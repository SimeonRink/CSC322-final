// External Flutter imports
import 'package:flutter/material.dart';

//////////////////////////////////////////////////////////////////
// Class definition for PopupDialogue. This is essentially a
// wrapper around the AlertDialog library and the required scaffolding
// to get that working.
//////////////////////////////////////////////////////////////////
class PopupDialogue {
  //////////////////////////////////////////////////////////////////
  // This method shows a Yes/No alert dialog to confirm a user
  // action. Returns TRUE if user selected YES; FALSE if user selected
  // NO.
  //////////////////////////////////////////////////////////////////
  static Future<bool?> showConfirm(String question, bool isDarkMode, BuildContext context) async {
    bool confirmed = false;
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            question,
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white70,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Yes"),
              onPressed: () {
                confirmed = true;
                Navigator.of(context).pop(confirmed);
              },
            ),
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop(confirmed);
              },
            ),
          ],
        );
      },
    );
  }
}
