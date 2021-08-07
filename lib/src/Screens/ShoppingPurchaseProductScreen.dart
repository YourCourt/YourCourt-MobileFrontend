import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yourcourt/src/Utiles/cabeceras.dart';
import 'package:yourcourt/src/Utiles/menu.dart';
import 'package:yourcourt/src/Utiles/principal_structure.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yourcourt/src/models/Product.dart';
import 'package:http/http.dart' as http;
import 'package:yourcourt/src/models/dto/ProductPurchaseLineDto.dart';
import 'package:yourcourt/src/vars.dart';
import 'login/LoginPage.dart';
import 'dart:convert';

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
    return GridView.count(
        crossAxisCount: 2,
        children: [
          showProductLines(productPurchaseLines),
        ]
    );
  }

  Future<Product> getProduct(int id) async {
    Product p;
    var jsonResponse;
    var response = await http.get("https://dev-yourcourt-api.herokuapp.com/products/"+id.toString());

    if(response.statusCode==200){
      jsonResponse = json.decode(response.body);
      p = Product.fromJson(jsonResponse);
    } else{
      print("Se ha producido un error" + response.statusCode.toString());
    }

    return p;
  }

  Widget showProductLines(List<ProductPurchaseLineDto> productLines){
    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: productLines.length,
        itemBuilder: (BuildContext context, int index) {
          return FutureBuilder(
            future: getProduct(productLines.elementAt(index).productId),
            builder: (context, snapshot){
              if(snapshot.connectionState==ConnectionState.done){
                return Column(
                  children: [
                    Image(
                      fit: BoxFit.fitHeight,
                      image: NetworkImage(snapshot.data.image.imageUrl),),
                    Text(snapshot.data
                        .name, style: TextStyle(color: Colors.black),),
                    Text(snapshot.data
                        .description, style: TextStyle(color: Colors.black),),
                    Text(snapshot.data
                        .price.toString(), style: TextStyle(color: Colors.black),),
                    Text(snapshot.data
                        .productType, style: TextStyle(color: Colors.black),),
                    Text(snapshot.data
                        .stock
                        .toString(), style: TextStyle(color: Colors.black),),
                    Text(productLines.elementAt(index).quantity.toString(), style: TextStyle(color: Colors.black),),
                    Row(
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: Text("¿Desea eliminar " +
                                          productLines.elementAt(index).quantity.toString() + " " + snapshot.data.name + " de la compra?"),
                                      actions: [
                                        ElevatedButton(
                                            onPressed: (){
                                              setState(() {
                                                productPurchaseLines.removeAt(index);
                                                Navigator.pop(context);
                                              });
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
                            child: Text("Eliminar del carrito"))
                      ],
                    )
                  ],
                );
              }
              return CircularProgressIndicator();
            },
          );
        }
    );
  }



}
