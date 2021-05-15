import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gather_app/constants.dart';
import 'package:gather_app/model/user.dart';
import 'package:gather_app/services/authenticate.dart';
import 'package:gather_app/services/helper.dart';
import 'package:gather_app/ui/auth/authScreen.dart';
import 'package:gather_app/ui/home/homeScreen.dart';
import 'package:gather_app/ui/login/loginScreen.dart';
import 'package:gather_app/ui/onBoarding/onBoardingScreen.dart';
import 'package:gather_app/ui/signUp/signUpScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  static User currentUser;
  StreamSubscription tokenStream;

  // Set default `_initialized` and `_error` state to false
  bool _initialized = false;
  bool _error = false;

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
        print("is initialized");
        print(_initialized);
      });
    } catch (e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show error message if initialization failed
    if (_error) {
      return MaterialApp(
          home: Scaffold(
        body: Container(
          color: Colors.white,
          child: Center(
              child: Column(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 25,
              ),
              SizedBox(height: 16),
              Text(
                'Failed to initialise firebase!',
                style: TextStyle(color: Colors.red, fontSize: 25),
              ),
            ],
          )),
        ),
      ));
    }

    // Show a loader until FlutterFire is initialized
    if (!_initialized) {
      return Container(
        color: Colors.white,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return MaterialApp(
        theme: ThemeData(accentColor: Color(COLOR_PRIMARY)),
        debugShowCheckedModeBanner: false,
        color: Color(COLOR_PRIMARY),
        home: OnBoarding());
  }

  @override
  void initState() {
    initializeFlutterFire();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (auth.FirebaseAuth.instance.currentUser != null && currentUser != null) {
      if (state == AppLifecycleState.paused) {
        //user offline
        tokenStream.pause();
        currentUser.active = false;
        currentUser.lastOnlineTimestamp = Timestamp.now();
        FireStoreUtils.updateCurrentUser(currentUser);
      } else if (state == AppLifecycleState.resumed) {
        //user online
        tokenStream.resume();
        currentUser.active = true;
        FireStoreUtils.updateCurrentUser(currentUser);
      }
    }
  }
}

class OnBoarding extends StatefulWidget {
  @override
  State createState() {
    return OnBoardingState();
  }
}

class OnBoardingState extends State<OnBoarding> {
  Future hasFinishedOnBoarding() async {
    // pushReplacement(context, new AuthScreen());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool finishedOnBoarding = (prefs.getBool(FINISHED_ON_BOARDING) ?? false);

    //removed finishedOnBoarding details, because we dont want the original onboarding screen
    // if (finishedOnBoarding) {
    //   auth.User firebaseUser = auth.FirebaseAuth.instance.currentUser;
    //   if (firebaseUser != null) {
    //     User user = await FireStoreUtils().getCurrentUser(firebaseUser.uid);
    //     if (user != null) {
    //       MyAppState.currentUser = user;
    //       pushReplacement(context, new HomeScreen(user: user));
    //     } else {
    //       pushReplacement(context, new AuthScreen());
    //     }
    //   } else {
    //     pushReplacement(context, new AuthScreen());
    //   }
    // } else {
    //   pushReplacement(context, new OnBoardingScreen());
    // }

    auth.User firebaseUser = auth.FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      User user = await FireStoreUtils().getCurrentUser(firebaseUser.uid);
      if (user != null) {
        MyAppState.currentUser = user;
        pushReplacement(context, new HomeScreen(user: user));
      } else {
        pushReplacement(context, new AuthScreen());
      }
    } else {
      pushReplacement(context, new AuthScreen());
    }
  }

  @override
  void initState() {
    super.initState();
    hasFinishedOnBoarding();
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: Color(COLOR_PRIMARY),
  //     body: Center(
  //       child: CircularProgressIndicator(
  //         backgroundColor: Colors.black,
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Icon(
              Icons.phone_iphone,
              size: 150,
              color: Color(COLOR_PRIMARY),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 16, top: 32, right: 16, bottom: 8),
            child: Text(
              'Say Hello To Your New App!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(COLOR_PRIMARY),
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            child: Text(
              'You\'ve just saved a week of development and headaches.',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: double.infinity),
              child: RaisedButton(
                color: Color(COLOR_PRIMARY),
                child: Text(
                  'Log In',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                textColor: Colors.white,
                splashColor: Color(COLOR_PRIMARY),
                onPressed: () => push(context, new LoginScreen()),
                padding: EdgeInsets.only(top: 12, bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    side: BorderSide(color: Color(COLOR_PRIMARY))),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                right: 40.0, left: 40.0, top: 20, bottom: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: double.infinity),
              child: FlatButton(
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(COLOR_PRIMARY)),
                ),
                onPressed: () => push(context, new SignUpScreen()),
                padding: EdgeInsets.only(top: 12, bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    side: BorderSide(color: Color(COLOR_PRIMARY))),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:place_picker/place_picker.dart';
//
// class PickerDemo extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() => PickerDemoState();
// }
//
// class PickerDemoState extends State<PickerDemo> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Picker Example')),
//       body: Center(
//         child: FlatButton(
//           child: Text("Pick Delivery location"),
//           onPressed: () {
//             showPlacePicker();
//           },
//         ),
//       ),
//     );
//   }
//
//   void showPlacePicker() async {
//     LocationResult result = await Navigator.of(context).push(
//         MaterialPageRoute(builder: (context) => PlacePicker("YOUR API KEY")));
//
//     // Handle the result in your way
//     print(result);
//   }
// }