import 'package:csv/csv.dart';
import 'package:egr423_starter_project/screens/stock_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StockWidget extends StatefulWidget {
  StockWidget({
    super.key,
    required this.ticker,
  });

  final String ticker;

  @override
  State<StockWidget> createState() => _StockWidgetState();
}

class _StockWidgetState extends State<StockWidget> {
  String stockFullName = 'Stock Full Name';

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
        setState(() {
          stockFullName = row[1];
        });
        // stockFullName = row[1];
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
        setState(() {
          stockFullName = row[1];
        });
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
        setState(() {
          stockFullName = row[1];
        });
        return;
      }
    }

    // Stock not found
    stockFullName = stockTicker;
  }

  @override
  Widget build(BuildContext context) {
    _getStockFullName(widget.ticker);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding:
            const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '${stockFullName}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue, // Set text color
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StockDetailsScreen(
                      ticker: widget.ticker,
                      stockFullName: stockFullName,
                    ),
                  ),
                );
              },
              child: Text(
                'View',
                style: TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
