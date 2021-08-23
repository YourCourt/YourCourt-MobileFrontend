import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yourcourt/src/models/Product.dart';
import 'package:http/http.dart' as http;
import 'package:yourcourt/src/models/dto/ProductPurchaseDto.dart';
import 'package:yourcourt/src/models/dto/ProductPurchaseLineDto.dart';
import 'package:yourcourt/src/screens/loginScreens/LoginPage.dart';
import 'package:yourcourt/src/screens/transactionsScreens/ProductTransactionsScreen.dart';
import 'package:yourcourt/src/utils/functions.dart';
import 'package:yourcourt/src/utils/headers.dart';
import 'package:yourcourt/src/utils/menu.dart';
import 'package:yourcourt/src/utils/principal_structure.dart';
import 'package:yourcourt/src/vars.dart';
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
    return principal(context, sharedPreferences, appHeadboard(context, sharedPreferences), body(), MenuLateral());
  }

  Widget body(){
    if(productPurchaseLines.length>0){
      return Column(
          children: [
            Expanded(
              child: showProductLines(productPurchaseLines),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFFBB856E),
                    ),
                    onPressed: (){
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: Text("¿Desea finalizar la compra?"),
                              actions: [
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: Color(0xFFBB856E),
                                    ),
                                    onPressed: (){
                                      //Aquí hay que hacer la peticion de la compra
                                      confirmPurchase(productPurchaseLines);
                                      setState(() {
                                        productPurchaseLines=[];
                                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ProductTransactions()));
                                      });
                                    },
                                    child: Text("Si")
                                ),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: Color(0xFFBB856E),
                                    ),
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
                    child: Text("Confirmar compra", style: TextStyle(color: Colors.white),)
                )
              ],
            )
          ]
      );
    } else {
      return Center(
        child: Container(
          child: Text("El carrito está vacío"),
        ),
      );
    }

  }

  Future<Product> getProduct(int id) async {
    Product p;
    var jsonResponse;
    var response = await http.get("https://dev-yourcourt-api.herokuapp.com/products/"+id.toString());

    if(response.statusCode==200){
      jsonResponse = transformUtf8(response.bodyBytes);
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
          return FutureBuilder<Product>(
            future: getProduct(productLines.elementAt(index).productId),
            builder: (context, snapshot){
              if(snapshot.connectionState==ConnectionState.done){
                return Column(
                  children: [
                    Image(
                      height: 300.0,
                      width: 300.0,
                      image: NetworkImage(snapshot.data.image.imageUrl),
                    ),
                    SizedBox(height: 5,),
                    Text(
                      snapshot.data.name,
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 15.0),
                    ),
                    SizedBox(height: 5,),
                    Text(
                      snapshot.data.description,
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300),
                    ),
                    SizedBox(height: 5,),
                    Text("Precio: " +
                        snapshot.data.price.toString() + " €",
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300),
                    ),
                    SizedBox(height: 5,),
                    Text("Impuestos: " +
                        snapshot.data.tax.toString() + " %",
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300),
                    ),
                    SizedBox(height: 5,),
                    Text("Precio final: " +
                        snapshot.data.totalPrice.toString() + " €",
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300),
                    ),
                    SizedBox(height: 5,),
                    Text("Tipo de producto: " +
                        snapshot.data.productType.toString(),
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300),
                    ),
                    SizedBox(height: 5,),
                    Text("Stock: " +
                        snapshot.data.stock.toString(),
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300),
                    ),
                    Text(productLines.elementAt(index).quantity.toString(), style: TextStyle(color: Colors.black),),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xFFDBA58F),
                            ),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: Text("¿Desea eliminar " +
                                          productLines.elementAt(index).quantity.toString() + " " + snapshot.data.name + " de la compra?"),
                                      actions: [
                                        ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              primary: Color(0xFFBB856E),
                                            ),
                                            onPressed: (){
                                              setState(() {
                                                productPurchaseLines.removeAt(index);
                                                Navigator.pop(context);
                                              });
                                            },
                                            child: Text("Si")
                                        ),
                                        ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              primary: Color(0xFFBB856E),
                                            ),
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
              return Center(
                child: CircularProgressIndicator(),
              );
            },
          );
        }
    );
  }

  confirmPurchase(List<ProductPurchaseLineDto> productsToPurchase) async {

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    int userId = sharedPreferences.getInt("id");

    ProductPurchaseDto productsPurchase = ProductPurchaseDto(userId: userId, lines: productsToPurchase);
    Map data = productsPurchase.toJson();
    print(data);

    var token = sharedPreferences.getString("token");
    var response = await http.post(
        "https://dev-yourcourt-api.herokuapp.com/purchases",
        body: json.encode(data),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-type": "application/json"
        });

    if (response.statusCode == 201) {
      print("Compra realizada");
    } else{
      print(response.statusCode);
    }

  }

}
