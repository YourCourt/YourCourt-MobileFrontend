
class CommentDto {

  String content;
  int newsId;

  CommentDto({
    this.content,
    this.newsId,
  });

  CommentDto.fromJson(Map<String, dynamic> json){
    content = json["content"];
    newsId = json["newsId"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = new Map<String, dynamic>();
    json['content'] = this.content;
    json['newsId'] = this.newsId;

    return json;

  }
}