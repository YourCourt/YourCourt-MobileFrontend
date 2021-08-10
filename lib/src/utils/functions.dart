import 'dart:convert';

dynamic transformUtf8(List<int> bytes){
  var jsonResponse;
  String stringJson = Utf8Decoder().convert(bytes);
  jsonResponse = json.decode(stringJson);
  return jsonResponse;
}
