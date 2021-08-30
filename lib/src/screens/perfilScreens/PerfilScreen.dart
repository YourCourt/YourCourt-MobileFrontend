
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yourcourt/src/screens/loginScreens/LoginPage.dart';
import 'package:yourcourt/src/screens/perfilScreens/PerfilUpdateScreen.dart';
import 'package:yourcourt/src/utils/principal_structure.dart';
import 'package:yourcourt/src/utils/menu.dart';
import 'package:yourcourt/src/models/User.dart';
import 'package:yourcourt/src/utils/functions.dart';
import 'package:yourcourt/src/utils/headers.dart';
import 'package:http/http.dart' as http;

class MyProfile extends StatefulWidget {

  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {

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

  final TextEditingController emailController = new TextEditingController();
  final TextEditingController phoneController = new TextEditingController();


  Widget textSection() {
    return FutureBuilder <User> (
      future: getUser(),
        builder: (context, snapshot) {
        if(snapshot.connectionState==ConnectionState.done){
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    height: 160,
                    width: 160,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(snapshot.data.imageUrl),
                          fit: BoxFit.cover
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                  TextFormField(
                    readOnly: true,
                    initialValue: snapshot.data.username,
                    cursorColor: Colors.black,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      icon: Icon(Icons.account_circle_rounded, color: Colors.black),
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      hintStyle: TextStyle(color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    readOnly: true,
                    initialValue: snapshot.data.email,
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
                    readOnly: true,
                    initialValue: snapshot.data.phone,
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
                      icon: Icon(Icons.supervised_user_circle, color: Colors.black),
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
                      icon: Icon(Icons.calendar_today, color: Colors.black),
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
      child: FutureBuilder <User>(
        future: getUser(),
        builder: (context, snapshot){
          if(snapshot.connectionState==ConnectionState.done){
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Color(0xFFDBA58F),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => PerfilUpdate(user: snapshot.data,)));
              },
              child: Text("Actualizar perfil", style: TextStyle(color: Colors.white)),
            );
          }
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Color(0xFFDBA58F),
            ),
            onPressed: () {
            },
            child: Text("Actualizar perfil", style: TextStyle(color: Colors.white70)),
          );
        }
      )
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
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-type": "application/json"
        });

    if (response.statusCode == 200) {
      jsonResponse = transformUtf8(response.bodyBytes);
    }
    user = User.fromJson(jsonResponse);

    return user;
  }


}
