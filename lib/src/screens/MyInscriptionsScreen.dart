import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:yourcourt/src/utils/menu.dart';
import 'package:yourcourt/src/utils/principal_structure.dart';
import 'package:yourcourt/src/models/Inscription.dart';
import 'package:yourcourt/src/utils/functions.dart';
import 'package:yourcourt/src/utils/headers.dart';
import 'package:yourcourt/src/utils/toast_messages.dart';

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
    if (sharedPreferences.getString("token") == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
          (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return principal(context, sharedPreferences,
        appHeadboard(context, sharedPreferences), body(), MenuLateral());
  }

  Widget body() {
    return FutureBuilder<List<Inscription>>(
        future: getInscriptions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 10.0,
                  ),
                  Expanded(
                    child: listInscriptions(snapshot.data),
                  ),
                ]);
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  Future<List<Inscription>> getInscriptions() async {
    sharedPreferences = await SharedPreferences.getInstance();

    List<Inscription> inscriptions = [];

    var token = sharedPreferences.getString("token");

    var jsonResponse;
    var response = await http.get(
      "https://dev-yourcourt-api.herokuapp.com/inscriptions/user/" +
          sharedPreferences.getString("username"),
      headers: {"Authorization": "Bearer $token"},
    );

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

  Widget listInscriptions(List<Inscription> inscriptions) {
    ScrollController _controller = new ScrollController();

    if (inscriptions.length > 0) {
      return ListView.builder(
          controller: _controller,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: inscriptions.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Curso inscrito: ",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize: 15.0),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        inscriptions.elementAt(index).course.title,
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 18.0),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            " Desde ",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w300),
                          ),
                          Text(
                            inscriptions.elementAt(index).course.startDate,
                            style: TextStyle(color: Colors.black),
                          ),
                          Text(
                            " hasta ",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w300),
                          ),
                          Text(
                            inscriptions.elementAt(index).course.endDate,
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Text(
                  "Datos de la inscripción:",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: 15.0),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Nombre: ",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w300),
                    ),
                    Text(
                      inscriptions.elementAt(index).name,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Apellidos: ",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w300),
                    ),
                    Text(
                      inscriptions.elementAt(index).surnames,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Email: ",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w300),
                    ),
                    Text(
                      inscriptions.elementAt(index).email,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Teléfono: ",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w300),
                    ),
                    Text(
                      inscriptions.elementAt(index).phone,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5.0,
                ),
                observationsIsNotNull(
                    inscriptions.elementAt(index).observations),
                SizedBox(
                  height: 5.0,
                ),
                // Text(inscriptions.elementAt(index).observations, style: TextStyle(color: Colors.black),),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFFDBA58F),
                  ),
                  onPressed: /*DateTime.now().isAfter(DateTime.parse(inscriptions.elementAt(index).course.startDate)) ? null :  */ () {
                    deleteInscription(inscriptions.elementAt(index));
                  },
                  child: Text(
                    "Cancelar inscripción",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            );
          });
    } else {
      return Center(
        child: Container(child: Text("No hay ninguna inscripción realizada")),
      );
    }
  }

  Widget observationsIsNotNull(String observations) {
    if (observations != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Observaciones: ",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300),
          ),
          Text(
            observations,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  deleteInscription(Inscription inscription) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    if (sharedPreferences.getInt("id") != inscription.userId ||
        sharedPreferences.getStringList("roles").contains("ROLE_ADMIN") ==
            true) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text("¿Desea cancelar la inscripción?"),
              actions: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFFBB856E),
                    ),
                    onPressed: () async {
                      var token = sharedPreferences.getString("token");
                      var response = await http.delete(
                          "https://dev-yourcourt-api.herokuapp.com/inscriptions/" +
                              inscription.id.toString(),
                          headers: {"Authorization": "Bearer $token"});
                      if (response.statusCode == 200) {
                        setState(() {
                          print("Se ha cancelado la reserva con éxito");
                          showMessage("La inscripción ha sido cancelada", context);
                          Navigator.pop(context);
                        });
                      } else {
                        showMessage("¡Ha ocurrido algo inesperado!", context);
                        print(response.statusCode);
                        print("Se ha producido un error: " + response.body);
                      }
                    },
                    child: Text("Si")),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFFBB856E),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("No")),
              ],
            );
          });
    } else {
      print("No puede cancelar una inscripción que no le pertenece");
    }
  }
}
