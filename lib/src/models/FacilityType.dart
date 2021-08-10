class FacilityType {
  int id;
  String typeName;

  FacilityType({
    this.id,
    this.typeName,
  });

  FacilityType.fromJson(Map<String, dynamic> json){
    id = json["id"];
    typeName = json["typeName"];

  }
}