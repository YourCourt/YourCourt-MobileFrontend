
import 'package:flutter/material.dart';

showMessage(String message, BuildContext context){
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}