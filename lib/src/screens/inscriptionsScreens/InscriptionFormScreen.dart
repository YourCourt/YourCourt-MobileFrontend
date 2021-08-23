import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yourcourt/src/screens/loginScreens/LoginPage.dart';
import 'package:yourcourt/src/utils/menu.dart';
import 'package:yourcourt/src/utils/principal_structure.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:yourcourt/src/models/dto/InscriptionDto.dart';
import 'package:yourcourt/src/utils/headers.dart';
import 'package:yourcourt/src/utils/toast_messages.dart';

import 'MyInscriptionsScreen.dart';


class InscriptionForm extends StatefulWidget {
  final int courseId;

  const InscriptionForm({Key key, this.courseId}) : super(key: key);

  @override
  _InscriptionFormState createState() => _InscriptionFormState();
}

class _InscriptionFormState extends State<InscriptionForm> {
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
    return Center(
      child: Column(
        children: <Widget>[
          headerSection(),
          textSection(),
          buttonSection(),
        ],
      ),
    );
  }

  Container headerSection() {
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      alignment: Alignment.topCenter,
      child: Text("Formulario de Inscripción",
              style: TextStyle(
                  color: Color(0x9A922020),
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold)),
    );
  }

  final TextEditingController emailController = new TextEditingController();
  final TextEditingController nameController = new TextEditingController();
  final TextEditingController observationsController = new TextEditingController();
  final TextEditingController phoneController = new TextEditingController();
  final TextEditingController surnamesController = new TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Widget textSection() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
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
                    icon: Icon(Icons.account_circle_rounded, color: Colors.black),
                    border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    hintStyle: TextStyle(color: Color(0xFFA8A8B1)),
                  ),
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  controller: emailController,
                  validator: (value) {
                    String emailPatter =
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
                    RegExp regExp = new RegExp(emailPatter);
                    if (value.length == 0) {
                      return 'Por favor, introduzca un email';
                    } else if (!regExp.hasMatch(value)) {
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
                    hintStyle: TextStyle(color: Color(0xFFA8A8B1)),
                  ),
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    String mobilePattern = r'^(([+][(][0-9]{1,3}[)][ ])?([0-9]{6,12}))$';
                    RegExp regExp = new RegExp(mobilePattern);
                    if (value.length == 0) {
                      return 'Por favor, introduzca un número de teléfono';
                    } else if (!regExp.hasMatch(value)) {
                      return 'Por favor, introduzca un número de teléfono válido';
                    }
                    return null;
                  },
                  controller: phoneController,
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    icon: Icon(Icons.phone_android_outlined, color: Colors.black),
                    hintText: "Teléfono",
                    border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    hintStyle: TextStyle(color: Color(0xFFA8A8B1)),
                  ),
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  controller: observationsController,
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: "Observaciones",
                    icon: Icon(Icons.announcement_outlined, color: Colors.black),
                    border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    hintStyle: TextStyle(color: Color(0xFFA8A8B1)),
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
                    icon: Icon(Icons.supervised_user_circle, color: Colors.black),
                    border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    hintStyle: TextStyle(color: Color(0xFFA8A8B1)),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget buttonSection() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 40.0,
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      margin: EdgeInsets.only(top: 15.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Color(0xFFDBA58F),
        ),
        onPressed: nameController.text == "" ||
                emailController.text == "" ||
                phoneController.text == "" ||
                surnamesController.text == ""
            ? null
            : () {
                //Incribir al usuario
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: Text("¿Desea confirmar la inscripción con estos datos?"),
                        actions: [
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xFFBB856E),
                              ),
                              onPressed: () async {
                                if(!_formKey.currentState.validate()){
                                  showMessage("Algunos campos son incorrectos", context);
                                } else {
                                  signOn(
                                      nameController.text,
                                      observationsController.text,
                                      emailController.text,
                                      phoneController.text,
                                      surnamesController.text);
                                }

                              },
                              child: Text(
                                "Si",
                                style: TextStyle(color: Colors.white),
                              )),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xFFBB856E),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                "No",
                                style: TextStyle(color: Colors.white),
                              )),
                        ],
                      );
                    });
              },
        child: Text("Inscribirse", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  signOn(String name, observations, email, phone, surnames) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    Map data = InscriptionDto(
            email: email,
            name: name,
            observations: observations,
            phone: phone,
            surnames: surnames)
        .toJson();

    var token = sharedPreferences.getString("token");

    var response = await http.post(
        "https://dev-yourcourt-api.herokuapp.com/inscriptions/course/" +
            widget.courseId.toString(),
        body: json.encode(data),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-type": "application/json"
        });

    if (response.statusCode == 201) {
      print("Incripción registrada con éxito");
      showMessage("Inscripción registrada con éxito", context);
      setState(() {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => MyInscriptions()));
      });

    } else {
      showMessage("Se han encontrado los siguientes errores: " + response.body, context);
      print(response.statusCode);
      print("Se ha producido un error " + response.body);
      Navigator.pop(context);
    }
  }
}
