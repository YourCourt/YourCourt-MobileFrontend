

import 'ProductPurchaseLine.dart';

class ProductPurchaseDto {

  int id;
  List<ProductPurchaseLine> lines;
  int userId;
  String creationDate;
  double productPurchaseSum;

  ProductPurchaseDto({
    this.id,
    this.userId,
    this.lines,
    this.productPurchaseSum,
  });

  ProductPurchaseDto.fromJson(Map<String, dynamic> json){
    id = json["id"];
    List<ProductPurchaseLine> l = [];
    for (var item in json["lines"]) {
      l.add(ProductPurchaseLine.fromJson(item));
    }
    lines = l;
    userId = json["user"];
    creationDate = json["creationDate"];
    productPurchaseSum = json["productPurchaseSum"];
  }
}