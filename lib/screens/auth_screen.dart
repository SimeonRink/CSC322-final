// Flutter external imports
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// File imports
import '../providers/user_profile_provider.dart';
import '../utils/message_display/snackbar.dart';
import '../widgets/auth/auth_form.dart';

//////////////////////////////////////////////////////////////////
// StateFUL widget which manages state. Simply initializes the
// state object.
//////////////////////////////////////////////////////////////////
class AuthScreen extends StatefulWidget {
  // Route name declaration
  static const routeName = '/auth';

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

//////////////////////////////////////////////////////////////////
// THe actual STATE which is managed by the above widget.
//////////////////////////////////////////////////////////////////
class _AuthScreenState extends State<AuthScreen> {
  // The "instance variables" managed in this state
  var _isLoading = false;
  var _isInit = true;
  late UserProfileProvider _userProfileProvider;

  // Finals used in this widget
  final _auth = FirebaseAuth.instance;

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
  // Attempts to either login to existing account or signup for
  // new account.
  ////////////////////////////////////////////////////////////////
  void _submitAuthForm(
    String email,
    String password,
    String firstName,
    String lastName,
    bool isLogin,
    BuildContext ctx,
  ) async {
    try {
      // Update screen to indicate loading spinner
      setState(() {
        _isLoading = true;
      });

      // If in "login mode", attempt to login with email/password...
      UserCredential authResult;
      if (isLogin) {
        authResult = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // If made it here, authentication was successful...load user profile
        await _userProfileProvider.fetchUserProfileIfNeeded();
      } else {
        //...else, signup for new account with email/password
        authResult = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Once account is created, send verification email
        User? user = _auth.currentUser;
        if (user != null) {
          // If made it here, account was created...create a profile with just email (so far)
          // and write it to the database
          _userProfileProvider.email = user.email ?? "";
          _userProfileProvider.firstName = firstName;
          _userProfileProvider.lastName = lastName;
          await _userProfileProvider.writeUserProfileToDb();

          if (!user.emailVerified) {
            await user.sendEmailVerification();

            // ...and display to user as "Snack bar" pop-up at bottom of screen
            String message = 'Check ${user.email} for verification link.';
            Snackbar.show(SnackbarDisplayType.SB_INFO, message, context);
          }
        }
      }
    } on PlatformException catch (err) {
      // If error occurs, gather error message...
      var message = 'An error occurred, please check your credentials!';
      if (err.message != null) message = err.message!;

      // ...and display to user as "Snack bar" pop-up at bottom of screen
      Snackbar.show(SnackbarDisplayType.SB_ERROR, message, context);

      // Dis-engage loading screen
      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      if (err is FirebaseAuthException) {
        if (err.code == 'email-already-in-use') {
          Snackbar.show(SnackbarDisplayType.SB_ERROR,
              '$email is already taken. Please try a new e-mail.', context);
        } else if (err.code == 'INVALID_LOGIN_CREDENTIALS') {
          Snackbar.show(
              SnackbarDisplayType.SB_ERROR,
              'Email/password combo for $email is invalid. Please re-type your e-mail or password.',
              context);
        }
        setState(() {
          _isLoading = false;
        });
      }

      // If other unknown error, log to console and dis-engage loading screen
      print(err);
      if (!mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  ////////////////////////////////////////////////////////////////
  // Primary Flutter method overriden which describes the layout
  // and bindings for this widget.
  ////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: LayoutBuilder(
        builder: (ctx, constraints) {
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: constraints.maxHeight * 0.1),
                Container(
                  width: constraints.maxWidth * 0.6,
                  child:
                      Image.asset('assets/images/image.png', fit: BoxFit.cover),
                ),
                AuthForm(
                  _submitAuthForm,
                  _isLoading,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
