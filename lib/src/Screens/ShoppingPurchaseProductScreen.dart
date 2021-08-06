import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yourcourt/src/Utiles/cabeceras.dart';
import 'package:yourcourt/src/Utiles/menu.dart';
import 'package:yourcourt/src/Utiles/principal_structure.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yourcourt/src/models/Product.dart';
import 'package:http/http.dart' as http;
import 'package:yourcourt/src/models/dto/ProductPurchaseLineDto.dart';
import 'login/LoginPage.dart';
import 'dart:convert';
import 'package:gson/gson.dart';

class ShoppingPurchaseProducts extends StatefulWidget {

  @override
  _ShoppingPurchaseProductsState createState() => _ShoppingPurchaseProductsState();
}

class _ShoppingPurchaseProductsState extends State<ShoppingPurchaseProducts> {

  SharedPreferences sharedPreferences;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if(sharedPreferences.getString("token") == null) {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => LoginPage()), (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Principal(context, sharedPreferences, appHeadboard(context, sharedPreferences), body(), MenuLateral());
  }

  Widget body(){
    return FutureBuilder(
        future: getProduct(1),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return GridView.count(
              crossAxisCount: 2,
              children: [
                Container(),
              ]
            );
          } else {
            return Container(
              child: Text("No hay ninguna reserva realizada"),
            );
          }
        }
    );
  }

  Future<List<ProductPurchaseLineDto>> getProductsPurchaseLines() async {
    sharedPreferences = await SharedPreferences.getInstance();
    List<ProductPurchaseLineDto> productsPurchaseLines = Gson().decode(sharedPreferences.getString("carrito"));


  }

  Future<Product> getProduct(int id) async {
    Product p;
    var jsonResponse;
    var response = await http.get("url");

    if(response.statusCode==200){
      jsonResponse = json.decode(response.body);
      p = Product.fromJson(jsonResponse);
    } else{
      print("Se ha producido un error" + response.statusCode.toString());
    }

    return p;
  }



}
