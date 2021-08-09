import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yourcourt/src/Utiles/cabeceras.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:yourcourt/src/Utiles/menu.dart';
import 'package:yourcourt/src/Utiles/principal_structure.dart';
import 'package:yourcourt/src/models/Inscription.dart';
import 'package:yourcourt/src/utiles/functions.dart';

import 'login/LoginPage.dart';

class MyInscriptions extends StatefulWidget {

  @override
  _MyInscriptionsState createState() => _MyInscriptionsState();
}

class _MyInscriptionsState extends State<MyInscriptions> {
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
    return FutureBuilder <List<Inscription>>(
        future: getInscriptions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState==ConnectionState.done) {
            return GridView.count(
              crossAxisCount: 2,
              children: [
                listInscriptions(snapshot.data),
              ]
            );
          } else {
            return CircularProgressIndicator();
          }
        }
    );
  }

  Future<List<Inscription>> getInscriptions() async {
    sharedPreferences = await SharedPreferences.getInstance();

    List<Inscription> inscriptions = [];

    var token = sharedPreferences.getString("token");

    var jsonResponse;
    var response = await http.get(
      "https://dev-yourcourt-api.herokuapp.com/inscriptions/user/"+sharedPreferences.getString("username"),
      headers: {"Authorization": "Bearer $token"},);

    if (response.statusCode == 200) {

      jsonResponse = transformUtf8(response.bodyBytes);

      for (var item in jsonResponse) {

        inscriptions.add(Inscription.fromJson(item));
      }
    } else {
      print(response.statusCode);
      print("Se ha producido un error: " + response.body);
    }

    return inscriptions;
  }

  Widget listInscriptions(List<Inscription> inscriptions){

    ScrollController _controller = new ScrollController();

    if(inscriptions.length>0){
      return ListView.builder(
        controller: _controller,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: inscriptions.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: [
                Container(
                  child: Column(
                    children: [
                      Text("Curso:",style: TextStyle(color: Colors.black), ),
                      Text(inscriptions.elementAt(index).course.title, style: TextStyle(color: Colors.black),),
                      Text(inscriptions.elementAt(index).course.description, style: TextStyle(color: Colors.black),),
                      Text("Desde " + inscriptions.elementAt(index).course
                          .startDate + " hasta " + inscriptions.elementAt(index).course
                          .endDate, style: TextStyle(color: Colors.black),),
                    ],
                  ),
                ),
                Text("Inscripción:", style: TextStyle(color: Colors.black),),
                Text(inscriptions.elementAt(index).name, style: TextStyle(color: Colors.black),),
                Text(inscriptions.elementAt(index).surnames, style: TextStyle(color: Colors.black),),
                Text(inscriptions.elementAt(index).email, style: TextStyle(color: Colors.black),),
                Text(inscriptions.elementAt(index).phone, style: TextStyle(color: Colors.black),),
                // Text(inscriptions.elementAt(index).observations, style: TextStyle(color: Colors.black),),
                SizedBox(height: 10,),
                ElevatedButton(
                    onPressed: /*DateTime.now().isAfter(DateTime.parse(inscriptions.elementAt(index).course.startDate)) ? null :  */() {
                      deleteInscription(inscriptions.elementAt(index));
                    },
                    child: Text("Cancelar inscripción", style: TextStyle(color: Colors.white),),),
                SizedBox(height: 10,),
              ],
            );
          }
      );
    }
    else{
      return Container(
          child: Text("No hay ninguna inscripción realizada")
      );
    }
  }

  deleteInscription(Inscription inscription) async {

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    if(sharedPreferences.getInt("id") != inscription.userId || sharedPreferences.getStringList("roles").contains("ROLE_ADMIN")==true){

        showDialog(
            context: context,
            builder: (context){
              return AlertDialog(
                content: Text("¿Desea cancelar la inscripción?"),
                actions: [
                  ElevatedButton(
                      onPressed: () async {
                        var token = sharedPreferences.getString("token");
                        var response = await http.delete("https://dev-yourcourt-api.herokuapp.com/inscriptions/" + inscription.id.toString(),
                            headers: {"Authorization": "Bearer $token"});
                        if(response.statusCode==200){
                          setState(() {
                            print("Se ha cancelado la reserva con éxito");
                            Navigator.pop(context);
                          });
                        } else {
                          print(response.statusCode);
                          print("Se ha producido un error: " + response.body);

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
          "No puede cancelar una inscripción que no le pertenece");
    }

  }
}
