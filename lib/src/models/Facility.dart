import 'FacilityType.dart';
import 'ImageOf.dart';

class Facility {
  int id;
  String name;
  ImageOf image;
  String description;
  FacilityType facilityType;

  Facility({
    this.facilityType,
    this.id,
    this.description,
    this.image,
    this.name,
  });

  Facility.fromJson(Map<String, dynamic> json){
    id = json["id"];
    name = json["name"];
    image = ImageOf.fromJson(json["image"]);
    description = json["description"];
    facilityType = FacilityType.fromJson(json["facilityType"]);

  }
}