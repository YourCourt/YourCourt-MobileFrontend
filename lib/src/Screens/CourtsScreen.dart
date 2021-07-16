import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:yourcourt/src/Utiles/menu.dart';
import '../models/Court.dart';
import '../models/ImageOf.dart';
import 'LoginPage.dart';
import 'PerfilScreen.dart';

class CourtsPage extends StatefulWidget {

  @override
  _CourtsPageState createState() => _CourtsPageState();
}

class _CourtsPageState extends State<CourtsPage> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("YourCourt", style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => LoginPage()), (Route<dynamic> route) => false);
            },
            child: Text("Log Out", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => MiPerfil()), (Route<dynamic> route) => false);
            },
            child: Text("Mi perfil", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),

        body: FutureBuilder <List<Court>>(
                  future: getCourts(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return GridView.count(
                        crossAxisCount: 2,
                        children: listCourts(snapshot.data),
                      );
                    } else {
                      return Container(
                        child: Text("No disponible"),
                      );
                    }
                  }
                  ),

            drawer: MenuLateral(),
    );

  }

  List<Widget> listCourts(List<Court> data){

    List<Widget> courts = [];

    for (var court in data){
      courts.add(
          Container(
            padding: const EdgeInsets.all(8),
            child: CircleAvatar(
              backgroundImage: NetworkImage(court.image.imageUrl),
              child: Text(court.courtType, style: TextStyle(color: Colors.black),
              ),
            ),
          ),
      );
    }
    return courts;

  }

/*  List<Widget> listCourts(List<Court> data){

    List<Widget> courts = [];

    for (var court in data){
      courts.add(
          Card(
            child: pistas(court),
          )
      );
    }
    return courts;
  }*/


  Future<List<Court>> getCourts() async {
    List<Court> courts = [];

    var jsonResponse;
    var response = await http.get(
        "https://dev-yourcourt-api.herokuapp.com/courts");
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
    }
    for (var item in jsonResponse) {

      /*ImageOf imageCourt = ImageOf(name:item['image']['name'], imageUrl:item['image']['imageUrl']);

      Court pista = Court(name:item['name'], description:item['description'],
          courtType:item['courtType'], image:imageCourt);
      courts.add(pista);*/
      courts.add(Court.fromJson(item));
    }
    print("Pistas: ${courts}");
    return courts;
  }

}
