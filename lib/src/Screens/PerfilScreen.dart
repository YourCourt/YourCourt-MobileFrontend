import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yourcourt/src/Utiles/cabeceras.dart';
import 'package:yourcourt/src/Utiles/principal_structure.dart';
import 'package:yourcourt/src/Utiles/menu.dart';
import 'package:yourcourt/src/models/User.dart';
import 'login/LoginPage.dart';
import 'package:http/http.dart' as http;

class MyProfile extends StatefulWidget {

  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {

  bool _isLoading = false;
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: textSection(),
          ),
          buttonSection(),
        ],
      )
    );
  }

  updateUser(String email, phone) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    Map data = {
      "phone" : phone,
      "email" : email,
    };

    var token = sharedPreferences.getString("token");
    var response = await http.put("https://dev-yourcourt-api.herokuapp.com/users/"+sharedPreferences.getInt("id").toString(),
        body: json.encode(data),
        headers: {
          "Authorization": "Bearer ${token}",
          "Accept": "application/json",
          "Content-type": "application/json"
        });

    if(response.statusCode==201){
      _isLoading = true;
      print("Perfil de usuario actualizado");
    } else{
      setState(() {
        _isLoading = false;
      });
      print("Se ha producido un error" + response.statusCode.toString());
    }

  }

  final TextEditingController emailController = new TextEditingController();
  final TextEditingController phoneController = new TextEditingController();

  Widget textSection() {
    return FutureBuilder(
      future: getUser(),
        builder: (context, snapshot) {
        if(snapshot.connectionState==ConnectionState.done){
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    readOnly: true,
                    initialValue: snapshot.data.username,
                    cursorColor: Colors.black,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      icon: Icon(Icons.verified_user, color: Colors.black),
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      hintStyle: TextStyle(color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    controller: emailController,
                    cursorColor: Colors.black,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      icon: Icon(Icons.email, color: Colors.black),
                      hintText: snapshot.data.email,
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      hintStyle: TextStyle(color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    controller: phoneController,
                    cursorColor: Colors.black,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      icon: Icon(Icons.phone, color: Colors.black),
                      hintText: snapshot.data.phone,
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      hintStyle: TextStyle(color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    initialValue: snapshot.data.membershipNumber,
                    readOnly: true,
                    cursorColor: Colors.black,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      icon: Icon(Icons.phone_android, color: Colors.black),
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      hintStyle: TextStyle(color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    initialValue: snapshot.data.birthDate,
                    readOnly: true,
                    cursorColor: Colors.black,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
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
        } else {
          return CircularProgressIndicator(

          );
        }
      }
    );
  }

  Widget buttonSection() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 40.0,
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      margin: EdgeInsets.only(top: 15.0),
      child: ElevatedButton(
        onPressed: emailController.text == "" && phoneController.text == "" ? null : () {
          setState(() {
            _isLoading = true;
          });
          updateUser(emailController.text, phoneController.text);
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

  Future<User> getUser() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    User user;

    var jsonResponse;
    var token = sharedPreferences.getString("token");
    var response = await http.get(
        "https://dev-yourcourt-api.herokuapp.com/users/username/"+sharedPreferences.getString("username"),
        headers: {
          "Authorization": "Bearer ${token}",
          "Accept": "application/json",
          "Content-type": "application/json"
        });

    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
    }
    user = User.fromJson(jsonResponse);

    return user;
  }
}
