import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yourcourt/src/Screens/LoginPage.dart';
import 'package:yourcourt/src/Screens/PerfilScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'menu.dart';

Widget Principal(BuildContext context, SharedPreferences sharedPreferences, Widget appHeadboard, Widget body, Widget drawer){
  return Scaffold(
    appBar: appHeadboard,
    body: body,
    drawer: drawer,
  );
}