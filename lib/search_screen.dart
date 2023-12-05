import 'dart:convert';

import 'package:egr423_starter_project/widgets/stock_card.dart';
import 'package:egr423_starter_project/widgets/stock_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  void _loadStock(String searchStock) async {
    final url =
        'https://api.polygon.io/v2/aggs/ticker/$searchStock/prev?adjusted=true&apiKey=NLdW0h6K2uq9ttogUpaDrUzMapnwLMVg';

    try {
      if (url ==
          'https://api.polygon.io/v2/aggs/ticker//prev?adjusted=true&apiKey=NLdW0h6K2uq9ttogUpaDrUzMapnwLMVg') {
        isLoading = false;
        return;
      }
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
          content = StockCard(stockName: stockName, result: result);
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
      print('Error: $error');
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
                StockWidget(stock: followedStocks[i]),
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
                  labelText: 'Enter search term',
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
