// Flutter imports
import 'package:flutter/material.dart';

//////////////////////////////////////////////////////////////////
// StateFUL widget which manages state. Simply initializes the
// state object.
//////////////////////////////////////////////////////////////////
class AuthForm extends StatefulWidget {
  // Finals used in this widget
  final bool isLoading;
  final void Function(
    String email,
    String password,
    String firstName,
    String lastName,
    bool isLogin,
    BuildContext ctx,
  ) submitFn;

  // Constructor
  AuthForm(
    this.submitFn,
    this.isLoading,
  );

  @override
  _AuthFormState createState() => _AuthFormState();
}

//////////////////////////////////////////////////////////////////
// THe actual STATE which is managed by the above widget.
//////////////////////////////////////////////////////////////////
class _AuthFormState extends State<AuthForm> {
  // The "instance variables" managed in this state
  var _isLogin = true;
  var _userEmail = '';
  var _firstName = '';
  var _lastName = '';
  var _userPassword = '';

  // Finals used in this widget
  final _formKey = GlobalKey<FormState>();

  ////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////
  /// Helper Methods (for state object)
  ////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////
  // Does basic validation and attempts to authenticate using the
  // method called in from the parent screen/widget.
  ////////////////////////////////////////////////////////////////
  void _trySubmit() {
    // Unfocus from any controls that may have focus to disengage the keyboard
    FocusScope.of(context).unfocus();

    // If the form validates, save the data and then execute the callback function,
    // which attempts to either login to existing account or signup for new account.
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
      widget.submitFn(
        _userEmail.trim(),
        _userPassword.trim(),
        _firstName.trim(),
        _lastName.trim(),
        _isLogin,
        context,
      );
    }
  }

  ////////////////////////////////////////////////////////////////
  // Primary Flutter method overriden which describes the layout
  // and bindings for this widget.
  ////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        margin: EdgeInsets.all(20),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  key: ValueKey('email'),
                  autocorrect: false,
                  textCapitalization: TextCapitalization.none,
                  enableSuggestions: false,
                  validator: (value) {
                    if (value!.isEmpty || !value.contains('@')) {
                      return 'Please enter a valid email address.';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email address',
                  ),
                  onSaved: (value) {
                    _userEmail = value!;
                  },
                ),
                if (!_isLogin)
                  TextFormField(
                    key: ValueKey('firstname'),
                    autocorrect: true,
                    textCapitalization: TextCapitalization.words,
                    enableSuggestions: false,
                    validator: (value) {
                      if (value!.isEmpty || value.length < 2) {
                        return 'Please enter at least 2 characters';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'First Name',
                    ),
                    onSaved: (value) {
                      _firstName = value!;
                    },
                  ),
                if (!_isLogin)
                  TextFormField(
                    key: ValueKey('lastname'),
                    autocorrect: true,
                    textCapitalization: TextCapitalization.words,
                    enableSuggestions: false,
                    validator: (value) {
                      if (value!.isEmpty || value.length < 2) {
                        return 'Please enter at least 2 characters';
                      }
                      return null;
                    },
                    decoration: InputDecoration(labelText: 'Last Name'),
                    onSaved: (value) {
                      _lastName = value!;
                    },
                  ),
                TextFormField(
                  key: ValueKey('password'),
                  validator: (value) {
                    if (value!.isEmpty || value.length < 7) {
                      return 'Password must be at least 7 characters long.';
                    }
                    return null;
                  },
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  onSaved: (value) {
                    _userPassword = value!;
                  },
                ),
                SizedBox(height: 12),
                if (widget.isLoading) CircularProgressIndicator(),
                if (!widget.isLoading)
                  ElevatedButton(
                    child: Text(_isLogin ? 'Login' : 'Signup'),
                    onPressed: _trySubmit,
                  ),
                if (!widget.isLoading)
                  TextButton(
                    style: TextButton.styleFrom(
                        primary: Theme.of(context).primaryColor),
                    child: Text(_isLogin
                        ? 'Create new account'
                        : 'I already have an account'),
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    },
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
