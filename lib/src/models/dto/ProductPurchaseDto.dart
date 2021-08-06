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
}