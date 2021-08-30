import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yourcourt/src/utils/already_have_an_account_check.dart';
import 'package:yourcourt/src/utils/functions.dart';
import 'package:yourcourt/src/utils/toast_messages.dart';

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
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarColor: Colors.transparent));
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.lightBlueAccent,
        appBar: AppBar(
          title: Text("Página de registro"),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.lightBlueAccent, Colors.blueAccent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter),
          ),
          child: Center(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 10.0,
                ),
                headerSection(),
                SizedBox(
                  height: 10.0,
                ),
                textSection(context),
                buttonSection(),
              ],
            ),
          ),
        ));
  }

  signUp(String username, password, email, phone, membershipNumber,
      DateTime date) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map data = {
      "email": email,
      "password": password,
      "username": username,
      "birthDate": date.toString().substring(0, 10),
      "membershipNumber": membershipNumber,
      "phone": phone,
      "roles": ["user"]
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
            MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
            (Route<dynamic> route) => false);
        showMessage("Usuario registrado con éxito", context);
      }
    } else {
      print(response.statusCode);
      print("Se ha producido un error: " + response.body);
      showMessage("Ha ocurrido un error: " + response.body.toString(), context);
    }
    return response;
  }

  final TextEditingController usernameController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController phoneController = new TextEditingController();
  final TextEditingController membershipController =
      new TextEditingController();

  Container headerSection() {
      return Container(
        alignment: Alignment.topLeft,
        padding: EdgeInsets.only(left: 10.0),
        child: Row(
          children: [
            Image(
              width: 50.0,
              height: 35.0,
              image: AssetImage('assets/yourcourt_logo.png'),
            ),
            SizedBox(width: 50.0,),
            Text("YourCourt",
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      );
  }
  final _formKey = GlobalKey<FormState>();

  Container textSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: Form(
        key: _formKey,
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
                icon: Icon(Icons.account_circle_rounded, color: Colors.white70),
                hintText: "Nombre de usuario",
                border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70)),
                hintStyle: TextStyle(color: Colors.white70),
              ),
            ),
            SizedBox(height: 5.0),
            TextFormField(
              controller: passwordController,
              validator: (value) {
                String passwordPatter =
                    r"(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[$@$!%*?&])?[A-Za-z\d$@$!%*?&].{8,}";
                RegExp regExp = new RegExp(passwordPatter);
                if (value.length == 0) {
                  return 'Por favor, introduzca una contraseña';
                } else if (!regExp.hasMatch(value)) {
                  return 'La contraseña debe contener al menos 8 caracteres entre letras, '
                      ' al menos una mayúscula, y números';
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
            SizedBox(height: 5.0),
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
            SizedBox(height: 5.0),
            TextFormField(
              controller: phoneController,
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
              cursorColor: Colors.white,
              style: TextStyle(color: Colors.white70),
              decoration: InputDecoration(
                icon: Icon(Icons.phone_android_outlined, color: Colors.white70),
                hintText: "Teléfono",
                border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70)),
                hintStyle: TextStyle(color: Colors.white70),
              ),
            ),
            SizedBox(height: 5.0),
            TextFormField(
              controller: membershipController,
              validator: (value) {
                String memberShipPatter = r"\b\d{5}\b";
                RegExp regExp = new RegExp(memberShipPatter);
                if (value.length == 0) {
                  return 'Por favor, introduzca un número de socio';
                } else if (!regExp.hasMatch(value)) {
                  return 'El número de socio es de 5 dígitos';
                }
                return null;
              },
              cursorColor: Colors.white,
              style: TextStyle(color: Colors.white70),
              decoration: InputDecoration(
                icon: Icon(Icons.supervised_user_circle, color: Colors.white70),
                hintText: "Número de socio",
                border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70)),
                hintStyle: TextStyle(color: Colors.white70),
              ),
            ),
            SizedBox(height: 5.0),
            Text(
              'Fecha de nacimiento:',
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 18, color: Colors.white70),
            ),
            SizedBox(
              height: 5.0,
            ),
            dateIsCorrect(_dateTime),
            SizedBox(height: 5.0),
            TextButton(
              child: Icon(
                Icons.calendar_today,
                color: Colors.white70,
              ),
              onPressed: () {
                showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now())
                    .then((date) {
                  if (date == DateTime.now()) {
                  } else {
                    setState(() {
                      _dateTime = date;
                    });
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget dateIsCorrect(DateTime date) {
    if (date == null) {
      return Text("No hay ninguna fecha seleccionada");
    } else if (date.day == DateTime.now().day && date.year == DateTime.now().year) {
      return Text("La fecha tiene que ser pasada", style: TextStyle(color: Colors.red),);
    } else {
      return Text(date.toString());
    }
  }

  Container buttonSection() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50.0,
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      margin: EdgeInsets.only(top: 20.0),
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: usernameController.text == "" ||
                      passwordController.text == "" ||
                      emailController.text == "" ||
                      phoneController.text == "" ||
                      membershipController.text == "" ||
                      _dateTime == null
                  ? null
                  : () async {
                      if (!_formKey.currentState.validate()) {
                        showMessage('Algunos campos del formulario son incorrectos', context);
                      } else {
                        if(_dateTime==null){
                          showMessage('La fecha de nacimiento es obligatoria', context);
                        } else {
                          signUp(
                              usernameController.text,
                              passwordController.text,
                              emailController.text,
                              phoneController.text,
                              membershipController.text,
                              _dateTime);
                        }
                      }

                    },
              child:
                  Text("Resgistrarse", style: TextStyle(color: Colors.white70)),
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
          Expanded(
            child: AlreadyHaveAnAccountCheck(
              login: false,
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return LoginPage();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
