import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:egr423_starter_project/buy_stock.dart';
import 'package:egr423_starter_project/models/stocks.dart';
import 'package:egr423_starter_project/sell_stock.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:egr423_starter_project/widgets/line_chart_widget.dart';
import 'package:intl/intl.dart';

class StockDetailsScreen extends StatefulWidget {
  const StockDetailsScreen({
    super.key,
    required this.ticker,
    required this.stockFullName,
  });

  final String ticker;
  final String stockFullName;

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
  bool isLoading = true;
  var content;
  List<dynamic> stockClosePrices = [];

  void _getInfo() async {
    CollectionReference stockDataCollection =
        FirebaseFirestore.instance.collection('userStocks');
    String stockName = widget.ticker;

    var currentData = await stockDataCollection.doc(_user!.email).get();

    List<Map<String, dynamic>> filteredShares = List<Map<String, dynamic>>.from(
        (currentData.data() as Map<String, dynamic>)['filteredShares'] ?? []);

    if (filteredShares.isNotEmpty) {
      var filteredInfo = filteredShares.firstWhere(
        (stock) => stock['stockName'] == stockName,
        orElse: () => {},
      );
      if (filteredInfo.length > 0) {
        setState(() {
          hasStock = true;
        });
      } else {
        setState(() {
          hasStock = false;
        });
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
    final url =
        'https://api.polygon.io/v2/aggs/ticker/${widget.ticker}/prev?adjusted=true&apiKey=NLdW0h6K2uq9ttogUpaDrUzMapnwLMVg';

    try {
      final response = await http.get(Uri.parse(url));
      final Map<String, dynamic> data = json.decode(response.body);

      // Access the "results" list and get the first item
      var result = data['results'][0];
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
          ticker: widget.ticker,
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
      buyingPower = (currentData.data() as Map<String, dynamic>)['buyingPower'];
    });
    String stockName = widget.ticker;

    // Find the totalShares for the specific stock
    var stockInfo = filteredShares.firstWhere(
      (stock) => stock['stockName'] == stockName,
    );

    double totalShares = stockInfo['totalShares'];
    final url =
        'https://api.polygon.io/v2/aggs/ticker/${widget.ticker}/prev?adjusted=true&apiKey=NLdW0h6K2uq9ttogUpaDrUzMapnwLMVg';

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
            ticker: widget.ticker,
            onSellStock: _sellStocks,
            totalShares: totalShares),
      );
    } catch (error) {
      print('Error: $error');
    }
  }

  void _sellStocks(Stocks stock) async {
    CollectionReference stockDataCollection =
        FirebaseFirestore.instance.collection('userStocks');
    String stockName = widget.ticker;

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

  double _getMaxY() {
    double max = 0.0;
    for (int i = 0; i < stockClosePrices.length; i++) {
      if (stockClosePrices[i] > max) {
        max = stockClosePrices[i];
      }
    }
    return max;
  }

  double _getMinY() {
    double min = stockClosePrices[0];
    for (int i = 1; i < stockClosePrices.length - 1; i++) {
      if (min > stockClosePrices[i] && stockClosePrices[i] != 0.0) {
        min = stockClosePrices[i];
      }
    }
    return min;
  }

  _loadStockDetails() async {
    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String prevDate = DateFormat('yyyy-MM-dd')
        .format(DateTime.now().subtract(const Duration(days: 90)));

    final url =
        'https://api.polygon.io/v2/aggs/ticker/${widget.ticker}/range/1/day/$prevDate/$currentDate?adjusted=true&sort=asc&limit=120&apiKey=NLdW0h6K2uq9ttogUpaDrUzMapnwLMVg';

    try {
      final response = await http.get(Uri.parse(url));

      // if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      // Access the "results" list and get the first item
      if (data.containsKey('results')) {
        for (int i = 0; i < data['results'].length; i++) {
          stockClosePrices.add(data['results'][i]['c']);
        }
      } else {
        print('No results found in the data.');
        // Handle the case where results are not available as needed.
      }

      double max = _getMaxY();
      double min = _getMinY();

      var width = MediaQuery.of(context).size.width;
      var heigth = MediaQuery.of(context).size.height;

      setState(() {
        isLoading = false;
        content = Column(
          children: [
            Text(
              'Below is the closing prices of ${widget.stockFullName} over the past 90 days.',
              style: TextStyle(fontSize: 20),
            ),
            Container(
              height: heigth * 0.4,
              width: width,
              child: LineChartWidget(
                stockClosePrices: stockClosePrices,
                maxY: max,
                minY: min,
              ),
            ),
            Row(
              children: [
                SizedBox(
                  width: width * 0.5,
                  child: Text(
                    '3 months ago',
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(
                  width: width * 0.4,
                  child: Text(
                    'today',
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'This stock peaked with a price of \$${max.toStringAsFixed(2)} and bottomed out at \$${min.toStringAsFixed(2)}.',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ],
        );
      });
      // } else {
      //   setState(() {
      //     content = Padding(
      //       padding: EdgeInsetsDirectional.only(top: 100),
      //       child: const Center(
      //         child: Text(
      //           'API not working. Try again!',
      //           style: TextStyle(
      //             fontSize: 30,
      //           ),
      //         ),
      //       ),
      //     );
      //   });
      // }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    _getInfo();
    _loadStockDetails();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      content = Padding(
        padding: EdgeInsetsDirectional.only(top: 100),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.ticker} Details'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: content,
      ),
    );
  }
}
