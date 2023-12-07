import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:egr423_starter_project/widgets/stock_card.dart';
import 'package:egr423_starter_project/widgets/stock_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  var content;
  String stockName = '';
  List<dynamic> followedStocks = [];
  final _user = FirebaseAuth.instance.currentUser;
  bool following = false;
  bool isLoading = false;
  bool isViewing = false;
  bool showFollowButton = true;
  String stockFullName = '';

  void _showDialog(String error) {
    //find out what platform you are on to have alert dialogs display in the same style
    if (Platform.isIOS) {
      showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
                title: const Text('Invalid input'),
                content: Text(error),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                    },
                    child: const Text('Okay'),
                  ),
                ],
              ));
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Invalid input'),
          content: Text(error),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text('Okay'),
            ),
          ],
        ),
      );
    }
  }

  void _getStocks() async {
    CollectionReference stockDataCollection =
        FirebaseFirestore.instance.collection('userStocks');

    // Get the current data in the document
    var currentData = await stockDataCollection.doc(_user!.email).get();

    // Get the current array of stock names
    var stockNames =
        (currentData.data() as Map<String, dynamic>)['stockNames'] ?? [];
    //Update the UI with the new following status
    setState(() {
      followedStocks = stockNames;
    });
  }

  void _followStock() async {
    CollectionReference stockDataCollection =
        FirebaseFirestore.instance.collection('userStocks');

    // Get the current data in the document
    var currentData = await stockDataCollection.doc(_user!.email).get();

    // Get the current array of stock names
    var stockNames =
        (currentData.data() as Map<String, dynamic>)['stockNames'] ?? [];

    // Toggle follow/unfollow
    if (!stockNames.contains(stockName)) {
      stockNames.add(stockName);
    } else {
      stockNames.remove(stockName);
    }

    // Update the document with the new array
    await stockDataCollection.doc(_user!.email).update({
      'stockNames': stockNames,
    });

    // Update the UI with the new following status
    setState(() {
      followedStocks = stockNames;
      following = !following;
    });
  }

  void _getStockFullName(String stockTicker) async {
    // this method checks the nsadaq, nyse, and other csv files to find the full name of the stock

    // Load the CSV file
    String csvData =
        await rootBundle.loadString('assets/nasdaq-listed_csv.csv');

    // Parse the CSV data
    List<List<dynamic>> csvTable = CsvToListConverter().convert(csvData);

    // Search for the stock in the CSV data
    for (int i = 1; i < csvTable.length; i++) {
      List<dynamic> row = csvTable[i];
      if (row.isNotEmpty && row[0] == stockTicker) {
        stockFullName = row[1];
        return;
      }
    }

    // Load the CSV file
    csvData = await rootBundle.loadString('assets/nyse-listed_csv.csv');

    // Parse the CSV data
    csvTable = CsvToListConverter().convert(csvData);

    // Search for the stock in the CSV data
    for (int i = 1; i < csvTable.length; i++) {
      List<dynamic> row = csvTable[i];
      if (row.isNotEmpty && row[0] == stockTicker) {
        stockFullName = row[1];
        return;
      }
    }

    // Load the CSV file
    csvData = await rootBundle.loadString('assets/other-listed_csv.csv');

    // Parse the CSV data
    csvTable = CsvToListConverter().convert(csvData);

    // Search for the stock in the CSV data
    for (int i = 1; i < csvTable.length; i++) {
      List<dynamic> row = csvTable[i];
      if (row.isNotEmpty && row[0] == stockTicker) {
        stockFullName = row[1];
        return;
      }
    }

    // Stock not found
    stockFullName = stockTicker;
  }

  void _loadStock(String ticker) async {
    final url =
        'https://api.polygon.io/v2/aggs/ticker/$ticker/prev?adjusted=true&apiKey=NLdW0h6K2uq9ttogUpaDrUzMapnwLMVg';

    try {
      if (url ==
          'https://api.polygon.io/v2/aggs/ticker//prev?adjusted=true&apiKey=NLdW0h6K2uq9ttogUpaDrUzMapnwLMVg') {
        isLoading = false;
        return;
      }

      _getStockFullName(ticker);

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Access the "results" list and get the first item
        var result;
        if (data['results'] == null) {
          setState(() {
            isLoading = false;
            showFollowButton = false;
            content = Padding(
              padding: EdgeInsetsDirectional.only(top: 100),
              child: const Center(
                child: Text(
                  'Could not find that stock. Try again!',
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
              ),
            );
          });
          return;
        } else {
          result = data['results'][0];
        }

        _getStocks();
        following = followedStocks.contains(stockName);

        setState(() {
          isLoading = false;
          content = StockCard(
              ticker: stockName, result: result, stockFullName: stockFullName);
          isViewing = true;
        });
      } else {
        setState(() {
          content = Padding(
            padding: EdgeInsetsDirectional.only(top: 100),
            child: const Center(
              child: Text(
                'API not working. Try again!',
                style: TextStyle(
                  fontSize: 30,
                ),
              ),
            ),
          );
        });
      }
    } catch (error) {
      _showDialog(error.toString());
    }
  }

  Widget _followButton() {
    return ElevatedButton(
      onPressed: () {
        _followStock();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
      ),
      child: Text(
        ((following) ? 'Unfollow Stock' : 'Follow Stock'),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _getStocks();
  }

  @override
  Widget build(BuildContext context) {
    if (stockName == '' && !isViewing) {
      if (followedStocks.isEmpty) {
        content = Padding(
          padding: EdgeInsetsDirectional.only(top: 100),
          child: const Center(
            child: Text(
              'No stock found yet. Start searching!',
              style: TextStyle(
                fontSize: 30,
              ),
            ),
          ),
        );
      } else {
        content = SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(children: [
              Row(
                children: [
                  Text(
                    'Stocks Following:',
                    style: TextStyle(
                      fontSize: 30,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              for (var i = 0; i < followedStocks.length; i++)
                StockWidget(
                  ticker: followedStocks[i],
                ),
            ]),
          ),
        );
      }
    }

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
        title: const Text('Search Stocks'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Enter stock ticker',
                  labelStyle: TextStyle(
                    fontSize: 20,
                  ),
                ),
                style: TextStyle(
                  fontSize: 20,
                ),
                onSubmitted: (String searchStock) {
                  stockName = searchStock.toUpperCase();
                  setState(() {
                    isLoading = true;
                  });
                  _loadStock(stockName);
                },
              ),
              content,
              (stockName != '' && !isLoading && showFollowButton)
                  ? Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              isViewing = false;
                              stockName = '';
                            });
                          },
                          icon: Icon(Icons.arrow_back),
                        ),
                        SizedBox(width: 50),
                        _followButton(),
                      ],
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
