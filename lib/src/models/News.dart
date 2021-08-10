import 'Comment.dart';
import 'ImageOf.dart';

class News {
  int id;
  String name;
  ImageOf image;
  String description;
  String creationDate;
  String editionDate;
  List<Comment> comments;

  News({
    this.description,
    this.name,
    this.id,
    this.comments,
    this.creationDate,
    this.editionDate,
    this.image
  });

  News.fromJson(Map<String, dynamic> json){
    id = json["id"];
    name = json["name"];
    image = ImageOf.fromJson(json["image"]);
    description = json["description"];
    creationDate = json["creationDate"];
    editionDate = json["editionDate"];

    List<Comment> l = [];
    for (var item in json["comments"]) {
      l.add(Comment.fromJson(item));
    }
    comments = l;
  }

}

