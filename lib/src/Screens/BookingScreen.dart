import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yourcourt/src/Utiles/cabeceras.dart';
import 'package:yourcourt/src/Utiles/principal_structure.dart';
import 'package:yourcourt/src/Utiles/menu.dart';
import 'package:yourcourt/src/models/BookingDate.dart';
import 'package:yourcourt/src/models/Court.dart';
import 'package:http/http.dart' as http;

import 'BookConfirmationScreen.dart';
import 'LoginPage.dart';
import 'PerfilScreen.dart';

class BookingPage extends StatefulWidget {

  final Court court;

  const BookingPage({Key key, this.court}) : super(key: key);

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {

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

  String _date;

  BookDate _selected_hour;

  List<BookDate> possibiltyHours = [
    BookDate('8:30', '10:00'),
    BookDate('10:00', '11:00'),
    BookDate('11:00', '12:00'),
    BookDate('12:00', '13:00'),
    BookDate('13:00', '14:00'),
    BookDate('14:00', '15:00'),
    BookDate('15:00', '16:00'),
    BookDate('16:00', '17:00'),
    BookDate('17:00', '18:00'),
    BookDate('18:00', '19:00'),
    BookDate('19:00', '20:00'),
    BookDate('20:00', '21:00'),
    BookDate('21:00', '22:00'),
  ];

  @override
  Widget build(BuildContext context) {
    return Principal(context, sharedPreferences, appHeadboard(context, sharedPreferences), body(), MenuLateral());
  }

  Widget body() {
    return Column(
      children: [
        Text('Fecha de reserva:', textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 20,
              color: Colors.black
          ),
        ),
        SizedBox(height: 10.0),
        Text(_date == null
            ? 'No hay ninguna fecha seleccionada'
            : _date),
        SizedBox(height: 10.0),
        ElevatedButton(
          child: Text("Seleccione el día de la reserva"),
          onPressed: () {
            showDatePicker(context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(Duration(days: 7))
            ).then((date) {
              setState(() {
                _date = DateFormat('yyyy-MM-dd').format(date);
              });
            });
          },
        ),

        seleccionHora(_date),

      ],
    );
  }

  String getHourMessage(List<String> horas){
    for (var i in horas){
      return i +'\n';
    }
  }
  Future<List<BookDate>> getAvailableHours(int courtId, String date) async {

    List<BookDate> unAvailableHours = [];
    List<BookDate> availableHours = possibiltyHours;

    print(date);

    var jsonResponse;
    var response = await http.get(
        "https://dev-yourcourt-api.herokuapp.com/bookings/date?courtId="+ courtId.toString() + "&date=" + date,
        headers: {
          "Accept": "application/json",
          "Content-type": "application/json"
        });

    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
    }
    for (var book in jsonResponse){

      unAvailableHours.add(BookDate(book[0], book[1]));

    }


    availableHours.retainWhere((element) => !unAvailableHours.contains(element));

    return availableHours;

  }

  List<Widget> showAvailableHours(List<BookDate> availableHours) {
    List<Widget> hours = [];

    for (var hour in availableHours) {
      hours.add(
          ListTile(
            leading: new Icon(Icons.wysiwyg),
            title: Text(hour.startHour+" -> "+hour.endHour, style: TextStyle(color: Colors.black),),
            onTap: () {
              setState(() {
                _selected_hour=hour;
                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => BookConfirmation(date: _date, hour: _selected_hour, court: widget.court,)));
              });
            },
          )
      );
    }

    return hours;
  }

  Widget seleccionHora(String date){
    if (date!= null){
      return FutureBuilder(
          future: getAvailableHours(widget.court.id, date),
          builder: (context, snapshot){
            if(snapshot.hasData){
              if(_selected_hour!=null){
                Text(_selected_hour.startHour+" -> "+_selected_hour.endHour, style: TextStyle(color: Colors.black),);
              }
              else{
                return ElevatedButton(
                  child: Text("Seleccionar hora", style: TextStyle(color: Colors.white),),
                  onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: showAvailableHours(snapshot.data),
                          );
                        }
                    );
                  }
                );
              }
            } else {
              return Container(
                child: Text("No disponible", style: TextStyle(color: Colors.black),),
              );
            }
          }
      );
    }
    else {
      return Container(
        child: Text("Debe seleccionar un día para poder seleccionar la hora"),
      );
    }
  }
}

