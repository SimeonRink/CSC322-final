import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:egr423_starter_project/buy_stock.dart';
import 'package:egr423_starter_project/models/stocks.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final _user = FirebaseAuth.instance.currentUser;
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
      CollectionReference stockDataCollection =
          FirebaseFirestore.instance.collection('userStocks');

      // Get the current data in the document
      var currentData = await stockDataCollection.doc(_user!.email).get();
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
        ),
      );
    } catch (error) {
      print('Error: $error');
    }
  }

  _updateStocks() async {
    CollectionReference stockDataCollection =
        FirebaseFirestore.instance.collection('userStocks');

    var currentData = await stockDataCollection.doc(_user!.email).get();

    setState(() {
      shares = (currentData.data() as Map<String, dynamic>)['funds'];
    });
  }

  void _buyStocks(Stocks stock) async {
    CollectionReference stockDataCollection =
        FirebaseFirestore.instance.collection('userStocks');

    var currentData = await stockDataCollection.doc(_user!.email).get();
    final Map<String, dynamic> stockInfo = {
      'stockName': stock.ticker,
      'numberOfShares': stock.shares,
      'PricePerShare': stock.currentPrice,
    };

    List<Map<String, dynamic>> boughtStocks = List<Map<String, dynamic>>.from(
        (currentData.data() as Map<String, dynamic>)['boughtStocks'] ?? []);

    setState(() {
      // Update funds with the new amount
      shares += stock.shares;
      buyingPower -= stock.shares * double.parse(currentPrice);
      boughtStocks.add(stockInfo);
      print(boughtStocks);
    });

    await stockDataCollection.doc(_user!.email).set(
      {
        'buyingPower': buyingPower,
        'boughtStocks': boughtStocks,
      },
      SetOptions(merge: true),
    );
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
        ],
      ),
      body: Center(
        child: Text('${widget.stockName} Details'),
      ),
    );
  }
}
