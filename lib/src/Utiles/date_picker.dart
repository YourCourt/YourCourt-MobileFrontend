import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DatePicker extends StatefulWidget {

  @override
  _DatePickerState createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  DateTime _dateTime;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget> [
      Text(_dateTime ==null ? 'No hay ninguna fecha seleccionada' : _dateTime.toString()),
      ElevatedButton(
      child: Text("Seleccione una fecha"),
      onPressed: () {
        showDatePicker(context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now()
        ).then((date) {
          setState(() {
            _dateTime = date;
          });
        });
      },
      )
        ],
      ),
    );
  }
}
