import 'dart:convert';

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

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Access the "results" list and get the first item
        final result = data['results'][0];

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
          content = _buildStockCard(result, stockNames.contains(stockName));
        });
      } else {
        // NOT WORKING YET
        setState(() {
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
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Card _buildStockCard(Map<String, dynamic> result, bool isFollowing) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stock data for ${result['T']} from the previous day',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlue, // Set text color
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'High: ${result['h']}',
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Low: ${result['l']}',
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Open: ${result['o']}',
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Close: ${result['c']}',
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Volume: ${result['v']}',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        //navigate to details screen
                      },
                      child: Text(
                        'View Details',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _followButton() {
    return ElevatedButton(
      onPressed: () {
        _followStock();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue, // Set button color
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
              (stockName != '' && !isLoading) ? _followButton() : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
