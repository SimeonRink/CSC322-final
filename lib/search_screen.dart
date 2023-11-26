import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  var content;
  String stockName = '';
  double high = 0.0;

  void _loadStock(String searchStock) async {
    final url =
        'https://api.polygon.io/v2/aggs/ticker/AAPL/prev?adjusted=true&apiKey=NLdW0h6K2uq9ttogUpaDrUzMapnwLMVg';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Access the "results" list and get the first item
        final result = data['results'][0];

        // Access the value of "h" (high) and store it in a variable
        // double highValue = result['h'];

        setState(() {
          content = Container(
            padding: EdgeInsetsDirectional.only(top: 20),
            child: Column(
              children: [
                Text('Stock data for $searchStock from the previous day'),
                Text('High: ${result['h']}'),
                Text('Low: ${result['l']}'),
                Text('Open: ${result['o']}'),
                Text('Close: ${result['c']}'),
                Text('Total number of shares traded: ${result['v']}')
              ],
            ),
          );
        });

        // Print the value or use it as needed
        // print('High value: $highValue');
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
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
                _loadStock(searchStock);
              },
            ),
            content,
          ],
        ),
      ),
    );
  }
}
