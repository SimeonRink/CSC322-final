import 'dart:convert';

import 'package:egr423_starter_project/widgets/stock_card.dart';
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
  final _user = FirebaseAuth.instance.currentUser;
  bool following = false;
  bool isLoading = false;
  bool showFollowButton = true;

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
      following = !following;
    });
  }

  void _loadStock(String searchStock) async {
    final url =
        'https://api.polygon.io/v2/aggs/ticker/$searchStock/prev?adjusted=true&apiKey=NLdW0h6K2uq9ttogUpaDrUzMapnwLMVg';

    try {
      final response = await http.get(Uri.parse(url));
      print(response.statusCode);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        print(data['status']);

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

        CollectionReference stockDataCollection =
            FirebaseFirestore.instance.collection('userStocks');

        // Get the current data in the document
        var currentData = await stockDataCollection.doc(_user!.email).get();

        // Get the current array of stock names
        var stockNames =
            (currentData.data() as Map<String, dynamic>)['stockNames'] ?? [];

        following = stockNames.contains(stockName);

        setState(() {
          isLoading = false;
          content = StockCard(stockName: stockName, result: result);
        });
      } else {
        // not working
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
  Widget build(BuildContext context) {
    if (stockName == '') {
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
                  ? _followButton()
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
