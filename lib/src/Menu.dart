import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/src/widgets/framework.dart';

class MenuLateral extends StatefulWidget{

  @override
  _MenuLateralState createState() => _MenuLateralState();
  }

class _MenuLateralState extends State<MenuLateral>
    with WidgetsBindingObserver {

  SharedPreferences preferences;

  @override
  void initState() {
    getSharedPreferenceInstance().then((response) {
      setState(() {
        preferences = response ?? "";
      });
    });
  }
  
  Widget build(BuildContext context) {
    return new Drawer(
      child: ListView(
        children: <Widget>[
          new UserAccountsDrawerHeader(
              accountName: Text(preferences.getString("username"), style: TextStyle(color: Colors.black54),),
              decoration: BoxDecoration(image: DecorationImage(
                image: NetworkImage("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR8pDaYsgZdEb5yQgxaeN-RFnBppSslZiNNMg&usqp=CAU"),
                fit: BoxFit.cover
              )
          ),
          ),
          Ink(
            color: Colors.lightBlueAccent,
            child: new ListTile(
              title: Text("Inicio", style: TextStyle(color: Colors.white),),
            ),
          ),

          new ListTile(
            title: Text("Pistas"),
          ),
          Ink(
            color: Colors.lightBlueAccent,
            child: new ListTile(
              title: Text("Instalaciones", style: TextStyle(color: Colors.white),),
            ),
          ),
          new ListTile(
            title: Text("Noticias"),
          ),
          Ink(
            color: Colors.lightBlueAccent,
            child: new ListTile(
              title: Text("Escuela", style: TextStyle(color: Colors.white),),
            ),
          ),

        ],
      ),
    );
  }

  Future<SharedPreferences> getSharedPreferenceInstance() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences;
  }

}
