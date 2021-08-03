import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yourcourt/src/models/Product.dart';
import 'package:http/http.dart' as http;

class ShowBookableProducts extends StatefulWidget {

  final productType;

  const ShowBookableProducts({Key key, this.productType}) : super(key: key);

  @override
  _ShowBookableProductsState createState() => _ShowBookableProductsState();
}

class _ShowBookableProductsState extends State<ShowBookableProducts> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
          future: getBookableProduct(widget.productType),
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
          }),
    );
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

  // Widget showBookableProducts(Product product) {
  //   return new Image(
  //     image: NetworkImage(product.image.imageUrl),);
  // }

  List<Widget> showBookableProducts(List<Product> products) {
    List<Widget> showList = [];

    if(products!=null){
      for (var product in products) {
        showList.add(ListView(
          children: [
            Image(
              image: NetworkImage(product.image.imageUrl),),
            Text(product.name, style: TextStyle(color: Colors.black),),
            Text(product.description, style: TextStyle(color: Colors.black),),
            Text(product.bookPrice.toString(), style: TextStyle(color: Colors.black),),
            Text(product.productType, style: TextStyle(color: Colors.black),),
            Text(product.stock.toString(), style: TextStyle(color: Colors.black),),
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

}
