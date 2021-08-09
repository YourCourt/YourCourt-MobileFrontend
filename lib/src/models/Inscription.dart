import 'Course.dart';

class Inscription{
  int id;
  int userId;
  String email;
  String name;
  String surnames;
  String observations;
  String phone;
  Course course;

  Inscription({
    this.phone,
    this.email,
    this.name,
    this.observations,
    this.surnames,
  });

  Inscription.fromJson(Map<String, dynamic> json){
    id = json["id"];
    userId = json["userId"];
    email = json["email"];
    name = json["name"];
    surnames = json["surnames"];
    observations = json["observations"];
    phone = json["phone"];
    course = Course.fromJson(json["course"]);

  }
}