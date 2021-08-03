import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:yourcourt/src/Screens/login/LoginPage.dart';
import 'package:yourcourt/src/Screens/PerfilScreen.dart';

Widget appHeadboard(BuildContext context, SharedPreferences sharedPreferences) {
  return AppBar(
    title: Text("YourCourt", style: TextStyle(color: Colors.white)),
    actions: <Widget>[
      TextButton(
        onPressed: () {
          sharedPreferences.clear();
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => LoginPage()), (Route<dynamic> route) => false);
        },
        child: Text("Log Out", style: TextStyle(color: Colors.white)),
      ),
      TextButton(
        onPressed: () {
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => MyProfile()), (Route<dynamic> route) => false);
        },
        child: Text("Mi perfil", style: TextStyle(color: Colors.white)),
      ),
    ],
  );
}