import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yourcourt/src/screens/bookingScreens/MyBooksScreen.dart';
import 'package:yourcourt/src/screens/inscriptionsScreens/CoursesScreen.dart';
import 'package:yourcourt/src/screens/bookingScreens/CourtsScreen.dart';
import 'package:http/http.dart' as http;
import 'package:yourcourt/src/screens/FacilitiesScreen.dart';
import 'package:yourcourt/src/screens/inscriptionsScreens/MyInscriptionsScreen.dart';
import 'package:yourcourt/src/screens/newsScreens/NewsScreen.dart';
import 'package:yourcourt/src/screens/transactionsScreens/ProductTransactionsScreen.dart';
import 'package:yourcourt/src/screens/transactionsScreens/ProductsScreen.dart';
import 'package:yourcourt/src/models/User.dart';


class MenuLateral extends StatefulWidget{

  @override
  _MenuLateralState createState() => _MenuLateralState();
  }

class _MenuLateralState extends State<MenuLateral>
    with WidgetsBindingObserver {

  var userActive;
//  SharedPreferences preferences;

/*  @override
  void initState() {
    super.initState();
  }*/

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: FutureBuilder (
          future: accDetails(),
          builder: (context, snapshot) {
            if (snapshot.connectionState==ConnectionState.done) {
              return Container(
                child:_ListaDatosDeUsuario(snapshot.data),
              );
          }
            return CircularProgressIndicator();
        },
      ),
    );
  }

  Future<User> accDetails() async {
    User userActive;
    var jsonResponse;

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    var token = sharedPreferences.getString("token");
    var response = await http.get(
        "https://dev-yourcourt-api.herokuapp.com/users/username/" + sharedPreferences.getString("username"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-type": "application/json"
        });

    jsonResponse = json.decode(response.body);

    userActive = User.fromJson(jsonResponse);

    return userActive;
  }

/*  Future<SharedPreferences> getSharedPreferenceInstance() async {
    preferences = await SharedPreferences.getInstance();
    return preferences;
  }*/

}

class _ListaDatosDeUsuario extends StatelessWidget {
  final User userActive;

  _ListaDatosDeUsuario(this.userActive);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        UserAccountsDrawerHeader(
          accountName: Text(userActive.username,
            style: TextStyle(color: Colors.black54),),
          accountEmail: Text(userActive.email, style: TextStyle(color: Colors.black54),),
          decoration: BoxDecoration(image: DecorationImage(
              image: NetworkImage(userActive.imageUrl),
              fit: BoxFit.cover
          )
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Color(0xFFDBA58F),
          ),
            child: Text(
              "Pistas", style: TextStyle(color: Colors.white),),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => CourtsPage()));
            }
        ),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Color(0xFFBB856E),
            ),
            child: Text(
              "Instalaciones", style: TextStyle(color: Colors.white),),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Facilities()));
            }
        ),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Color(0xFFDBA58F),
            ),
            child: Text(
              "Noticias", style: TextStyle(color: Colors.white),),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => NewsPage()));
            }
        ),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Color(0xFFBB856E),
            ),
            child: Text(
              "Productos", style: TextStyle(color: Colors.white),),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Products()));
            }
        ),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Color(0xFFDBA58F),
            ),
            child: Text(
              "Mis reservas", style: TextStyle(color: Colors.white),),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MyBooks()));
            }
        ),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Color(0xFFBB856E),
            ),
            child: Text(
              "Mis transacciones", style: TextStyle(color: Colors.white),),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ProductTransactions()));
            }
        ),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Color(0xFFDBA58F),
            ),
            child: Text(
              "Cursos", style: TextStyle(color: Colors.white),),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Courses()));
            }
        ),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Color(0xFFBB856E),
            ),
            child: Text(
              "Mis inscripciones", style: TextStyle(color: Colors.white),),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MyInscriptions()));
            }
        ),
      ],
    );
  }

  String getUsername(User data){
    return data.username;
  }

  String getEmail(User data){
    return data.email;
  }

  String getImage(User data){
    return data.imageUrl;
  }
}
