import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:yourcourt/src/utils/principal_structure.dart';
import 'package:yourcourt/src/utils/menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yourcourt/src/utils/functions.dart';
import 'package:yourcourt/src/utils/headers.dart';
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
    return principal(context, sharedPreferences, appHeadboard(context, sharedPreferences), body(), MenuLateral());

  }

  Widget body() {
    return Center(
      child: FutureBuilder <List<Court>>(
            future: getCourts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState==ConnectionState.done) {
                return Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text("Seleccione una pista para reservar", style: TextStyle(color: Color(
                          0xFF9E7053), fontSize: 20.0, fontWeight: FontWeight.bold), ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Expanded(
                        child: listCourts(snapshot.data)),
                  ],
                );
              } else {
                return CircularProgressIndicator();
              }
            }
        )
    );
  }

  Widget listCourts(List<Court> courts){


    if(courts!=null){
      return ListView.builder(
          itemCount: courts.length,
          itemBuilder: (context, int index){
            return Container(
              padding: const EdgeInsets.all(4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    child: Image(
                      height: 250,
                      width: 250,
                      image: NetworkImage(courts.elementAt(index).image.imageUrl),
                      semanticLabel: courts.elementAt(index).courtType,
                    ),
                    onTap: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return ListTile(
                              leading: new Icon(Icons.wysiwyg),
                              title: Text("Reservar", style: TextStyle(color: Colors.black),),
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => BookingPage(court: courts.elementAt(index),)));
                              },
                            );
                          }
                      );
                    },
                  ),
                  Text(courts.elementAt(index).name, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10.0,),
                ],
              ),
            );
          }
      );
    } else {
      return Container(
        child: Text("No hay pistas disponibles"),
      );
    }


  }


  Future<List<Court>> getCourts() async {
    List<Court> courts = [];

    var jsonResponse;
    var response = await http.get(
        "https://dev-yourcourt-api.herokuapp.com/courts");
    if (response.statusCode == 200) {
      jsonResponse = transformUtf8(response.bodyBytes);
    }
    for (var item in jsonResponse) {

      courts.add(Court.fromJson(item));
    }
    return courts;
  }

}
