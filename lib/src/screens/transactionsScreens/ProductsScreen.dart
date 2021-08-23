
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yourcourt/src/screens/loginScreens/LoginPage.dart';
import 'package:yourcourt/src/utils/menu.dart';
import 'package:yourcourt/src/utils/principal_structure.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:yourcourt/src/models/Product.dart';
import 'package:yourcourt/src/models/dto/ProductPurchaseLineDto.dart';
import 'package:yourcourt/src/utils/functions.dart';
import 'package:yourcourt/src/utils/headers.dart';

import '../../vars.dart';

class Products extends StatefulWidget {

  @override
  _ProductsState createState() => _ProductsState();
}

class _ProductsState extends State<Products> {

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
    return principal(
        context, sharedPreferences, appHeadboard(context, sharedPreferences),
        body(), MenuLateral());
  }

  String _productType = "Textil";
  int _productCounter = 0;
  int _stockLimit = 20;

  Widget body() {
    return FutureBuilder(
      future: getProductTypes(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(
              children: [
                SizedBox(
                  height: 5.0,
                ),
                Text(
                  "Seleccione un tipo de producto",
                  style: TextStyle(color: Colors.black),
                  textAlign: TextAlign.left,
                ),
                Expanded(
                  child: DropdownButtonFormField(
                    onChanged: (dynamic value) {
                      setState(() {
                        _productType = value;
                        _productCounter=0;
                      });
                    },
                    value: _productType,
                    hint: Text("Elige un tipo de producto",),
                    items: snapshot.data.map<DropdownMenuItem<String>>((
                        String item) {
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
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget showProducts(String productType) {
    if (productType != null) {
      return FutureBuilder(
          future: getProductsByType(productType),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return showProductsByType(snapshot.data);
            } else {
              return Container();
            }
          });
    } else {
      return Container(child: Text("No hay productos alquilables"));
    }
  }


  Widget showProductsByType(List<Product> products) {
    if(products.length!=0){
      return ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: products.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  height: 300.0,
                  width: 300.0,
                  image: NetworkImage(products.elementAt(index).image.imageUrl),
                ),
                SizedBox(height: 5,),
                Text(
                  products.elementAt(index).name,
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 15.0),
                ),
                SizedBox(height: 5,),
                Text(
                  products.elementAt(index).description,
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300),
                ),
                SizedBox(height: 5,),
                Text("Precio: " +
                    products.elementAt(index).price.toString() + " €",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300),

                ),
                SizedBox(height: 5,),
                Text("Stock: " +
                    products.elementAt(index).stock.toString(),
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFFDBA58F),
                    ),
                    onPressed: _productCounter == 0 ? null :() {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: Text("¿Desea añadir " +
                                  _productCounter.toString() + " " + products
                                  .elementAt(index)
                                  .name + " al carrito?"),
                              actions: [
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: Color(0xFFBB856E),
                                    ),
                                    onPressed: () {
                                      productPurchaseLines.add(ProductPurchaseLineDto(productId:products
                                          .elementAt(index).id, quantity: _productCounter, discount: 0 ));
                                      setState(() {

                                        _productCounter = 0;
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
                    child: Text("Añadir", style: TextStyle(color: Colors.black),)
                ),
              ],
            );
          }
      );
    } else {
      return Container(
          child: Text("No existen productos de este tipo")
      );
    }
  }

  Future<List<String>> getProductTypes() async {
    List<String> productTypes = [];
    var jsonResponse;

    var response = await http.get(
        "https://dev-yourcourt-api.herokuapp.com/products/productTypes");
    if (response.statusCode == 200) {
      jsonResponse = transformUtf8(response.bodyBytes);
    }
    for (var item in jsonResponse) {
      productTypes.add(item["typeName"]);
    }
    return productTypes;
  }

  Future<List<Product>> getProductsByType(String type) async {
    List<Product> products = [];
    var jsonResponse;

    var response = await http.get(
        "https://dev-yourcourt-api.herokuapp.com/products/productsByType?typeName=" +
            type);
    if (response.statusCode == 200) {
      jsonResponse = transformUtf8(response.bodyBytes);
      for (var item in jsonResponse) {
        products.add(Product.fromJson(item));
      }
    }
    return products;
  }





}

