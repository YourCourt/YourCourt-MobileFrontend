import 'ImageOf.dart';

class Court {
  int id;
  String name;
  String description;
  String courtType;
  ImageOf image;

  Court({
    this.name,
    this.description,
    this.courtType,
    this.image,
  });

  Court.fromJson(Map<String, dynamic> json){
    id = json["id"];
    name = json["name"];
    description = json["description"];
    courtType = json["courtType"];
    image = ImageOf.fromJson(json["image"]);

  }

}