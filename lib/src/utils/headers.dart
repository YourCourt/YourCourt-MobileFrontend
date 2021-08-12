import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:yourcourt/main.dart';
import 'package:yourcourt/src/screens/ShoppingPurchaseProductScreen.dart';
import 'package:yourcourt/src/screens/login/LoginPage.dart';
import 'package:yourcourt/src/screens/PerfilScreen.dart';

import '../vars.dart';

Widget appHeadboard(BuildContext context, SharedPreferences sharedPreferences) {
  return AppBar(
    backgroundColor: Color(0xFFDBA58F),
    title: TextButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => MainPage()));
      },
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image(
              width: 40.0,
              height: 25.0,
              image: AssetImage('assets/yourcourt_logo.png'),
            ),
          ),
          Text("YourCourt", style: TextStyle(color: Colors.white, fontSize: 20.0)),
        ],
      ),
    ),
    actions: <Widget>[
      TextButton(
        onPressed: () {
          if(sharedPreferences!=null){
            sharedPreferences.clear();
          }
          productPurchaseLines = [];
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => LoginPage()), (Route<dynamic> route) => false);
        },
        child: Text("Salir", style: TextStyle(color: Colors.white)),
      ),
      TextButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => MyProfile()));
        },
        child: Text("Mi perfil", style: TextStyle(color: Colors.white)),
      ),
      GestureDetector(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Icon(
              Icons.shopping_cart_rounded,
              size: 24.0,
            ),
            if (productPurchaseLines.length > 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: CircleAvatar(
                  radius: 6.0,
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  child: Text(
                    productPurchaseLines.length.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 9.0,
                    ),
                  ),
                ),
              ),
          ],
        ),
        onTap: () {
          if (productPurchaseLines.isNotEmpty)
            Navigator.of(context).push(
              MaterialPageRoute(builder: (BuildContext context) => ShoppingPurchaseProducts(),),
            );
        },
      ),
    ],
  );
}