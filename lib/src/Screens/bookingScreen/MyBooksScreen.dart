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
              children: listBooks(snapshot.data),
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
      jsonResponse = json.decode(response.body);

      for (var item in jsonResponse) {

        books.add(Book.fromJson(item));
      }
    }

    return books;
  }

  List<Widget> listBooks(List<Book> data){

    List<Widget> books = [];

    for (var book in data){
      if(DateTime.now().isAfter(DateTime.parse(book.startDate))){
        books.add(
          Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Text("Empieza: " + book.startDate, style: TextStyle(color: Colors.black),),
                  Text("Termina: " + book.endDate, style: TextStyle(color: Colors.black),),
                  Text("Productos: " + book.productBooking.lines.toString(), style: TextStyle(color: Colors.black),),
                  Text("Precio final: " + book.productBookingSum.toString(), style: TextStyle(color: Colors.black),),
                ]
              ),
          ));
      }
      else {
        books.add(
            Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Text("Empieza: " + book.startDate, style: TextStyle(color: Colors.black),),
                  Text("Termina: " + book.endDate, style: TextStyle(color: Colors.black),),
                  Text("Productos: " + book.productBooking.lines.toString(), style: TextStyle(color: Colors.black),),
                  Text("Precio final: " + book.productBookingSum.toString(), style: TextStyle(color: Colors.black),),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: DateTime.now().isAfter(DateTime.parse(book.startDate)) ? null : () {
                            if(sharedPreferences.getInt("id") != book.userId || sharedPreferences.getStringList("roles").contains("ROLE_ADMIN")==true) {
                              showDialog(
                                  context: context,
                                  builder: (context){
                                    return AlertDialog(
                                      content: Text("¿Desea cancelar la reserva?"),
                                      actions: [
                                        ElevatedButton(
                                            onPressed: () async {
                                              Response r = await deleteBook(book);
                                              if(r.statusCode==200){
                                                setState(() {
                                                  print("Se ha cancelado la reserva con éxito");
                                                  Navigator.pop(context);
                                                });
                                              } else{
                                                print("Ha ocurrido un error: "+ r.body);
                                              }

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
                  )
                ],
              ),
            ));
    }

    }
    return books;

  }

  Future<Response> deleteBook(Book book) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();


        var token = sharedPreferences.getString("token");
        var response = await http.delete("https://dev-yourcourt-api.herokuapp.com/bookings/" + book.id.toString(),
        headers: {"Authorization": "Bearer $token"});

        return response;

  }
}
