import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:yourcourt/src/Utiles/cabeceras.dart';
import 'package:yourcourt/src/Utiles/principal_structure.dart';
import 'package:yourcourt/src/Utiles/menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/Court.dart';
import 'bookingScreen/BookingScreen.dart';
import 'login/LoginPage.dart';

class CourtsPage extends StatefulWidget {

  @override
  _CourtsPageState createState() => _CourtsPageState();
}

class _CourtsPageState extends State<CourtsPage> {

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

  Widget body() {
    return FutureBuilder <List<Court>>(
        future: getCourts(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return GridView.count(
              crossAxisCount: 2,
              children: listCourts(snapshot.data),
            );
          } else {
            return CircularProgressIndicator();
          }
        }
    );
  }

  List<Widget> listCourts(List<Court> data){

    List<Widget> courts = [];

    for (var court in data){
      courts.add(
          Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                GestureDetector(
                  child: Image(
                    image: NetworkImage(court.image.imageUrl),
                    semanticLabel: court.courtType,
                  ),
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return ListTile(
                                  leading: new Icon(Icons.wysiwyg),
                                  title: Text("Reservar", style: TextStyle(color: Colors.black),),
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => BookingPage(court: court,)));
                                  },
                                );
                        }
                    );
                  },
                ),
                Text(court.name, style: TextStyle(color: Colors.black), 
                ),
              ],
            ),
          ))
      ;
    }
    return courts;

  }


  Future<List<Court>> getCourts() async {
    List<Court> courts = [];

    var jsonResponse;
    var response = await http.get(
        "https://dev-yourcourt-api.herokuapp.com/courts");
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
    }
    for (var item in jsonResponse) {

      courts.add(Court.fromJson(item));
    }
    return courts;
  }

}
