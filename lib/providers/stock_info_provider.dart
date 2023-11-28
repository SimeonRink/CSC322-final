// import 'dart:convert';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;


// class StockProvider with ChangeNotifier {
//   var content;
//   String stockName = '';
//   List<dynamic> followedStocks = [];
//   final _user = FirebaseAuth.instance.currentUser;
//   bool following = false;
//   bool isLoading = false;
//   bool isViewing = false;

//     void _getStocks() async {
//     CollectionReference stockDataCollection =
//         FirebaseFirestore.instance.collection('userStocks');

//     // Get the current data in the document
//     var currentData = await stockDataCollection.doc(_user!.email).get();

//     // Get the current array of stock names
//     var stockNames =
//         (currentData.data() as Map<String, dynamic>)['stockNames'] ?? [];
//     //Update the UI with the new following status
//     setState(() {
//       followedStocks = stockNames;
//     });
//   }

//   void _followStock() async {
//     CollectionReference stockDataCollection =
//         FirebaseFirestore.instance.collection('userStocks');

//     // Get the current data in the document
//     var currentData = await stockDataCollection.doc(_user!.email).get();

//     // Get the current array of stock names
//     var stockNames =
//         (currentData.data() as Map<String, dynamic>)['stockNames'] ?? [];

//     // Toggle follow/unfollow
//     if (!stockNames.contains(stockName)) {
//       stockNames.add(stockName);
//     } else {
//       stockNames.remove(stockName);
//     }

//     // Update the document with the new array
//     await stockDataCollection.doc(_user!.email).update({
//       'stockNames': stockNames,
//     });

//     // Update the UI with the new following status
//     setState(() {
//       followedStocks = stockNames;
//       following = !following;
//     });
//   }

//   void _loadStock(String searchStock) async {
//     final url =
//         'https://api.polygon.io/v2/aggs/ticker/$searchStock/prev?adjusted=true&apiKey=NLdW0h6K2uq9ttogUpaDrUzMapnwLMVg';

//     try {
//       final response = await http.get(Uri.parse(url));

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);

//         // Access the "results" list and get the first item
//         final result = data['results'][0];

//         CollectionReference stockDataCollection =
//             FirebaseFirestore.instance.collection('userStocks');

//         // Get the current data in the document
//         var currentData = await stockDataCollection.doc(_user!.email).get();

//         // Get the current array of stock names
//         var stockNames =
//             (currentData.data() as Map<String, dynamic>)['stockNames'] ?? [];

//         following = stockNames.contains(stockName);

//         setState(() {
//           isLoading = false;
//           content = _buildStockCard(result, stockNames.contains(stockName));
//           isViewing = true;
//         });
//       } else {
//         // NOT WORKING YET
//         setState(() {
//           content = Padding(
//             padding: EdgeInsetsDirectional.only(top: 100),
//             child: const Center(
//               child: Text(
//                 'Could not find that stock. Try again!',
//                 style: TextStyle(
//                   fontSize: 30,
//                 ),
//               ),
//             ),
//           );
//         });
//       }
//     } catch (error) {
//       print('Error: $error');
//     }
//   }

// }
