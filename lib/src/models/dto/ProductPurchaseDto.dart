import 'ProductPurchaseLineDto.dart';

class ProductPurchaseDto {

  List<ProductPurchaseLineDto> lines;
  int userId;

  ProductPurchaseDto({
    this.userId,
    this.lines,
  });

  ProductPurchaseDto.fromJson(Map<String, dynamic> json){
    List<ProductPurchaseLineDto> l = [];
    for (var item in json["lines"]) {
      l.add(ProductPurchaseLineDto.fromJson(item));
    }
    lines = l;
    userId = json["user"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = new Map<String, dynamic>();
    List<Map<String, dynamic>> l = [];
    for(var item in this.lines){
      l.add(item.toJson());
    }
    json['lines'] = l;
    json['user'] = this.userId;

    return json;

  }
}