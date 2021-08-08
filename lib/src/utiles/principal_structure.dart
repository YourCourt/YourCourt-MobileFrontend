import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget Principal(BuildContext context, SharedPreferences sharedPreferences, Widget appHeadboard, Widget body, Widget drawer){
  return Scaffold(
    resizeToAvoidBottomInset: false,
    appBar: appHeadboard,
    body: body,
    drawer: drawer,
  );
}