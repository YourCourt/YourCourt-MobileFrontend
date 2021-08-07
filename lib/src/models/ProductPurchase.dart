

import 'ProductPurchaseLine.dart';

class ProductPurchase {

  int id;
  List<ProductPurchaseLine> lines;
  int userId;
  String creationDate;
  double productPurchaseSum;

  ProductPurchase({
    this.id,
    this.userId,
    this.lines,
    this.productPurchaseSum,
  });

  ProductPurchase.fromJson(Map<String, dynamic> json){
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