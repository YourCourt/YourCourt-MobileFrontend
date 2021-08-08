import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:yourcourt/src/Screens/login/LoginPage.dart';
import 'package:yourcourt/src/Utiles/cabeceras.dart';
import 'package:yourcourt/src/Utiles/menu.dart';
import 'package:yourcourt/src/Utiles/principal_structure.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yourcourt/src/models/Court.dart';
import 'package:yourcourt/src/models/BookingDate.dart';
import 'package:yourcourt/src/models/Product.dart';
import 'package:http/http.dart' as http;
import 'package:yourcourt/src/models/ProductBookingLine.dart';

import 'BookConfirmationScreen.dart';

class ProductBooking extends StatefulWidget {

  final String date;
  final BookDate hour;
  final Court court;

  const ProductBooking({Key key, this.date, this.hour, this.court}) : super(key: key);

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
  int _stockLimit = 20;
  List<ProductBookingLine> productsBooking = [];
  int _productCounter = 0;
  String _productType = "Raqueta";

  Widget body() {
    return FutureBuilder(
      future: getProductTypes(),
      builder: (context, snapshot) {
        if (snapshot.hasData){
          return Column(
              children: [
                Expanded(
                  child: DropdownButtonFormField(
                    onChanged: (dynamic value) {
                      setState(() {
                        _productType = value;
                        _productCounter = 0;
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
                ),
                Expanded(
                  flex: 4,
                    child: showProducts(_productType),
                )
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
              return GridView.count(
                    crossAxisCount: 2,
                    children: [
                      showBookableProducts(snapshot.data),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => BookConfirmation(date: widget.date, court: widget.court, hour: widget.hour, productsBooking: productsBooking,)));
                          },
                          child: Text("Confirmar", style: TextStyle(color: Colors.white),)
                      )
                    ]
                );
            } else {
              return Container(child: Text("No hay productos alquilables"),);
            }
          });
    }

    return Container();
  }

  Widget showBookableProducts(List<Product> products) {

    Widget showProduct = ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: products.length,
        itemBuilder: (BuildContext context, int index){
          return Column(
              children: [
                Image(
                  fit: BoxFit.fitHeight,
                     image: NetworkImage(products.elementAt(index).image.imageUrl),),
                Text(products.elementAt(index).name, style: TextStyle(color: Colors.black),),
                Text(products.elementAt(index).description, style: TextStyle(color: Colors.black),),
                Text(products.elementAt(index).bookPrice.toString(), style: TextStyle(color: Colors.black),),
                Text(products.elementAt(index).productType, style: TextStyle(color: Colors.black),),
                Text(products.elementAt(index).stock.toString(), style: TextStyle(color: Colors.black),),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _productCounter != 0 ? new
                    IconButton(
                      icon: new Icon(Icons.remove),
                      onPressed: () {
                        setState(() {
                          _productCounter--;
                        });
                      },
                    )
                        : new Container(),
                    new Text(_productCounter.toString()),
                    products
                        .elementAt(index)
                        .stock - _productCounter > _stockLimit ?
                    new
                    IconButton(
                        icon: new Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            _productCounter++;
                          });
                        }
                    ) : new Container(),
                  ],
                ),
                ElevatedButton(
                    onPressed: _productCounter==0 ? null : () {
                          showDialog(
                              context: context,
                              builder: (context){
                                return AlertDialog(
                                  content: Text("Desea añadir " + _productCounter.toString() + " " + products.elementAt(index).name+""),
                                  actions: [
                                    ElevatedButton(
                                        onPressed: () {
                                          productsBooking.add(ProductBookingLine(discount: 0,productId:products.elementAt(index).id, quantity: _productCounter ));
                                          Navigator.pop(context);
                                          _productCounter=0;
                                        },
                                        child: Text("Si")
                                    ),
                                    ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text("No")
                                    ),
                                  ],
                                );
                              }
                          );
                    },
                    child: Text("Añadir", style: TextStyle(color: Colors.black),)
                ),
              ],
            );
        }
    );

    return showProduct;
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
