import 'package:egr423_starter_project/add_funds.dart';
import 'package:egr423_starter_project/models/funds.dart';
import 'package:egr423_starter_project/widgets/navigation/app_drawer.dart';
import 'package:flutter/material.dart';

final List<Fund> addedFunds = [];
double startAmount = 0;

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _openAddFundOverlay() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => addFunds(
        onAddFunds: _addFund,
      ),
    );
  }

  void _addFund(Fund fund) {
    startAmount = 0;

    setState(() {
      addedFunds.add(fund);
      for (final bucket in addedFunds) {
        startAmount += bucket.amount;
      }
    });
  }

  TextEditingController _valueController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Widget content;
    double balance = startAmount;
    double stocksBought = 0;
    double buyingPower = balance - stocksBought;
    List<String> stocks = [];

    Widget stockContent = const Center(
      child: Text("No stocks found. Start adding some!"),
    );

    if (addedFunds.isEmpty) {
      content = AlertDialog(
        title: Text('You have no funds!'),
        actions: <Widget>[
          TextButton(
            onPressed: _openAddFundOverlay,
            child: Text('Add Funds'),
          ),
        ],
      );
    } else {
      content = Scaffold(
        appBar: AppBar(
          title: const Text('Investing'),
          actions: [
            IconButton(
                onPressed: _openAddFundOverlay, icon: const Icon(Icons.add)),
          ],
        ),
        drawer: AppDrawer(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Text(
                  '\$${balance.toStringAsFixed(2)}', // Display the balance with 2 decimal places
                  style: const TextStyle(
                    fontSize: 36.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 200,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'buying power: ',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Text(
                      '\$${balance.toStringAsFixed(2)}',
                      // stocksBought.toStringAsFixed(2),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'My Stocks',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
                stockContent,
              ],
            ),
          ),
        ),
      );
    }
    return content;
  }
}
