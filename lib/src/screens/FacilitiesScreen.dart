import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yourcourt/src/models/Facility.dart';
import 'package:yourcourt/src/utils/functions.dart';
import 'package:yourcourt/src/utils/headers.dart';
import 'package:yourcourt/src/utils/menu.dart';
import 'package:yourcourt/src/utils/principal_structure.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'login/LoginPage.dart';

class Facilities extends StatefulWidget {

  @override
  _FacilitiesState createState() => _FacilitiesState();
}

class _FacilitiesState extends State<Facilities> {
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

  Widget body(){
    return Center(
        child: FutureBuilder <List<Facility>> (
          future: getFacilities(),
          builder: (context, snapshot) {
            if(snapshot.connectionState==ConnectionState.done){
              return listFacilities(snapshot.data);
            }
            return CircularProgressIndicator();
          },
        )
    );
  }

  Widget listFacilities(List<Facility> facilities){

    if(facilities.length>0){
      return ListView.builder(
          itemCount: facilities.length,
          itemBuilder: (context, int index){
            return Column(
              children: [
                Image(
                  image: NetworkImage(facilities.elementAt(index).image.imageUrl),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(facilities.elementAt(index).name, style: TextStyle(color: Colors.black),),
                SizedBox(
                  height: 5,
                ),
                Text(facilities.elementAt(index).description, style: TextStyle(color: Colors.black),),
                Text(facilities.elementAt(index).facilityType.typeName, style: TextStyle(color: Colors.black),),

              ],
            );
          }
      );
    } else {
      return Container(
        child: Text("No hay instalaciones"),
      );
    }

  }


  Future<List<Facility>> getFacilities() async {
    List<Facility> facilities = [];

    var jsonResponse;
    var response = await http.get(
        "https://dev-yourcourt-api.herokuapp.com/facilities");
    if (response.statusCode == 200) {
      jsonResponse = transformUtf8(response.bodyBytes);
    }
    for (var item in jsonResponse) {

      facilities.add(Facility.fromJson(item));
    }
    return facilities;
  }



}
