import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

dynamic transformUtf8(List<int> bytes){
  var jsonResponse;
  String stringJson = Utf8Decoder().convert(bytes);
  jsonResponse = json.decode(stringJson);
  return jsonResponse;
}
