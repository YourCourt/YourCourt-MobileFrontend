class User{

  int id;
  String username;
  String email;
  String creationDate;
  String birthDate;
  String membershipNumber;
  String phone;
  String imageUrl;

  User({
    this.username,
    this.birthDate,
    this.email,
    this.membershipNumber,
    this.phone,
    this.imageUrl,
  });

  User.fromJson(Map<String, dynamic> json){
    id = json["id"];
    username = json["username"];
    email = json["email"];
    creationDate = json["creationDate"];
    birthDate = json["birthDate"];
    membershipNumber = json["membershipNumber"];
    phone = json["phone"];
    imageUrl = json["imageUrl"];
  }

}