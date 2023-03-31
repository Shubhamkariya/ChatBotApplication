import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled1/Pages/Account/Login.dart';
import 'package:untitled1/Pages/Chat/MyUserList.dart';

class CheckAuth extends StatefulWidget {
  @override
  _CheckAuthState createState() => _CheckAuthState();
}

class _CheckAuthState extends State<CheckAuth> {
  bool isAuth = false;
  @override
  void initState() {
    super.initState();
    _checkIfLoggedIn();
  }

  void _checkIfLoggedIn() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        print(user.uid);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('UID', user.uid);
        // print('${prefs.getKeys()}');
        // print('Shared pref process ends');
        isAuth = true;
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) => MyUserList()));
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) => Login()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
