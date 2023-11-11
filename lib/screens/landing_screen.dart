// NOTE Will need to authenticate on FRAMES using HTTP requests so will likely
// need to pass username/password to FRAMES
// https://firebase.google.com/docs/reference/rest/auth#section-verify-custom-token

// Dart imports
import 'dart:convert';

// Flutter imports
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

// File Imports
import '../providers/user_profile_provider.dart';
import '../widgets/navigation/app_drawer.dart';

//////////////////////////////////////////////////////////////////
// StateFUL widget which manages state. Simply initializes the
// state object.
//////////////////////////////////////////////////////////////////
class LandingScreen extends StatefulWidget {
  // Route name declaration
  static const routeName = '/landing';

  @override
  _LandingScreenState createState() => _LandingScreenState();
}

//////////////////////////////////////////////////////////////////
// THe actual STATE which is managed by the above widget.
//////////////////////////////////////////////////////////////////
class _LandingScreenState extends State<LandingScreen> {
  // Instance variables
  var _token;
  var _refreshToken;
  var _tokenExpireDate;
  var _isInit = true;
  late UserProfileProvider _userProfileProvider;

  // Final variables that do not change
  final _user = FirebaseAuth.instance.currentUser;

  ////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////
  /// INIT Methods
  ////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////
  // Gets the current state of the providers for consumption on
  // this page
  ////////////////////////////////////////////////////////////////
  _getProviderSettings() async {
    _userProfileProvider = Provider.of<UserProfileProvider>(context);
    await _userProfileProvider.fetchUserProfileIfNeeded();
  }

  ////////////////////////////////////////////////////////////////
  // Runs the following code once upon initialization, which reads
  // the Product from navigation parameters and updates the vars
  // connected to the UI (used for loading data from existing
  // products).
  ////////////////////////////////////////////////////////////////
  @override
  void didChangeDependencies() {
    // If first time running this code, update provider settings
    if (_isInit) {
      _getProviderSettings();
    }

    // Now initialized; run super method
    _isInit = false;
    super.didChangeDependencies();
  }

  ////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////
  /// Helper Methods (for state object)
  ////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////
  // Gets a fresh authentication token and saves it in the device
  // storage.
  ////////////////////////////////////////////////////////////////
  Future<bool> _getAndStoreNewToken() async {
    // Get a fresh token (should be good for 60 minutes)
    _token = await _user!.getIdToken(true);
    _tokenExpireDate = DateTime.now().add(Duration(seconds: 60 * 60));
    _refreshToken = _user!.refreshToken;
    // Store user credentials on the device storage as JSON object
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'userId': _user!.uid,
          'tokenExpireDate': _tokenExpireDate.toIso8601String(),
        },
      );
      return await prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  ////////////////////////////////////////////////////////////////
  // Primary Flutter method overriden which describes the layout
  // and bindings for this widget.
  ////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    // Get and store token/user info
    Future<bool> _tokenFuture = _getAndStoreNewToken();

    return Scaffold(
      appBar: AppBar(
        title: Text('Globe Frames'),
      ),
      drawer: AppDrawer(),
      body: Column(
        children: [
          Text("Welcome ${_userProfileProvider.firstName} ${_userProfileProvider.lastName}!"),
          Text("USER:"),
          Text("Email: ${_user!.email}"),
          Text("Display Name: ${_user!.displayName}"),
          Text("Email Verified: ${_user!.emailVerified}"),
          Text("UID: ${_user!.uid}"),
          FutureBuilder(
              future: _tokenFuture,
              builder: (context, appSnapshot) {
                if (appSnapshot.connectionState == ConnectionState.waiting)
                  return CircularProgressIndicator();
                else if (appSnapshot.hasData && !(appSnapshot.data as bool))
                  return Text("Token: COULD NOT GENERATE");
                else
                  return Column(
                    children: [
                      Text("Refresh Token: $_refreshToken"),
                      Text("Token: $_token"),
                      Text(
                          "Token Expiration: ${DateFormat('MM/dd/yyyy hh:mm:ss').format(_tokenExpireDate)}"),
                    ],
                  );
              }),
        ],
      ),
    );
  }
}
