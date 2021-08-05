import 'package:flutter/cupertino.dart';

class UserProvider with ChangeNotifier {
  String _username;
  String _password;
  String _email;
  String _phone;
  String _imageUrl;

  String get username => _username;

  String get password => _password;

  String get email => _email;

  String get phone => _phone;

  String get imageUrl => _imageUrl;

  set imageUrl(String value) {
    _imageUrl = value;

    notifyListeners();
  }

  set phone(String value) {
    _phone = value;

    notifyListeners();
  }

  set email(String value) {
    _email = value;

    notifyListeners();
  }

  set password(String value) {
    _password = value;

    notifyListeners();
  }

  set username(String value) {
    _username = value;

    notifyListeners();
  }
}