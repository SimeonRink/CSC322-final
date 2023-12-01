import 'dart:io';
import 'package:egr423_starter_project/models/stocks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class buyStock extends StatefulWidget {
  const buyStock(
      {super.key,
      required this.ticker,
      required this.currentPrice,
      required this.onBuyStock});

  final void Function(Stocks buy) onBuyStock;
  final String ticker;
  final String currentPrice;

  @override
  State<buyStock> createState() {
    return _buyStockState();
  }
}

class _buyStockState extends State<buyStock> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final _user = FirebaseAuth.instance.currentUser;
  Widget content = const Text('--');

  void _showDialog() {
    //find out what platform you are on to have alert dialogs display in the same style
    if (Platform.isIOS) {
      showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
                title: const Text('Invalid input'),
                content: const Text(
                    'Please make sure a valid title, amount, date and category was entered.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                    },
                    child: const Text('Okay'),
                  ),
                ],
              ));
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Invalid input'),
          content: const Text(
              'Please make sure a valid title, amount, date and category was entered.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text('Okay'),
            ),
          ],
        ),
      );
    }
  }

  void _submitStockData() {
    final enteredAmount = int.tryParse(_amountController.text);
    final amountIsInvalid = enteredAmount == null || enteredAmount <= 0;
    if (amountIsInvalid) {
      _showDialog();
      return;
    }

    widget.onBuyStock(
      Stocks(
        ticker: _titleController.text,
        shares: enteredAmount,
        date: _selectedDate,
      ),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //getting the amount of space the keyboard takes up
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    //get constraints for screen
    return LayoutBuilder(
      builder: (ctx, Constraints) {
        final width = Constraints.maxWidth;

        return SizedBox(
          height: double.infinity,
          child: SingleChildScrollView(
            child: Padding(
              //implementing custom padding for the keyboard
              padding: EdgeInsets.fromLTRB(16, 16, 16, keyboardSpace + 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.ticker,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          widget.currentPrice,
                        ),
                      ),
                    ],
                  ),
                  if (width >= 600)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: 24),
                        Expanded(
                          child: TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              prefixText: '\$ ',
                              label: Text('Amount'),
                            ),
                          ),
                        ),
                      ],
                    )
                  else if (width >= 600)
                    Row(
                      children: [
                        const SizedBox(width: 24),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(format.format(_selectedDate)),
                              Icon(
                                Icons.calendar_month,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              prefixText: '\$ ',
                              label: Text('Amount'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(format.format(_selectedDate)),
                              const SizedBox(width: 16),
                              const Icon(
                                Icons.calendar_month,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  if (width >= 600)
                    Row(
                      children: [
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: _submitStockData,
                          child: const Text('Buy'),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: _submitStockData,
                          child: const Text('Buy'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
