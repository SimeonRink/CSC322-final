import 'package:egr423_starter_project/widgets/line_chart_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class StockDetailsScreen extends StatefulWidget {
  const StockDetailsScreen({super.key, required this.ticker});

  final String ticker;

  @override
  State<StockDetailsScreen> createState() => _StockDetailsScreenState();
}

class _StockDetailsScreenState extends State<StockDetailsScreen> {
  bool isLoading = true;
  var content;
  List<dynamic> stockClosePrices = [];

  double _getMaxY() {
    double max = 0.0;
    for (int i = 0; i < stockClosePrices.length; i++) {
      if (stockClosePrices[i] > max) {
        max = stockClosePrices[i];
      }
    }
    return max + 5;
  }

  double _getMinY() {
    double min = stockClosePrices[0];
    for (int i = 1; i < stockClosePrices.length - 1; i++) {
      if (min > stockClosePrices[i] && stockClosePrices[i] != 0.0) {
        min = stockClosePrices[i];
      }
    }
    return min - 5;
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

      setState(() {
        isLoading = false;
        content = Center(
          child: Column(
            children: [
              Text(
                'Below is the closing prices of the stock over the past 90 days.',
                style: TextStyle(fontSize: 20),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.5,
                width: MediaQuery.of(context).size.width,
                child: LineChartWidget(
                  stockClosePrices: stockClosePrices,
                  maxY: max,
                  minY: min,
                ),
              ),
              Text(
                '${widget.ticker} peaked with a price of \$${max.toStringAsFixed(2)} and bottomed out at \$${min.toStringAsFixed(2)}.',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ],
          ),
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
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: content,
        ),
      ),
    );
  }
}
