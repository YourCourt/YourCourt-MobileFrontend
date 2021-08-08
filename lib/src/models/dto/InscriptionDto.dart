
class InscriptionDto{
  String email;
  String name;
  String surnames;
  String observations;
  String phone;

  InscriptionDto({
    this.phone,
    this.email,
    this.name,
    this.observations,
    this.surnames,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = new Map<String, dynamic>();
    json['email'] = this.email;
    json['name'] = this.name;
    json['surnames'] = this.surnames;
    json['observations'] = this.observations;
    json['phone'] = this.phone;

    return json;

  }
}