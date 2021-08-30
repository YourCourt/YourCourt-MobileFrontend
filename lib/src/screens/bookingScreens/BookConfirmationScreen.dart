import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yourcourt/src/models/BookingDate.dart';
import 'package:yourcourt/src/models/Court.dart';
import 'package:http/http.dart' as http;
import 'package:yourcourt/src/models/Product.dart';
import 'package:yourcourt/src/models/ProductBookingLine.dart';
import 'package:yourcourt/src/screens/loginScreens/LoginPage.dart';
import 'package:yourcourt/src/utils/functions.dart';
import 'package:yourcourt/src/utils/headers.dart';
import 'package:yourcourt/src/utils/menu.dart';
import 'package:yourcourt/src/utils/principal_structure.dart';

import 'MyBooksScreen.dart';
import 'ProductBooking.dart';


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
    return principal(context, sharedPreferences, appHeadboard(context, sharedPreferences), body(), MenuLateral());
  }


  Widget show = Container(
    child: Text("Prueba ")
  );

  Widget body() {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 10.0,),
          Text("Fecha de la reserva:  ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 20.0),),
          SizedBox(height: 5.0,),
          Text(widget.date, style: TextStyle(color: Colors.black),),
          SizedBox(height: 10.0,),
          Text("Hora:  ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400,fontSize: 20.0)),
          SizedBox(height: 5.0,),
          Text(widget.hour.startHour + " -> " + widget.hour.endHour,
            style: TextStyle(color: Colors.black),),
          SizedBox(height: 20.0,),
          Text("Productos alquilados: ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 20.0),),
          SizedBox(height: 5.0,),
          Expanded(
              child: showBookProducts(widget.productsBooking),
            ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Color(0xFFDBA58F),
            ),
            onPressed: (){
              //Un stateFul widget que realice las operaciones de alquilar los productos
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ProductBooking(court: widget.court, date: widget.date, hour: widget.hour, )));
            },
            child: Text("Alquilar productos", style: TextStyle(color: Colors.white),),
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Color(0xFFBB856E),
              ),
              onPressed: () async {
                //Si se produce algún error en la reserva, mostrarlo.
                Response r = await confirmBook();
                if(r.statusCode == 201){
                  Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => MyBooks()));
                } else{
                  print("Se ha producido un error: " + r.body);
                }

              },
              child: Text(
                "Confirmar reserva", style: TextStyle(color: Colors.white),)),
        ],
      ),
    );
  }


  List<Map<String, dynamic>> productsBookingToJson(List<ProductBookingLine> productsBooking) {
    List<Map<String, dynamic>> productsBookingToJson = [];

    for(var item in productsBooking){
      productsBookingToJson.add(item.toJson());
    }
    return productsBookingToJson;
  }

  Future<Response> confirmBook() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

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
    var token = sharedPreferences.getString("token");
    var response = await http.post(
        "https://dev-yourcourt-api.herokuapp.com/bookings",
        body: json.encode(data),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-type": "application/json"
        });

    if (response.statusCode == 201) {
      print("Reserva creada");
    } else{
      print(response.statusCode);
      print(response.body);
    }
    return response;

  }

  Widget showBookProducts(List<ProductBookingLine> productsBooking){
    if(productsBooking!=null){
      return ListView.builder(
        shrinkWrap: true,
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

    return Center(
      child: Text("No hay productos añadidos", style: TextStyle(color: Colors.black),),
    );
  }

  Future<String> getProduct(int id) async {
    Product product;
    var jsonResponse;

    var response = await http.get("https://dev-yourcourt-api.herokuapp.com/products/"+id.toString());
    if (response.statusCode==200){
      jsonResponse = transformUtf8(response.bodyBytes);

      product = Product.fromJson(jsonResponse);

    }
    return product.name;

  }

}
