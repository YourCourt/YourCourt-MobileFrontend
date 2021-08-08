import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yourcourt/src/Utiles/cabeceras.dart';
import 'package:yourcourt/src/Utiles/menu.dart';
import 'package:yourcourt/src/Utiles/principal_structure.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:yourcourt/src/models/dto/InscriptionDto.dart';

class InscriptionForm extends StatefulWidget {

  final int courseId;

  const InscriptionForm({Key key, this.courseId}) : super(key: key);

  @override
  _InscriptionFormState createState() => _InscriptionFormState();
}

class _InscriptionFormState extends State<InscriptionForm> {

  SharedPreferences sharedPreferences;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Principal(context, sharedPreferences, appHeadboard(context, sharedPreferences), body(), MenuLateral());
  }

  Widget body(){
    return Center(
      child: Column(
        children: <Widget>[
          textSection(),
          buttonSection(),
        ],
      ),
    );
  }

  final TextEditingController emailController = new TextEditingController();
  final TextEditingController nameController = new TextEditingController();
  final TextEditingController observationsController = new TextEditingController();
  final TextEditingController phoneController = new TextEditingController();
  final TextEditingController surnamesController = new TextEditingController();

  Widget textSection() {
    return Container(
                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: nameController,
                        validator: (value) {
                          if (value.length == 0) {
                            return 'Por favor, introduzca un nombre';
                          }
                          return null;
                        },
                        cursorColor: Colors.black,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: "Nombre",
                          icon: Icon(Icons.verified_user, color: Colors.black),
                          border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          hintStyle: TextStyle(color: Colors.black),
                        ),
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        controller: emailController,
                        validator: (value) {
                          String emailPatter = r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
                          RegExp regExp = new RegExp(emailPatter);
                          if (value.length == 0) {
                            return 'Por favor, introduzca un email';
                          }
                          else if (!regExp.hasMatch(value)) {
                            return 'Por favor, introduzca un email válido';
                          }
                          return null;
                        },
                        cursorColor: Colors.black,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          icon: Icon(Icons.email, color: Colors.black),
                          hintText: "Email",
                          border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          hintStyle: TextStyle(color: Colors.black),
                        ),
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        keyboardType: TextInputType.phone,
                        validator: (value){
                          String mobilePattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
                          RegExp regExp = new RegExp(mobilePattern);
                          if (value.length == 0) {
                            return 'Por favor, introduzca un número de teléfono';
                          }
                          else if (!regExp.hasMatch(value)) {
                            return 'Por favor, introduzca un número de teléfono válido';
                          }
                          return null;
                        },
                        controller: phoneController,
                        cursorColor: Colors.black,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          icon: Icon(Icons.phone, color: Colors.black),
                          hintText: "Teléfono",
                          border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          hintStyle: TextStyle(color: Colors.black),
                        ),
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        controller: observationsController,
                        cursorColor: Colors.black,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: "Observaciones",
                          icon: Icon(Icons.phone_android, color: Colors.black),
                          border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          hintStyle: TextStyle(color: Colors.black),
                        ),
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        controller: surnamesController,
                        validator: (value) {
                          if (value.length == 0) {
                            return 'Por favor, introduzca los apellidos';
                          }
                          return null;
                        },
                        cursorColor: Colors.black,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: "Apellidos",
                          icon: Icon(Icons.phone_android, color: Colors.black),
                          border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          hintStyle: TextStyle(color: Colors.black),
                        ),
                      ),

                    ],
                  ),
                )
    );
  }

  Widget buttonSection() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 40.0,
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      margin: EdgeInsets.only(top: 15.0),
      child: ElevatedButton(
        onPressed: nameController.text == "" || emailController.text == "" || phoneController.text == "" ||
            surnamesController.text == "" ? null : () {
          //Incribir al usuario
          signOn(nameController.text, observationsController.text, emailController.text, phoneController.text, surnamesController.text);
          showDialog(
              context: context,
              builder: (context){
                return AlertDialog(
                  content: Text("El perfil ha sido actualizado", style: TextStyle(color: Colors.black),),
                  actions: [
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            Navigator.pop(context);
                          });
                        },
                        child: Text("Ok", style: TextStyle(color: Colors.white),))
                  ],
                );
              }
          );
        },
        child: Text("Actualizar perfil", style: TextStyle(color: Colors.black)),
      ),
    );
  }

  signOn(String name, observations, email, phone, surnames) async {

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    Map data = InscriptionDto(email: email, name: name, observations: observations, phone: phone, surnames: surnames).toJson();

    var token = sharedPreferences.getString("token");

    var response = await http.post(
        "https://dev-yourcourt-api.herokuapp.com/inscriptions/course/"+widget.courseId.toString(),
        body: json.encode(data),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-type": "application/json"
        });

    if (response.statusCode == 201) {
      print("Incripción registrada con éxito");
    }
    else {
      print("Se ha producido un error " + response.statusCode.toString());
    }
  }
}
