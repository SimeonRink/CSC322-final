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
  final _user = FirebaseAuth.instance.currentUser;
  void _openBuyStockOverlay() async {
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

//   // Example data for a bought stock
// String ticker = 'AAPL';
// int shares = 10;

// // Get the current user document reference
// DocumentReference userDocRef = collectionReference.doc(email);

// // Get the current data in the document
// DocumentSnapshot userSnapshot = await userDocRef.get();
// Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

// // Get the current boughtStocks array
// List<Map<String, dynamic>> boughtStocks = List<Map<String, dynamic>>.from(userData['boughtStocks']);

// // Add the new bought stock to the array
// boughtStocks.add({
//   'ticker': ticker,
//   'shares': shares,
// });

// // Update the document with the new boughtStocks array
// await userDocRef.update({'boughtStocks': boughtStocks});

  void _buyStocks(Stocks stock) async {
    CollectionReference stockDataCollection =
        FirebaseFirestore.instance.collection('userStocks');

    var currentData = await stockDataCollection.doc(_user!.email).get();

    boughtStocks = (currentData.data() as Map<String, dynamic>)['boughtStocks'];

    setState(() {
      // Update funds with the new amount
      shares += stock.shares;
    });

    await stockDataCollection.doc(_user!.email).set(
      {'boughtStocks': shares},
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
