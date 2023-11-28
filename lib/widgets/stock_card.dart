import 'package:egr423_starter_project/stock_details_screen.dart';
import 'package:flutter/material.dart';

class StockCard extends StatelessWidget {
  const StockCard({super.key, required this.stockName, required this.result});

  final String stockName;
  final Map<String, dynamic> result;

  @override
  Widget build(BuildContext context) {
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StockDetailsScreen(
                                  stockName: stockName,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            'View Details',
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                        SizedBox(width: 10),
                      ],
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
}
