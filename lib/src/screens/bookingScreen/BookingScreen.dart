
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yourcourt/src/models/BookingDate.dart';
import 'package:yourcourt/src/models/Court.dart';
import 'package:http/http.dart' as http;
import 'package:yourcourt/src/utils/headers.dart';
import 'package:yourcourt/src/utils/functions.dart';
import 'package:yourcourt/src/utils/menu.dart';
import 'package:yourcourt/src/utils/principal_structure.dart';

import 'BookConfirmationScreen.dart';
import '../login/LoginPage.dart';

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

  @override
  Widget build(BuildContext context) {
    return principal(context, sharedPreferences, appHeadboard(context, sharedPreferences), body(), MenuLateral());
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
        SelectHour(date: _date, court: widget.court),

      ],
    );
  }

}


class SelectHour extends StatefulWidget {

  final String date;
  final Court court;

  const SelectHour({Key key, this.date, this.court,}) : super(key: key);

  @override
  _SelectHourState createState() => _SelectHourState();
}

class _SelectHourState extends State<SelectHour> {

  BookDate _selectedHour;

  List<BookDate> possibilityHours = [
    BookDate('08:30', '10:00'),
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
    if (widget.date != null) {
      return FutureBuilder(
          future: getAvailableHours(widget.court.id, widget.date),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (_selectedHour != null) {
                Text(_selectedHour.startHour + " -> " + _selectedHour.endHour,
                  style: TextStyle(color: Colors.black),);
              }
              else {
                return ElevatedButton(
                    child: Text("Seleccionar hora",
                      style: TextStyle(color: Colors.white),),
                    onPressed: () {
                      showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          builder: (context) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: showAvailableHours(context, snapshot
                                  .data),
                            );
                          }
                      );
                    }
                );
              }
            }
            return CircularProgressIndicator();
          }
      );
    }
    return Container(
      child: Text("Debe seleccionar una fecha para poder seleccionar la hora",
        style: TextStyle(color: Colors.black),),
    );
  }

  Future<List<BookDate>> getAvailableHours(int courtId, String date) async {
    List<BookDate> availableHours = possibilityHours;

    print(DateTime.now());
    if (DateTime.now().toString().contains(date)) {
      availableHours.removeWhere((element) =>
      getDoubleNumber(element.startHour) < DateTime
          .now()
          .hour
          .toDouble());
    }

    var jsonResponse;
    var response = await http.get(
        "https://dev-yourcourt-api.herokuapp.com/bookings/date?courtId=" +
            courtId.toString() + "&date=" + date,
        headers: {
          "Accept": "application/json",
          "Content-type": "application/json"
        });

    if (response.statusCode == 200) {
      jsonResponse = transformUtf8(response.bodyBytes);
    }
    for (var book in jsonResponse) {
      availableHours.remove(BookDate(book[0], book[1]));
    }

    return availableHours;
  }

  List<Widget> showAvailableHours(BuildContext context,
      List<BookDate> availableHours) {
    List<Widget> hours = [];

    for (var hour in availableHours) {
      hours.add(
          Expanded(
            child: ListTile(
              leading: new Icon(Icons.wysiwyg),
              title: Text(hour.startHour + " -> " + hour.endHour,
                style: TextStyle(color: Colors.black),),
              onTap: () {
                _selectedHour = hour;
                Navigator.push(context, MaterialPageRoute(
                    builder: (BuildContext context) => BookConfirmation(
                      date: widget.date, hour: _selectedHour, court: widget.court,)));
              },
            ),
          )
      );
    }

    return hours;
  }

  double getDoubleNumber(String number) {
    List<String> array = [];
    array = number.split(":");
    String numberToParse = array[0].trim() + "." + array[1].trim();
    double numberToDouble = double.parse(numberToParse);
    return numberToDouble;
  }
}

