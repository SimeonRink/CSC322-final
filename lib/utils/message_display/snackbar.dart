// External Flutter imports
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Enumeration type for coloring the snackbar
enum SnackbarDisplayType { SB_ERROR, SB_INFO, SB_SUCCESS }

//////////////////////////////////////////////////////////////////
// Class definition for SnackbarWrapper. This is essentially a
// wrapper around the Snackbar library and the required scaffolding
// to get that working.
//////////////////////////////////////////////////////////////////
class Snackbar {
  //////////////////////////////////////////////////////////////////
  // This function takes in a message type, message, message
  // origin (from frames or from phone) and local context and
  // displays a snackbar with the appropriate message, color and
  // source icon.
  //////////////////////////////////////////////////////////////////
  static show(SnackbarDisplayType msgType, String message, BuildContext context) {
    // Get proper color
    Color snackBarColor = Colors.greenAccent;
    if (msgType == SnackbarDisplayType.SB_ERROR) {
      snackBarColor = Theme.of(context).errorColor;
    } else if (msgType == SnackbarDisplayType.SB_INFO) {
      snackBarColor = Colors.lightBlue;
    }

    // Show message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (msgType == SnackbarDisplayType.SB_ERROR)
              Icon(CupertinoIcons.xmark_circle, color: Colors.white),
            if (msgType == SnackbarDisplayType.SB_SUCCESS)
              Icon(CupertinoIcons.check_mark_circled, color: Colors.white),
            if (msgType == SnackbarDisplayType.SB_INFO)
              Icon(CupertinoIcons.exclamationmark_circle, color: Colors.white),
            const SizedBox(width: 10),
            Flexible(child: Text(message)),
          ],
        ),
        backgroundColor: snackBarColor,
      ),
    );
  }
}
