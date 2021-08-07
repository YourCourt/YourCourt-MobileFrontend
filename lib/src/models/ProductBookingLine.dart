import 'package:flutter/cupertino.dart';

class ProductBookingLine {
  double discount;
  int productId;
  int quantity;


  ProductBookingLine({
    this.discount,
    this.productId,
    this.quantity,
  });

  ProductBookingLine.fromJson(Map<String, dynamic> json){
    discount = json["discount"];
    productId = json["productId"];
    quantity = json["quantity"];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = new Map<String, dynamic>();
    json['discount'] = this.discount;
    json['productId'] = this.productId;
    json['quantity'] = this.quantity;

    return json;

  }
}