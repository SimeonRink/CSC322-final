import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:egr423_starter_project/add_funds.dart';
import 'package:egr423_starter_project/models/funds.dart';
import 'package:egr423_starter_project/widgets/bar_chart.dart';
import 'package:egr423_starter_project/widgets/navigation/app_drawer.dart';
import 'package:egr423_starter_project/widgets/stock_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _user = FirebaseAuth.instance.currentUser;
  double funds = 0.0;
  double buyingPower = 0.0;
  double initialFunds = 0.0;
  List<dynamic> myStocks = [];

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

  void _getMyStocks() async {
    CollectionReference stockDataCollection =
        FirebaseFirestore.instance.collection('userStocks');

    // Get the current data in the document
    var currentData = await stockDataCollection.doc(_user!.email).get();

    List<dynamic> boughtStocks =
        (currentData.data() as Map<String, dynamic>)['filteredShares'] ?? [];

    // Filter stocks with numberOfShares equal to 0
    List<String> stockNames = boughtStocks
        .where((stock) => (stock['totalShares'] ?? 0) != 0)
        .map((stock) => stock['stockName'] as String)
        .toSet() // Remove duplicates by converting to a set
        .toList(); // Convert back to a list

    // Update the UI with the new list of stock names
    setState(() {
      myStocks = stockNames;
    });
  }

  void _updateBuyingPower() async {
    CollectionReference stockDataCollection =
        FirebaseFirestore.instance.collection('userStocks');

    var currentData = await stockDataCollection.doc(_user!.email).get();

    setState(() {
      buyingPower = (currentData.data() as Map<String, dynamic>)['buyingPower'];
    });
  }

  _updateFunds() async {
    CollectionReference stockDataCollection =
        FirebaseFirestore.instance.collection('userStocks');

    var currentData = await stockDataCollection.doc(_user!.email).get();

    setState(() {
      funds = (currentData.data() as Map<String, dynamic>)['funds'];
    });
  }

  _updateInitialFunds() async {
    CollectionReference stockDataCollection =
        FirebaseFirestore.instance.collection('userStocks');

    var currentData = await stockDataCollection.doc(_user!.email).get();

    setState(() {
      initialFunds =
          (currentData.data() as Map<String, dynamic>)['initialFunds'];
    });
  }

  void _addFund(Fund fund) async {
    CollectionReference stockDataCollection =
        FirebaseFirestore.instance.collection('userStocks');

    var currentData = await stockDataCollection.doc(_user!.email).get();

    funds = (currentData.data() as Map<String, dynamic>)['funds'] ?? 0.0;
    buyingPower =
        (currentData.data() as Map<String, dynamic>)['buyingPower'] ?? 0.0;

    initialFunds =
        (currentData.data() as Map<String, dynamic>)['initialFunds'] ?? 0.0;

    setState(() {
      // Update funds with the new amount
      funds += fund.amount;
      buyingPower += fund.amount;
      initialFunds += fund.amount;
    });

    await stockDataCollection.doc(_user!.email).set(
      {
        'funds': funds,
        'buyingPower': buyingPower,
        'initialFunds': initialFunds
      },
      SetOptions(merge: true),
    );
  }

  @override
  void initState() {
    _getMyStocks();
    _updateBuyingPower();
    _updateInitialFunds();
    _updateFunds();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              // Text(
              //   'Available funds: \$${funds.toStringAsFixed(2)}', // Display the balance with 2 decimal places
              //   style: const TextStyle(
              //     fontSize: 25,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              const SizedBox(
                height: 30,
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.3,
                width: MediaQuery.of(context).size.width,
                child: BarChartWidget(
                    initialFunds: initialFunds, currentFunds: funds),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Buying Power: ',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Text(
                    '\$${buyingPower.toStringAsFixed(2)}',
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
              SizedBox(height: 20),
              for (var i = 0; i < myStocks.length; i++)
                StockWidget(ticker: myStocks[i]),
            ],
          ),
        ),
      ),
    );
  }
}
