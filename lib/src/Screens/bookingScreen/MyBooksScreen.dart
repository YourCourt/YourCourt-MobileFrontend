import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yourcourt/src/Utiles/cabeceras.dart';
import 'package:yourcourt/src/Utiles/menu.dart';
import 'package:yourcourt/src/Utiles/principal_structure.dart';
import 'package:yourcourt/src/models/book/Book.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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

    var jsonResponse;
    var response = await http.get(
        "https://dev-yourcourt-api.herokuapp.com/bookings/user?username="+sharedPreferences.getString("username"));

    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);

      for (var item in jsonResponse) {

        books.add(Book.fromJson(item));
      }
    }

    print("Reservas: ${books}");

    return books;
  }

  List<Widget> listBooks(List<Book> data){

    List<Widget> books = [];

    for (var book in data){
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
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context){
                                return AlertDialog(
                                  content: Text("¿Desea eliminar la reserva?"),
                                  actions: [
                                    ElevatedButton(
                                        onPressed: () {
                                          eliminarReserva(book);
                                          setState(() {
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
                        child: Text("Eliminar reserva", style: TextStyle(color: Colors.white),),
                    ),

                  ],
                )
              ],
            ),
          ))
      ;
    }
    return books;

  }

  eliminarReserva(Book book) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    if(getUserId(sharedPreferences.getString("username")) != book.userId || sharedPreferences.getStringList("roles").contains("ROLE_ADMIN")==true){

      var response = await http.delete("https://dev-yourcourt-api.herokuapp.com/bookings/" + book.id.toString());

      if(response.statusCode==200){
        print("Reserva eliminada");
      } else{
        print(response.statusCode);
      }
    } else{
      print("No puede eliminar una reserva que no le pertenece");
    }


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
}
