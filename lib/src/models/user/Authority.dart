class Authority{
  String role;


  Authority({
    this.role,
  });

  Authority.fromJson(Map<String, dynamic> json){
    role = json["authority"];
  }

}