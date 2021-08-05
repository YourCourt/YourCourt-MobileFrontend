import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yourcourt/main.dart';
import 'package:yourcourt/src/Screens/bookingScreen/ProductBooking.dart';
import 'package:yourcourt/src/Utiles/cabeceras.dart';
import 'package:yourcourt/src/Utiles/principal_structure.dart';
import 'package:yourcourt/src/Utiles/menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yourcourt/src/models/book/BookingDate.dart';
import 'package:yourcourt/src/models/Court.dart';
import 'package:http/http.dart' as http;
import 'package:yourcourt/src/models/book/ProductBookingLine.dart';
import 'package:yourcourt/src/models/product/Product.dart';

import '../login/LoginPage.dart';


class BookConfirmation extends StatefulWidget {
  final String date;
  final BookDate hour;
  final Court court;
  final List<ProductBookingLine> productsBooking;

  const BookConfirmation({Key key, this.date, this.hour, this.court, this.productsBooking}) : super(key: key);

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


  Widget show = Container(
    child: Text("Prueba ")
  );

  Widget body() {
    return Column(
      children: [
        Text(widget.date, style: TextStyle(color: Colors.black),),
        Text(widget.hour.startHour + " -> " + widget.hour.endHour,
          style: TextStyle(color: Colors.black),),
        Text("Productos alquilados: ", style: TextStyle(color: Colors.black),),
        Expanded(
          child: SizedBox(
            height: 200,
            child: showBookProducts(widget.productsBooking),
          ),
        ),
        ElevatedButton(
          onPressed: (){
            //Un stateFul widget que realice las operaciones de alquilar los productos
            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ProductBooking(court: widget.court, date: widget.date, hour: widget.hour, )));
          },
          child: Text("Alquilar productos", style: TextStyle(color: Colors.black),),
        ),
        ElevatedButton(
            onPressed: () {
              confirmBook();
              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => MainPage()));
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


  List<Map<String, dynamic>> productsBookingToJson(List<ProductBookingLine> productsBooking) {
    List<Map<String, dynamic>> productsBookingToJson = [];

    for(var item in productsBooking){
      productsBookingToJson.add(item.toJson());
    }
    return productsBookingToJson;
  }

  confirmBook() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String username = sharedPreferences.getString("username");
    getUserId(username);

    Map data = {};

    if(widget.productsBooking!=null){
      data = {
        "court": widget.court.id,
        "endDate": widget.date + "T" + widget.hour.endHour,
        "lines": productsBookingToJson(widget.productsBooking),
        "startDate": widget.date + "T" + widget.hour.startHour,
        "user": sharedPreferences.getInt("id"),
      };

    } else{
      data = {
        "court": widget.court.id,
        "endDate": widget.date + "T" + widget.hour.endHour,
        "lines": [],
        "startDate": widget.date + "T" + widget.hour.startHour,
        "user": sharedPreferences.getInt("id"),
      };
    }

    print(data);

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

  Widget showBookProducts(List<ProductBookingLine> productsBooking){
    if(productsBooking!=null){
      return ListView.builder(
          itemCount: productsBooking.length,
          itemBuilder: (BuildContext context, int index){
            return FutureBuilder(
                future: getProduct(productsBooking.elementAt(index).productId),
                builder: (context, snapshot){
                  if(snapshot.connectionState==ConnectionState.done){
                    return Column(
                      children: [
                        Text("Producto : "+ snapshot.data, style: TextStyle(color: Colors.black),),
                        Text("Dto : "+ productsBooking.elementAt(index).discount.toString(), style: TextStyle(color: Colors.black),),
                        Text("Cantidad : "+ productsBooking.elementAt(index).quantity.toString(), style: TextStyle(color: Colors.black),),
                      ],
                    );
                  }
                  return CircularProgressIndicator(

                  );
                }
            );
          }
      );
    }

    return Text("No hay productos añadidos", style: TextStyle(color: Colors.black),);
  }

  Future<String> getProduct(int id) async {
    Product product;
    var jsonResponse;

    var response = await http.get("https://dev-yourcourt-api.herokuapp.com/products/"+id.toString());
    if (response.statusCode==200){
      jsonResponse = json.decode(response.body);

      product = Product.fromJson(jsonResponse);

    }
    return product.name;

  }

}
