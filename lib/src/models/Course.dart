class Course {
  int id;
  String title;
  String description;
  String startDate;
  String endDate;

  Course({
    this.id,
    this.description,
    this.title,
    this.startDate,
    this.endDate
  });

  Course.fromJson(Map<String, dynamic> json){
    id = json["id"];
    title = json["title"];
    description = json["description"];
    startDate = json["startDate"];
    endDate = json["endDate"];
  }

}