
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yourcourt/src/utils/menu.dart';
import 'package:yourcourt/src/utils/principal_structure.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yourcourt/src/models/Product.dart';
import 'package:yourcourt/src/models/ProductPurchase.dart';
import 'package:yourcourt/src/utils/functions.dart';
import 'package:yourcourt/src/utils/headers.dart';

import 'login/LoginPage.dart';

class ProductTransactions extends StatefulWidget {

  @override
  _ProductTransactionsState createState() => _ProductTransactionsState();
}

class _ProductTransactionsState extends State<ProductTransactions> {

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
    return FutureBuilder(
        future: getTransactions(),
        builder: (context, snapshot){
          if (snapshot.hasData) {
            return Column(
              children: [
                Expanded(
                    child: showTransactions(snapshot.data),
                ),

              ]
            );
          } else {
            return Center(
              child: Container(
                child: Text("No hay transacciones"),
              ),
            );
          }
        }
    );
  }

  Widget showTransactions(List<ProductPurchase> purchasedProducts){

    ScrollController _controller = new ScrollController();

    if(purchasedProducts.length>0){
      return ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: purchasedProducts.length,
          itemBuilder: (BuildContext context, int index) {
            if(purchasedProducts.elementAt(index).lines.length>0){
              return Container(
                child: Column(
                  children: [
                    SizedBox(height: 10,),
                    Text("Transacción número " + (index+1).toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400),),
                    SizedBox(height: 10,),
                    ListView.builder(
                      controller: _controller,
                        shrinkWrap: true,
                        itemCount: purchasedProducts.elementAt(index).lines.length,
                        itemBuilder: (BuildContext context, int index) {
                          return FutureBuilder(
                              future: getProduct(purchasedProducts.elementAt(index).lines.elementAt(index).productId),
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
                                            snapshot.data.tax.toString() + " €",
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
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w300),
                                      ),
                                        SizedBox(height: 5,),
                                        Text("Cantidad: " + purchasedProducts.elementAt(index).lines.elementAt(index).quantity.toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300),),
                                      ],
                                    );
                                }
                                return Container();
                              }
                          );
                        }
                    ),
                    Text("Total de la compra: " + purchasedProducts.elementAt(index).productPurchaseSum.toString(), style: TextStyle(color: Colors.black),),
                    SizedBox(height: 15,),
                  ],
                ),
              );
            } else {
              return Container();
            }

          }
      );
    }
    else{
      return Center(
        child: Container(
            child: Text("No hay ninguna transacción realizada")
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

  Future<List<ProductPurchase>> getTransactions() async {
    sharedPreferences = await SharedPreferences.getInstance();

    List<ProductPurchase> purchasedProducts = [];

    var token = sharedPreferences.getString("token");
    var jsonResponse;
    var response = await http.get(
        "https://dev-yourcourt-api.herokuapp.com/purchases/user?username="+sharedPreferences.getString("username"),
    headers: {"Authorization": "Bearer $token"},);

    if (response.statusCode == 200) {
      jsonResponse = transformUtf8(response.bodyBytes);

      for (var item in jsonResponse) {

        purchasedProducts.add(ProductPurchase.fromJson(item));
      }
    } else{
      print("Se ha producido un error " + response.statusCode.toString());
    }

    return purchasedProducts;
  }


}
