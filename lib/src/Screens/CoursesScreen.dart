import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yourcourt/src/Utiles/cabeceras.dart';
import 'package:yourcourt/src/Utiles/menu.dart';
import 'package:yourcourt/src/Utiles/principal_structure.dart';
import 'package:yourcourt/src/models/Course.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:yourcourt/src/utiles/functions.dart';

import 'InscriptionFormScreen.dart';

class Courses extends StatefulWidget {

  @override
  _CoursesState createState() => _CoursesState();
}

class _CoursesState extends State<Courses> {
  SharedPreferences sharedPreferences;

  @override
  Widget build(BuildContext context) {
    return Principal(context, sharedPreferences, appHeadboard(context, sharedPreferences), body(), MenuLateral());
  }

  Widget body() {
    return FutureBuilder <List<Course>>(
        future: getCourses(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return GridView.count(
              crossAxisCount: 2,
              children: [
                showCourses(snapshot.data),
              ]
            );
          } else {
            return Container(
              child: Text("No existen cursos disponibles"),
            );
          }
        }
    );
  }

  Widget showCourses(List<Course> courses){
    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: courses.length,
        itemBuilder: (BuildContext context, int index) {
          if(DateTime.now().isAfter(DateTime.parse(courses.elementAt(index).startDate))){
            return Column(
              children: [
                Text(courses
                    .elementAt(index)
                    .title, style: TextStyle(color: Colors.black),),
                Text(courses
                    .elementAt(index)
                    .description, style: TextStyle(color: Colors.black),),
                Text("Desde " + courses
                    .elementAt(index)
                    .startDate + " hasta " + courses
                    .elementAt(index)
                    .endDate, style: TextStyle(color: Colors.black),),
                ElevatedButton(
                    onPressed: (){

                      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) =>   InscriptionForm(courseId:courses
                          .elementAt(index).id ,)));
                    },
                    child: Text("Inscribirse", style: TextStyle(color: Colors.black),),)
              ],
            );
          } else {
            return Column(
              children: [
                Text(courses
                    .elementAt(index)
                    .title, style: TextStyle(color: Colors.black),),
                Text(courses
                    .elementAt(index)
                    .description, style: TextStyle(color: Colors.black),),
                Text(courses
                    .elementAt(index)
                    .startDate, style: TextStyle(color: Colors.black),),
                Text("Desde " + courses
                    .elementAt(index)
                    .startDate + " hasta " + courses
                    .elementAt(index)
                    .endDate, style: TextStyle(color: Colors.black),),
              ],
            );
          }
        }
    );

  }

  Future<List<Course>> getCourses() async {
    List<Course> courses = [];

    var jsonResponse;
    var response = await http.get(
        "https://dev-yourcourt-api.herokuapp.com/courses");
    if (response.statusCode == 200) {
      jsonResponse = transformUtf8(response.bodyBytes);
    }
    for (var item in jsonResponse) {

      courses.add(Course.fromJson(item));
    }
    return courses;

  }

}
