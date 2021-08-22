import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:yourcourt/src/models/Book.dart';
import 'package:yourcourt/src/models/Court.dart';
import 'package:yourcourt/src/models/Product.dart';
import 'package:yourcourt/src/models/ProductBooking.dart';
import 'package:yourcourt/src/models/ProductBookingLine.dart';
import 'package:yourcourt/src/utils/headers.dart';
import 'package:yourcourt/src/utils/functions.dart';
import 'package:yourcourt/src/utils/menu.dart';
import 'package:yourcourt/src/utils/principal_structure.dart';
import 'package:yourcourt/src/utils/toast_messages.dart';

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
    if (sharedPreferences.getString("token") == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
          (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return principal(context, sharedPreferences,
        appHeadboard(context, sharedPreferences), body(), MenuLateral());
  }

  Widget body() {
    return FutureBuilder<List<Book>>(
        future: getBooks(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
              child: Center(
                child: listBooks(snapshot.data),
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  Future<List<Book>> getBooks() async {
    sharedPreferences = await SharedPreferences.getInstance();

    List<Book> books = [];

    var token = sharedPreferences.getString("token");

    var jsonResponse;
    var response = await http.get(
      "https://dev-yourcourt-api.herokuapp.com/bookings/user?username=" +
          sharedPreferences.getString("username"),
      headers: {"Authorization": "Bearer $token"},
    );

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

  Widget listBooks(List<Book> books) {
    if (books.length > 0) {
      return ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: books.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              child: Column(
                children: [
                  SizedBox(
                    height: 10.0,
                  ),
                  FutureBuilder<Court>(
                    future: getCourt(books.elementAt(index).courtId),
                      builder: (context, snapshot){
                        if(snapshot.connectionState==ConnectionState.done){
                          return Text("Pista reservada: " + snapshot.data.name, style: TextStyle(color: Colors.black));
                        }
                        return Container();
                      }
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    "Empieza: " + books.elementAt(index).startDate,
                    style: TextStyle(color: Colors.black),
                  ),
                  Text(
                    "Termina: " + books.elementAt(index).endDate,
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    "Productos incluidos: ",
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  showBookProducts(books.elementAt(index).productBooking),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    "Total de la reserva: " +
                        books.elementAt(index).productBookingSum.toString() + " €",
                    style: TextStyle(color: Colors.black),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xFFBB856E),
                        ),
                        onPressed: DateTime.now().isAfter(DateTime.parse(
                                books.elementAt(index).startDate))
                            ? null
                            : () {
                                if (sharedPreferences.getInt("id") ==
                                        books.elementAt(index).userId ||
                                    sharedPreferences
                                            .getStringList("roles")
                                            .contains("ROLE_ADMIN") ==
                                        true) {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          content: Text(
                                              "¿Desea cancelar la reserva?"),
                                          actions: [
                                            ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  primary: Color(0xFFBB856E),
                                                ),
                                                onPressed: () async {
                                                  deleteBook(
                                                      books.elementAt(index), context);
                                                },
                                                child: Text("Si")),
                                            ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  primary: Color(0xFFBB856E),
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text("No")),
                                          ],
                                        );
                                      });
                                } else {
                                  print(
                                      "No puede cancelar una reserva que no le pertenece");
                                }
                              },
                        child: Text(
                          "Cancelar reserva",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(
                        height: 30.0,
                      ),
                    ],
                  ),
                ],
              ),
            );
          });
    } else {
      return Center(
        child: Container(child: Text("No hay ninguna reserva realizada")),
      );
    }
  }

  Widget showBookProducts(ProductBooking productsBooking) {
    if (productsBooking!=null) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: productsBooking.lines.length,
          itemBuilder: (BuildContext context, int index) {
            return FutureBuilder<Product>(
                future: getProduct(productsBooking.lines.elementAt(index).productId),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: [
                        Text(
                          "Producto : " + snapshot.data.name,
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300)
                        ),
                        Text(
                          "Dto : " +
                              productsBooking.lines
                                  .elementAt(index)
                                  .discount
                                  .toString(),
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300)
                        ),
                        Text(
                          "Cantidad : " +
                              productsBooking.lines
                                  .elementAt(index)
                                  .quantity
                                  .toString(),
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300)
                        ),
                      ],
                    );
                  }
                  return Container();
                });
          });
    } else {
      return Text(
        "No hay productos añadidos",
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300),
      );
    }
  }


  deleteBook(Book book, BuildContext context) async {
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
        showMessage("La reserva ha sido cancelada", context);
      });
    } else {
      print("Ha ocurrido un error: " + response.body);
    }
  }

  Future<Product> getProduct(int id) async {
    Product p;
    var jsonResponse;
    var response = await http.get(
        "https://dev-yourcourt-api.herokuapp.com/products/" + id.toString());

    if (response.statusCode == 200) {
      jsonResponse = transformUtf8(response.bodyBytes);
      p = Product.fromJson(jsonResponse);
    } else {
      print("Se ha producido un error" + response.statusCode.toString());
    }

    return p;
  }

  Future<Court> getCourt(int id) async {
    Court court;
    var jsonResponse;
    var response = await http
        .get("https://dev-yourcourt-api.herokuapp.com/courts/" + id.toString());
    if (response.statusCode == 200) {
      jsonResponse = transformUtf8(response.bodyBytes);
    }
    court = Court.fromJson(jsonResponse);

    return court;
  }
}
