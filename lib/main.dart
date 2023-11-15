// Flutter imports
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

// File imports
import './screens/landing_screen.dart';
import './screens/splash_screen.dart';
import './screens/auth_screen.dart';
import 'providers/user_profile_provider.dart';

//////////////////////////////////////////////////////////////////
// MAIN entry point to start app.
//////////////////////////////////////////////////////////////////
Future<void> main() async {
  // Upon starting the app, initialize the Firebase package
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Run the app
  runApp(MyApp());
}

//////////////////////////////////////////////////////////////////
// StateLESS widget which only has data that is initialized when
// widget is created (cannot update except when re-created).
//////////////////////////////////////////////////////////////////
class MyApp extends StatelessWidget {
  ////////////////////////////////////////////////////////////////
  // Primary Flutter method overriden which describes the layout
  // and bindings for this widget.
  ////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    // The primary widget to build and return once Firebase has been initialized
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProfileProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'GameStock',
        theme: ThemeData(
          backgroundColor: Colors.blueGrey,
          primaryColor: Colors.white,
          splashColor: Colors.indigo,
          errorColor: Colors.redAccent,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.grey)
              .copyWith(secondary: Colors.black),
        ),
        home: SplashScreen(),
        routes: {
          AuthScreen.routeName: (ctx) => AuthScreen(),
          LandingScreen.routeName: (ctx) => LandingScreen(),
        },
      ),
    );
  }
}
