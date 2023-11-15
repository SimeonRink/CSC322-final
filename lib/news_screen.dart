import 'package:flutter/material.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('News Tracker'),
        ),
        body: Column(
          children: [
            Text('News'),
          ],
        ));
  }
}
