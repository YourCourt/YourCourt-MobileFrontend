import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yourcourt/src/Screens/ScreensToUpdate/ShowBookableProducts.dart';
import 'package:yourcourt/src/Utiles/cabeceras.dart';
import 'package:yourcourt/src/Utiles/principal_structure.dart';
import 'package:yourcourt/src/Utiles/menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yourcourt/src/models/BookingDate.dart';
import 'package:yourcourt/src/models/Court.dart';
import 'package:http/http.dart' as http;

import 'LoginPage.dart';


class BookConfirmation extends StatefulWidget {
  final String date;
  final BookDate hour;
  final Court court;

  const BookConfirmation({Key key, this.date, this.hour, this.court}) : super(key: key);

  @override
  _BookConfirmationState createState() => _BookConfirmationState();
}

class _BookConfirmationState extends State<BookConfirmation> {

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

  Widget show = Container(
    child: Text("Prueba ")
  );
  bool _search = false;

  Widget body() {
    return Column(
      children: [
        Text(widget.date, style: TextStyle(color: Colors.black),),
        Text(widget.hour.startHour + " -> " + widget.hour.endHour,
          style: TextStyle(color: Colors.black),),
        ElevatedButton(
          onPressed: (){
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Alquilar productos", style: TextStyle(color: Colors.black),),
                    content: Container(
                      width: double.maxFinite,
                      child: FutureBuilder(
                        future: getProductTypes(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData){
                            return Column(
                                children: [
                                  DropdownButtonFormField(
                                    onChanged: (dynamic value) {
                                      setState(() {
                                        _productType = value;
                                        show = ShowBookableProducts(productType: _productType,);
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
                                  show,
                                ]
                            );
                          } else{
                            return Container(
                              child: Text("No se encuentra disponible esta operación", style: TextStyle(color: Colors.black),),
                            );
                          }
                        },
                      ),
                    ),
                    actions: [
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Cerrar", style: TextStyle(color: Colors.black),)),

                    ],
                  );
                }
            );
          },
          child: Text("Alquilar productos", style: TextStyle(color: Colors.black),),
        ),
        ElevatedButton(
            onPressed: () {
              confirmBook();
              },
            child: Text(
              "Confirmar reserva", style: TextStyle(color: Colors.black),)),
      ],
    );
  }

  getUserId(String username) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int userId;

    var jsonResponse;
    var response = await http.get(
        "https://dev-yourcourt-api.herokuapp.com/users/username/"+username,
        headers: {
          "Accept": "application/json",
          "Content-type": "application/json"
        });

    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
    }

    userId = jsonResponse["id"];
    sharedPreferences.setInt("id", userId);

    return userId;

  }

  confirmBook() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String username = sharedPreferences.getString("username");
    getUserId(username);

    Map data = {
      "court": widget.court.id,
      "endDate": widget.date + "T" + widget.hour.endHour,
      "lines": [
      ],
      "startDate": widget.date + "T" + widget.hour.startHour,
      "user": sharedPreferences.getInt("id"),
    };

    var response = await http.post(
        "https://dev-yourcourt-api.herokuapp.com/bookings",
        body: json.encode(data),
        headers: {
          "Accept": "application/json",
          "Content-type": "application/json"
        });

    print(response.statusCode);

    if (response.statusCode == 201) {
      print("Reserva creada");
    }


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

  List<DropdownMenuItem<String>> dropMenuItems(List<String> data) {
    List<DropdownMenuItem<String>> dropMenuItems = [];
    for (var item in data) {
      dropMenuItems.add(DropdownMenuItem(
          value: item,
          child: Text(item, style: TextStyle(color: Colors.black),)
      ));
    }
    return dropMenuItems;
  }

  // Future<List<Product>> getBookableProduct(String type) async {
  //   List<Product> products = [];
  //   var jsonResponse;
  //
  //   var response = await http.get("https://dev-yourcourt-api.herokuapp.com/products/bookableProductsByType?typeName="+type);
  //   if (response.statusCode==200){
  //     jsonResponse = json.decode(response.body);
  //     for (var item in jsonResponse) {
  //       products.add(Product.fromJson(item));
  //     }
  //   }
  //   return products;
  //
  // }
  //
  // // Widget showBookableProducts(Product product) {
  // //   return new Image(
  // //     image: NetworkImage(product.image.imageUrl),);
  // // }
  //
  // List<Widget> showBookableProducts(List<Product> products) {
  //   List<Widget> showList = [];
  //
  //   if(products!=null){
  //     for (var product in products) {
  //       showList.add(ListView(
  //         children: [
  //           Image(
  //             image: NetworkImage(product.image.imageUrl),),
  //           Text(product.name),
  //           Text(product.description),
  //           Text(product.bookPrice.toString()),
  //           Text(product.productType),
  //           Text(product.stock.toString()),
  //         ],
  //       ));
  //     }
  //   } else{
  //     showList.add(Container(child: Text("No existen productos alquilables de este tipo"),));
  //   }
  //
  //   return showList;
  // }
}
