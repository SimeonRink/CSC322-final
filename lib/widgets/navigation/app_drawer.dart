// Flutter imports
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// File imports
import '../../providers/user_profile_provider.dart';
import '../../screens/landing_screen.dart';

//////////////////////////////////////////////////////////////////
// StateLESS widget which only has data that is initialized when
// widget is created (cannot update except when re-created).
//////////////////////////////////////////////////////////////////
class AppDrawer extends StatelessWidget {
  final _user = FirebaseAuth.instance.currentUser;

  ////////////////////////////////////////////////////////////////
  // Primary Flutter method overriden which describes the layout
  // and bindings for this widget.
  ////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    // Finals used in this widget
    UserProfileProvider userProfileProvider =
        Provider.of<UserProfileProvider>(context);

    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text('Hello ${_user!.email}'),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(LandingScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () {
              while (Navigator.of(context).canPop())
                Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed("/");
              FirebaseAuth.instance.signOut();
              userProfileProvider.wipe();
            },
          ),
        ],
      ),
    );
  }
}
