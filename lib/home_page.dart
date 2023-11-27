import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:egr423_starter_project/add_funds.dart';
import 'package:egr423_starter_project/models/funds.dart';
import 'package:egr423_starter_project/widgets/navigation/app_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// final List<Fund> addedFunds = [];
// double startAmount = 0;

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _user = FirebaseAuth.instance.currentUser;
  List<String> _stocks = [];
  double funds = 0.0;

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

  void _addFund(Fund fund) async {
    CollectionReference stockDataCollection =
        FirebaseFirestore.instance.collection('userStocks');

    var currentData = await stockDataCollection.doc(_user!.email).get();

    funds = (currentData.data() as Map<String, dynamic>)['funds'];

    setState(() {
      // Update funds with the new amount
      funds += fund.amount;
    });

    await stockDataCollection.doc(_user!.email).set(
      {'funds': funds},
      SetOptions(merge: true),
    );
  }

  _getMyStocks() async {
    CollectionReference stockDataCollection =
        FirebaseFirestore.instance.collection('userStocks');

    // Get the current data in the document
    var currentData = await stockDataCollection.doc(_user!.email).get();

    // Get the current array of stock names
    var stockNames = (currentData.data() as Map<String, dynamic>)['stockNames'];

    if (!stockNames.isEmpty) {
      for (var stock in stockNames) {
        _stocks.add(stock);
      }
    }
  }

  @override
  void initState() {
    _getMyStocks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    // double balance = startAmount;

    // if (addedFunds.isEmpty) {
    //   content = AlertDialog(
    //     title: Text('You have no funds!'),
    //     actions: <Widget>[
    //       TextButton(
    //         onPressed: _openAddFundOverlay,
    //         child: Text('Add Funds'),
    //       ),
    //     ],
    //   );
    // } else {
    content = Scaffold(
      appBar: AppBar(
        title: const Text('Investing'),
        actions: [
          IconButton(
            onPressed: _openAddFundOverlay,
            icon: const Icon(Icons.add),
          ),
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
                'Available funds: \$${funds.toStringAsFixed(2)}', // Display the balance with 2 decimal places
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 200),
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
                    '\$${funds.toStringAsFixed(2)}',
                    // stocksBought.toStringAsFixed(2),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'My Stocks',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 40),
              (_stocks.isEmpty)
                  ? const Text('You have no stocks. Start following some!')
                  : Text('yup there are some stocks there'),
              // : ListView.builder(
              //     itemCount: _stocks.length,
              //     itemBuilder: (context, index) {
              //       return Text(
              //         _stocks[index],
              //         style: Theme.of(context).textTheme.titleMedium,
              //       );
              //     },
              //   ),
            ],
          ),
        ),
      ),
    );
    // }

    return content;
  }
}
