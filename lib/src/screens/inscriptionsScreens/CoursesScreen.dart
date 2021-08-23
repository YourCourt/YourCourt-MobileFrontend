import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yourcourt/src/screens/loginScreens/LoginPage.dart';
import 'package:yourcourt/src/utils/menu.dart';
import 'package:yourcourt/src/utils/principal_structure.dart';
import 'package:yourcourt/src/models/Course.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:yourcourt/src/utils/functions.dart';
import 'package:yourcourt/src/utils/headers.dart';

import 'InscriptionFormScreen.dart';


class Courses extends StatefulWidget {
  @override
  _CoursesState createState() => _CoursesState();
}

class _CoursesState extends State<Courses> {
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
    return FutureBuilder<List<Course>>(
        future: getCourses(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(children: [
              Expanded(
                child: showCourses(snapshot.data),
              ),
            ]);
          } else {
            return Container(
              child: Text("No existen cursos disponibles"),
            );
          }
        });
  }

  Widget showCourses(List<Course> courses) {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: courses.length,
        itemBuilder: (BuildContext context, int index) {
          if (DateTime.now()
              .isBefore(DateTime.parse(courses.elementAt(index).startDate))) {
            return Column(
              children: [
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  courses.elementAt(index).title,
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 20.0),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Text(
                  courses.elementAt(index).description,
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      " Desde ",
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300),
                    ),
                    Text(
                      courses.elementAt(index).startDate,
                      style: TextStyle(color: Colors.black),
                    ),
                    Text(
                      " hasta ",
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300),
                    ),
                    Text(
                      courses.elementAt(index).endDate,
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10.0,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFFDBA58F),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => InscriptionForm(
                                  courseId: courses.elementAt(index).id,
                                )));
                  },
                  child: Text(
                    "Inscribirse",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
              ],
            );
          } else {
            return Column(
              children: [
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  courses.elementAt(index).title,
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 20.0),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Text(
                  courses.elementAt(index).description,
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      " Desde ",
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300),
                    ),
                    Text(
                      courses.elementAt(index).startDate,
                      style: TextStyle(color: Colors.black),
                    ),
                    Text(
                      " hasta ",
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300),
                    ),
                    Text(
                      courses.elementAt(index).endDate,
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20.0,
                ),
              ],
            );
          }
        });
  }

  Future<List<Course>> getCourses() async {
    List<Course> courses = [];

    var jsonResponse;
    var response =
        await http.get("https://dev-yourcourt-api.herokuapp.com/courses");
    if (response.statusCode == 200) {
      jsonResponse = transformUtf8(response.bodyBytes);
    }
    for (var item in jsonResponse) {
      courses.add(Course.fromJson(item));
    }
    return courses;
  }
}
