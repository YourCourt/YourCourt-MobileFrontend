
import 'package:flutter/cupertino.dart';
import 'package:yourcourt/src/models/ImageOf.dart';


class Product extends ChangeNotifier{
  int id;
  String name;
  String productType;
  String description;
  int stock;
  int tax;
  double price;
  double bookPrice;
  double totalPrice;
  ImageOf image;

  Product({
    this.id,
    this.name,
    this.productType,
    this.description,
    this.stock,
    this.tax,
    this.price,
    this.bookPrice,
    this.totalPrice,
    this.image,

    notifyListeners()
  });

  Product.fromJson(Map<String, dynamic> json){
    id = json["id"];
    name = json["name"];
    productType = json["productType"];
    description = json["description"];
    stock = json["stock"];
    tax = json["tax"];
    price = json["price"];
    bookPrice = json["bookPrice"];
    totalPrice = json["totalPrice"];
    image = ImageOf.fromJson(json["image"]);

  }


}

