
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yourcourt/src/utiles/functions.dart';

import '../../../main.dart';
import 'LoginPage.dart';

class SignUpPage extends StatefulWidget {

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  DateTime _dateTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.lightBlueAccent,
      appBar: AppBar(
        title: Text("Página de registro"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            headerSection(),
            textSection(context),
            buttonSection(),
          ],
        ),
      ),
    );
  }


  signUp(String username, password, email, phone, membershipNumber, DateTime date) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map data = {
      "email":email,
      "password":password,
      "username":username,
      "birthDate":date.toString().substring(0,10),
      "membershipNumber":membershipNumber,
      "phone":phone,
      "roles": [
        "user"
      ]
    };

    var jsonResponse;

    var response = await http.post(
        "https://dev-yourcourt-api.herokuapp.com/users",
        body: json.encode(data),
        headers: {
          "Accept": "application/json",
          "Content-type": "application/json"
        });
    if (response.statusCode == 201) {
      jsonResponse = transformUtf8(response.bodyBytes);
      if (jsonResponse != null) {

        sharedPreferences.setString("token", jsonResponse['token']);
        sharedPreferences.setString("username", username);

        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => MainPage()), (
            Route<dynamic> route) => false);
      }
    }
    else {
      print(response.statusCode);
      print("Se ha producido un error: " + response.body);
    }
    return response;
  }


  final TextEditingController usernameController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController phoneController = new TextEditingController();
  final TextEditingController membershipController = new TextEditingController();


  Container headerSection() {
    return Container(
      margin: EdgeInsets.only(top: 10.0),
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      child: Text("YourCourt",
          style: TextStyle(
              color: Colors.blue,
              fontSize: 40.0,
              fontWeight: FontWeight.bold)),
    );
  }

  Container textSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: usernameController,
            validator: (value) {
              if (value.length == 0) {
                return 'Por favor, introduzca un nombre de usuario';
              }
              return null;
            },
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              icon: Icon(Icons.verified_user, color: Colors.white70),
              hintText: "Nombre de usuario",
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
          SizedBox(height: 10.0),
          TextFormField(
            controller: passwordController,
            validator: (value) {
              if (value.length == 0) {
                return 'Por favor, introduzca una contraseña';
              }
              return null;
            },
            cursorColor: Colors.white,
            obscureText: true,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              icon: Icon(Icons.lock, color: Colors.white70),
              hintText: "Contraseña",
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.white70),
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
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              icon: Icon(Icons.email, color: Colors.white70),
              hintText: "Email",
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
          SizedBox(height: 10.0),
          TextFormField(
            controller: phoneController,
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
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              icon: Icon(Icons.phone, color: Colors.white70),
              hintText: "Teléfono",
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
          SizedBox(height: 10.0),
          TextFormField(
            controller: membershipController,
            validator: (value) {
              String memberShipPatter = r"\\b\\d{5}\\b";
              RegExp regExp = new RegExp(memberShipPatter);
              if (value.length == 0) {
                return 'Por favor, introduzca un número de socio';
              }
              else if (!regExp.hasMatch(value)) {
                return 'Por favor, introduzca un número de socio válido';
              }
              return null;
            },
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              icon: Icon(Icons.phone_android, color: Colors.white70),
              hintText: "Número de socio",
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
          SizedBox(height: 10.0),
          Text('Fecha de nacimiento:', textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20,
                color: Colors.white
            ),
          ),
          Text(_dateTime == null
              ? 'No hay ninguna fecha seleccionada'
              : _dateTime.toString()),
          SizedBox(height: 10.0),
          ElevatedButton(
            child: Text("Seleccione una fecha"),
            onPressed: () {
              showDatePicker(context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now()
              ).then((date) {
                setState(() {
                  _dateTime = date;
                });
              });
            },
          ),

        ],
      ),
    );

  }

  Container buttonSection() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 40.0,
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      margin: EdgeInsets.only(top: 15.0),
      child: ElevatedButton(
        onPressed: usernameController.text == "" || passwordController.text == "" ||
            emailController.text == "" || phoneController.text == "" ||
            membershipController.text == "" || _dateTime == null ? null : () async {

          signUp(usernameController.text, passwordController.text , emailController.text,
              phoneController.text, membershipController.text, _dateTime);
        },
        child: Text("Sign Up", style: TextStyle(color: Colors.white70)),
      ),
    );
  }

}


