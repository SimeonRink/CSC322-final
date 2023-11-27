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

  void _followStock() async {
    CollectionReference stockDataCollection =
        FirebaseFirestore.instance.collection('userStocks');

    // Get the current data in the document
    var currentData = await stockDataCollection.doc(_user!.email).get();

    // List<String> stockNames;

    // if (currentData.exists) {
    //   stockNames = (currentData.data() as Map<String, dynamic>)['stockNames'];
    // } else {
    //   stockNames = {'stockNames': []};
    // }

    // Get the current array of stock names
    var stockNames = (currentData.data() as Map<String, dynamic>)['stockNames'];

    // If the document exists, update the existing array; otherwise, create a new array
    if (currentData.exists) {
      // Append the new stock name to the array
      if (!stockNames.contains(stockName)) {
        stockNames.add(stockName);
      } else {
        stockNames.remove(stockName);
      }

      // Update the document with the new array
      await stockDataCollection.doc(_user!.email).update({
        'stockNames': stockNames,
      });
    } else {
      // Create a new array with the stock name
      var stockNames = [stockName];

      // Create a new document with the array
      await stockDataCollection.doc(_user!.email).set({
        'stockNames': stockNames,
      });
    }
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

        setState(() {
          content = Container(
            padding: EdgeInsetsDirectional.only(top: 20),
            child: Column(
              children: [
                Text('Stock data for ${result['T']} from the previous day'),
                Text('High: ${result['h']}'),
                Text('Low: ${result['l']}'),
                Text('Open: ${result['o']}'),
                Text('Close: ${result['c']}'),
                Text('Total number of shares traded: ${result['v']}'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    _followStock();
                    setState(() {
                      following = !following;
                    });
                  },
                  child: Text(
                    (!following ? 'Follow Stock' : 'Unfollow Stock'),
                  ),
                ),
              ],
            ),
          );
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Stocks'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Enter search term',
              ),
              onSubmitted: (String searchStock) {
                stockName = searchStock.toUpperCase();
                _loadStock(stockName);
              },
            ),
            content,
          ],
        ),
      ),
    );
  }
}
