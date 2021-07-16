import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:yourcourt/src/Utiles/menu.dart';
import '../models/Court.dart';
import '../models/ImageOf.dart';

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
      ),

        body: Container(
          child: FutureBuilder <List<Court>>(
              future: getCourts(),
              builder: (context, snapshot) {
                if (snapshot.hasData){
                  return Container(
                    child: Column(
                        children: listCourts(snapshot.data),
                    ),
                  );
                }
                else{
                  return Container(
                    child: Text("No disponible"),
                  );
                }
              }
          ),
        ),
      drawer: MenuLateral(),
    );

  }

  List<Widget> listCourts(List<Court> data){

    List<Widget> courts = [];

    for (var court in data){
      courts.add(
                Text(court.courtType, style: TextStyle(color: Colors.black),
            ),
      );
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
      print(item[0]);
      ImageOf imageCourt = ImageOf(name:item['image'][1], imageUrl:item['image'][2]);
      Court pista = Court(name:item['name'], description:item['description'],
          courtType:item['courtType'], image:imageCourt);
      courts.add(pista);
    }
    print("Pistas: ${courts}");
    return courts;
  }

}
