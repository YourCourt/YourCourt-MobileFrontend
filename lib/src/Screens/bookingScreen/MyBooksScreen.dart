import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:yourcourt/src/Utiles/cabeceras.dart';
import 'package:yourcourt/src/Utiles/menu.dart';
import 'package:yourcourt/src/Utiles/principal_structure.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:yourcourt/src/models/Book.dart';
import 'package:yourcourt/src/models/Product.dart';
import 'package:yourcourt/src/models/ProductBookingLine.dart';
import 'package:yourcourt/src/utiles/functions.dart';

import '../login/LoginPage.dart';

class MyBooks extends StatefulWidget {

  @override
  _MyBooksState createState() => _MyBooksState();
}

class _MyBooksState extends State<MyBooks> {

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
    return FutureBuilder <List<Book>>(
        future: getBooks(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return GridView.count(
              crossAxisCount: 2,
              children: [
                listBooks(snapshot.data),
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

  Future<List<Book>> getBooks() async {
    sharedPreferences = await SharedPreferences.getInstance();

    List<Book> books = [];

    var token = sharedPreferences.getString("token");

    var jsonResponse;
    var response = await http.get(
        "https://dev-yourcourt-api.herokuapp.com/bookings/user?username="+sharedPreferences.getString("username"),
    headers: {"Authorization": "Bearer ${token}"},);

    if (response.statusCode == 200) {
      jsonResponse = transformUtf8(response.bodyBytes);

      for (var item in jsonResponse) {

        books.add(Book.fromJson(item));
      }
    } else {
      print(response.statusCode);
      print("Se ha producido un error: " + response.body);
    }

    return books;
  }

  Widget listBooks(List<Book> books){

    if(books.length>0){
      return ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: books.length,
          itemBuilder: (BuildContext context, int index) {
              return Container(
                child: Column(
                  children: [
                    Text("Empieza: " + books.elementAt(index).startDate, style: TextStyle(color: Colors.black),),
                    Text("Termina: " + books.elementAt(index).endDate, style: TextStyle(color: Colors.black),),
                    Text("Productos incluidos: ", style: TextStyle(color: Colors.black),),
                    listProducts(books.elementAt(index).productBooking.lines),
                    Text("Total de la reserva: " + books.elementAt(index).productBookingSum.toString(), style: TextStyle(color: Colors.black),),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: DateTime.now().isAfter(DateTime.parse(books.elementAt(index).startDate)) ? null : () {
                            if(sharedPreferences.getInt("id") != books.elementAt(index).userId || sharedPreferences.getStringList("roles").contains("ROLE_ADMIN")==true) {
                              showDialog(
                                  context: context,
                                  builder: (context){
                                    return AlertDialog(
                                      content: Text("¿Desea cancelar la reserva?"),
                                      actions: [
                                        ElevatedButton(
                                            onPressed: () async {
                                              deleteBook(books.elementAt(index));
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
                                  });
                            } else {
                              print(
                                  "No puede cancelar una reserva que no le pertenece");
                            }

                          },
                          child: Text("Cancelar reserva", style: TextStyle(color: Colors.white),),
                        ),
                      ],
                    ),
                  ],
                ),
              );
          }
      );
    }
    else{
      return Container(
          child: Text("No hay ninguna transacción realizada")
      );
    }

  }

  Widget listProducts(List<ProductBookingLine> products) {
    ScrollController _controller = new ScrollController();

    if (products.length > 0) {
      return ListView.builder(
          controller: _controller,
          shrinkWrap: true,
          itemCount: products.length,
          itemBuilder: (BuildContext context, int index) {
            return FutureBuilder(
                future: getProduct(products.elementAt(index).productId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Column(
                      children: [
                        Image(
                          fit: BoxFit.fitHeight,
                          image: NetworkImage(snapshot.data.image.imageUrl),
                        ),
                        Text(
                          snapshot.data.name,
                          style: TextStyle(color: Colors.black),
                        ),
                        Text(
                          snapshot.data.description,
                          style: TextStyle(color: Colors.black),
                        ),
                        Text(
                          snapshot.data.price.toString(),
                          style: TextStyle(color: Colors.black),
                        ),
                        Text(
                          snapshot.data.productType,
                          style: TextStyle(color: Colors.black),
                        ),
                        Text(
                          snapshot.data.stock.toString(),
                          style: TextStyle(color: Colors.black),
                        ),
                        Text(
                          products.elementAt(index).quantity.toString(),
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    );
                  }
                  return CircularProgressIndicator();
                });
          }
      );
    } else {
      return SizedBox(height: 5,);
    }
  }

  deleteBook(Book book) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    var token = sharedPreferences.getString("token");
    var response = await http.delete(
        "https://dev-yourcourt-api.herokuapp.com/bookings/" +
            book.id.toString(),
        headers: {"Authorization": "Bearer $token"});

    if (response.statusCode == 200) {
      setState(() {
        print("Se ha cancelado la reserva con éxito");
        Navigator.pop(context);
      });
    } else{
      print("Ha ocurrido un error: "+ response.body);
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
}
