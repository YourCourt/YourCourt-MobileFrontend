import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yourcourt/src/Screens/bookingScreen/ProductBooking.dart';
import 'package:yourcourt/src/Utiles/cabeceras.dart';
import 'package:yourcourt/src/Utiles/principal_structure.dart';
import 'package:yourcourt/src/Utiles/menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yourcourt/src/models/book/BookingDate.dart';
import 'package:yourcourt/src/models/Court.dart';
import 'package:http/http.dart' as http;
import 'package:yourcourt/src/models/product/Product.dart';

import '../login/LoginPage.dart';


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

  Widget body() {
    return Column(
      children: [
        Text(widget.date, style: TextStyle(color: Colors.black),),
        Text(widget.hour.startHour + " -> " + widget.hour.endHour,
          style: TextStyle(color: Colors.black),),
        ElevatedButton(
          onPressed: (){
            //Un stateFul widget que realice las operaciones de alquilar los productos
            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ProductBooking()));
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

}
