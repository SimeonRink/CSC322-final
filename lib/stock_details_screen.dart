import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:egr423_starter_project/buy_stock.dart';
import 'package:egr423_starter_project/models/stocks.dart';
import 'package:egr423_starter_project/sell_stock.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StockDetailsScreen extends StatefulWidget {
  const StockDetailsScreen({super.key, required this.stockName});

  final String stockName;

  @override
  State<StockDetailsScreen> createState() => _StockDetailsScreenState();
}

class _StockDetailsScreenState extends State<StockDetailsScreen> {
  List boughtStocks = [];
  double shares = 0.0;
  String currentPrice = '';
  double buyingPower = 0.0;
  double totalShares = 0.0;
  bool hasStock = false;
  final _user = FirebaseAuth.instance.currentUser;

  void _getInfo() async {
    print('phase 1');
    CollectionReference stockDataCollection =
        FirebaseFirestore.instance.collection('userStocks');
    String stockName = widget.stockName;

    var currentData = await stockDataCollection.doc(_user!.email).get();

    List<Map<String, dynamic>> filteredShares = List<Map<String, dynamic>>.from(
        (currentData.data() as Map<String, dynamic>)['filteredShares'] ?? []);

    if (filteredShares.isNotEmpty) {
      print('phase 2');
      var filteredInfo = filteredShares.firstWhere(
        (stock) => stock['stockName'] == stockName,
        orElse: () => {},
      );
      if (filteredInfo.length > 0) {
        print(hasStock);
        setState(() {
          hasStock = true;
        });
        print(hasStock);
      } else {
        print(hasStock);
        setState(() {
          hasStock = false;
        });
        print(hasStock);
      }
    } else {
      totalShares = 0;
    }
  }

  void _openBuyStockOverlay() async {
    CollectionReference stockDataCollection =
        FirebaseFirestore.instance.collection('userStocks');
    var currentData = await stockDataCollection.doc(_user!.email).get();

    setState(() {
      buyingPower = (currentData.data() as Map<String, dynamic>)['buyingPower'];
    });
    print(widget.stockName);
    final url =
        'https://api.polygon.io/v2/aggs/ticker/${widget.stockName}/prev?adjusted=true&apiKey=NLdW0h6K2uq9ttogUpaDrUzMapnwLMVg';

    try {
      final response = await http.get(Uri.parse(url));
      print(response.body);
      final Map<String, dynamic> data = json.decode(response.body);

      // Access the "results" list and get the first item
      var result;
      result = data['results'][0];
      print(data['results'][0]);
      // Get the current data in the document
      setState(() {
        currentPrice = result['c'].toStringAsFixed(2);
      });
      showModalBottomSheet(
        useSafeArea: true,
        isScrollControlled: true,
        context: context,
        builder: (ctx) => buyStock(
          currentPrice: currentPrice,
          ticker: widget.stockName,
          onBuyStock: _buyStocks,
          buyingPower: buyingPower,
          totalShares: totalShares,
        ),
      );
    } catch (error) {
      print('Error: $error');
    }
  }

  void _openSellStockOverlay() async {
    CollectionReference stockDataCollection =
        FirebaseFirestore.instance.collection('userStocks');
    var currentData = await stockDataCollection.doc(_user!.email).get();
    List<Map<String, dynamic>> filteredShares = List<Map<String, dynamic>>.from(
        (currentData.data() as Map<String, dynamic>)['filteredShares'] ?? []);
    setState(() {
      shares = (currentData.data() as Map<String, dynamic>)['buyingPower'];
    });
    String stockName = widget.stockName;

    // Find the totalShares for the specific stock
    var stockInfo = filteredShares.firstWhere(
      (stock) => stock['stockName'] == stockName,
    );

    double totalShares = stockInfo['totalShares'];
    final url =
        'https://api.polygon.io/v2/aggs/ticker/${widget.stockName}/prev?adjusted=true&apiKey=NLdW0h6K2uq9ttogUpaDrUzMapnwLMVg';

    try {
      final response = await http.get(Uri.parse(url));
      print(response.body);
      final Map<String, dynamic> data = json.decode(response.body);

      // Access the "results" list and get the first item
      var result;
      result = data['results'][0];
      setState(() {
        currentPrice = result['c'].toStringAsFixed(2);
      });
      showModalBottomSheet(
        useSafeArea: true,
        isScrollControlled: true,
        context: context,
        builder: (ctx) => sellStock(
          currentPrice: currentPrice,
          ticker: widget.stockName,
          onSellStock: _sellStocks,
          totalShares: totalShares,
        ),
      );
    } catch (error) {
      print('Error: $error');
    }
  }

