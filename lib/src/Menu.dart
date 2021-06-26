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
              accountName: Text(preferences.getString("username"), style: TextStyle(color: Colors.purple),),
              decoration: BoxDecoration(
          ))
        ],
      ),
    );
  }

  Future<SharedPreferences> getSharedPreferenceInstance() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences;
  }

}
