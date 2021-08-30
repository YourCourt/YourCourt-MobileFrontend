import 'User.dart';

class Comment {
  int id;
  String content;
  String creationDate;
  User user;
  int newsId;

  Comment({
    this.creationDate,
    this.id,
    this.content,
    this.newsId,
    this.user,
  });

  Comment.fromJson(Map<String, dynamic> json){
    id = json["id"];
    content = json["content"];
    creationDate = json["creationDate"];
    user = User.fromJson(json["user"]);
    newsId = json["newsId"];
  }
}