  void _sellStocks(Stocks stock) async {
    CollectionReference stockDataCollection =
        FirebaseFirestore.instance.collection('userStocks');
    String stockName = widget.stockName;

    var currentData = await stockDataCollection.doc(_user!.email).get();

    List<Map<String, dynamic>> filteredShares = List<Map<String, dynamic>>.from(
        (currentData.data() as Map<String, dynamic>)['filteredShares'] ?? []);

    if (filteredShares.isNotEmpty) {
      var filteredInfo = filteredShares.firstWhere(
        (stock) => stock['stockName'] == stockName,
        orElse: () => {},
      );
      if (filteredInfo.length > 0) {
        totalShares = filteredInfo['totalShares'];
      } else {
        totalShares = 0;
      }
    } else {
      totalShares = 0;
    }

    final Map<String, dynamic> stockInfo = {
      'stockName': stock.ticker,
      'numberOfShares': stock.shares,
      'PricePerShare': stock.currentPrice,
    };
    final Map<String, dynamic> totalInfo = {
      'stockName': stock.ticker,
      'totalShares': totalShares - stock.shares,
    };

    List<Map<String, dynamic>> soldStocks = List<Map<String, dynamic>>.from(
        (currentData.data() as Map<String, dynamic>)['soldStocks'] ?? []);

    soldStocks.add(stockInfo);
    filteredShares.removeWhere((stock) => stock['stockName'] == stockName);
    filteredShares.add(totalInfo);
    setState(() {
      // Update funds with the new amount
      hasStock = true;
      buyingPower += stock.shares * double.parse(currentPrice);
    });

    await stockDataCollection.doc(_user!.email).set(
      {
        'buyingPower': buyingPower,
        'soldStocks': soldStocks,
        'filteredShares': filteredShares,
      },
      SetOptions(merge: true),
    );
  }

  void _buyStocks(Stocks stock) async {
    CollectionReference stockDataCollection =
        FirebaseFirestore.instance.collection('userStocks');

    var currentData = await stockDataCollection.doc(_user!.email).get();

    List<Map<String, dynamic>> filteredShares = List<Map<String, dynamic>>.from(
        (currentData.data() as Map<String, dynamic>)['filteredShares'] ?? []);

    List<Map<String, dynamic>> boughtStocks = List<Map<String, dynamic>>.from(
        (currentData.data() as Map<String, dynamic>)['boughtStocks'] ?? []);
    String stockName = stock.ticker;

    if (filteredShares.isNotEmpty) {
      var filteredInfo = filteredShares.firstWhere(
        (stock) => stock['stockName'] == stockName,
        orElse: () => {},
      );
      if (filteredInfo.isNotEmpty) {
        totalShares = filteredInfo['totalShares'];
      } else {
        totalShares = 0;
      }
    } else {
      totalShares = 0;
    }

    final Map<String, dynamic> stockInfo = {
      'stockName': stock.ticker,
      'numberOfShares': stock.shares,
      'PricePerShare': stock.currentPrice,
    };

    final Map<String, dynamic> totalInfo = {
      'stockName': stock.ticker,
      'totalShares': totalShares + stock.shares,
    };

    // Update or add the stock entry in boughtStocks
    boughtStocks.add(stockInfo);
    filteredShares.removeWhere((stock) => stock['stockName'] == stockName);
    filteredShares.add(totalInfo);

    setState(() {
      // Update funds with the new amount
      buyingPower -= stock.shares * double.parse(currentPrice);
    });

    await stockDataCollection.doc(_user!.email).set(
      {
        'buyingPower': buyingPower,
        'boughtStocks': boughtStocks,
        'filteredShares': filteredShares,
      },
      SetOptions(merge: true),
    );
  }

  @override
  void initState() {
    super.initState();
    _getInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Details'),
        actions: [
          ElevatedButton(
            child: const Text('Buy'),
            onPressed: () {
              _openBuyStockOverlay();
            },
          ),
          const SizedBox(width: 10),
          (hasStock)
              ? ElevatedButton(
                  child: const Text('Sell'),
                  onPressed: () {
                    _openSellStockOverlay();
                  },
                )
              : const SizedBox(width: 5),
          const SizedBox(width: 5),
        ],
      ),
      body: Center(
        child: Text('${widget.stockName} Details'),
      ),
    );
  }
}
