import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yourcourt/src/Screens/login/LoginPage.dart';
import 'package:yourcourt/src/Utiles/cabeceras.dart';
import 'package:yourcourt/src/Utiles/menu.dart';
import 'package:yourcourt/src/Utiles/principal_structure.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yourcourt/src/models/product/Product.dart';
import 'package:http/http.dart' as http;

class ProductBooking extends StatefulWidget {

  @override
  _ProductBookingState createState() => _ProductBookingState();
}

class _ProductBookingState extends State<ProductBooking> {
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

  String _productType = "Textil";

  Widget body() {
    return FutureBuilder(
      future: getProductTypes(),
      builder: (context, snapshot) {
        if (snapshot.hasData){
          return Column(
              children: [
                DropdownButtonFormField(
                  onChanged: (dynamic value) {
                    setState(() {
                      _productType = value;
                    });
                  },
                  value: _productType,
                  hint: Text("Elige un tipo de producto",),
                  items: snapshot.data.map<DropdownMenuItem<String>>((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: new Text(item),
                    );
                  }).toList(),
                ),
                showProducts(_productType),
              ]
          );
        }
        return Container(
          child: Text("No se encuentra disponible esta operación", style: TextStyle(color: Colors.black),),
          );
      },
    );
  }

  Widget showProducts(String productType){
    if(productType!=null){
      return FutureBuilder(
          future: getBookableProduct(productType),
          builder: (context, snapshot){
            if(snapshot.hasData){
              return Expanded(
                child: GridView.count(
                    crossAxisCount: 2,
                    children: showBookableProducts(snapshot.data)
                ),
              );
            } else {
              return Container(child: Text("No hay productos alquilables"),);
            }
          });
    }

    return Container();
  }

  int _counterProduct = 0;
  List<Widget> showBookableProducts(List<Product> products) {
    List<Widget> showList = [];
    
    if(products!=null){
      for (var product in products) {
        showList.add(
            ListView(
              children: [
                // Image(
                //   image: NetworkImage(product.image.imageUrl),),
                Text(product.name, style: TextStyle(color: Colors.black),),
                Text(product.description, style: TextStyle(color: Colors.black),),
                Text(product.bookPrice.toString(), style: TextStyle(color: Colors.black),),
                Text(product.productType, style: TextStyle(color: Colors.black),),
                Text(product.stock.toString(), style: TextStyle(color: Colors.black),),
                // Row(
                //   children: [
                //     TextFormField(
                //       initialValue: _counterProduct.toString(),
                //       keyboardType: TextInputType.number,
                //       readOnly: true,
                //     ),
                //     FloatingActionButton(
                //         child: Icon(Icons.add),
                //         onPressed: () {
                //           _counterProduct++;
                //         }
                //         ),
                //   ],
                // ),
                ElevatedButton(
                    onPressed: () {

                    },
                    child: Text("Añadir", style: TextStyle(color: Colors.black),)
                ),
              ],
            ));
      }
    } else{
      showList.add(Container(child: Text("No existen productos alquilables de este tipo", style: TextStyle(color: Colors.black),),));
    }

    return showList;
  }

  Future<List<Product>> getBookableProduct(String type) async {
    List<Product> products = [];
    var jsonResponse;

    var response = await http.get("https://dev-yourcourt-api.herokuapp.com/products/bookableProductsByType?typeName="+type);
    if (response.statusCode==200){
      jsonResponse = json.decode(response.body);
      for (var item in jsonResponse) {
        products.add(Product.fromJson(item));
      }
    }
    return products;

  }

  Future<List<String>> getProductTypes() async {
    List<String> productTypes = [];
    var jsonResponse;

    var response = await http.get("https://dev-yourcourt-api.herokuapp.com/products/productTypes");
    if (response.statusCode==200){
      jsonResponse = json.decode(response.body);
    }
    for (var item in jsonResponse) {
      productTypes.add(item["typeName"]);
    }
    return productTypes;
  }




}
