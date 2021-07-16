class ImageOf {
  int id;
  String name;
  String imageUrl;

  ImageOf({
    this.name,
    this.imageUrl,
  });

  ImageOf.fromJson(Map<String, dynamic> json){
    id = json["id"];
    name = json["name"];
    imageUrl = json["imageUrl"];

  }
}