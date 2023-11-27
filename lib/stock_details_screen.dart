import 'package:flutter/material.dart';

class StockDetailsScreen extends StatefulWidget {
  const StockDetailsScreen({super.key});

  @override
  State<StockDetailsScreen> createState() => _StockDetailsScreenState();
}

class _StockDetailsScreenState extends State<StockDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Details'),
      ),
      body: Center(
        child: Text('Stock Details'),
      ),
    );
  }
}
