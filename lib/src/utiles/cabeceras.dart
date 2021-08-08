import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:yourcourt/src/Screens/ShoppingPurchaseProductScreen.dart';
import 'package:yourcourt/src/Screens/login/LoginPage.dart';
import 'package:yourcourt/src/Screens/PerfilScreen.dart';

import '../vars.dart';

Widget appHeadboard(BuildContext context, SharedPreferences sharedPreferences) {
  return AppBar(
    title: Text("YourCourt", style: TextStyle(color: Colors.white)),
    actions: <Widget>[
      TextButton(
        onPressed: () {
          if(sharedPreferences!=null){
            sharedPreferences.clear();
          }
          productPurchaseLines = [];
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => LoginPage()), (Route<dynamic> route) => false);
        },
        child: Text("Log Out", style: TextStyle(color: Colors.white)),
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
                padding: const EdgeInsets.only(left: 2.0),
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