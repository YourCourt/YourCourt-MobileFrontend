class ProductPurchaseLine{
  int id;
  double discount;
  int productId;
  int quantity;

  ProductPurchaseLine({
    this.id,
    this.discount,
    this.productId,
    this.quantity,
  });


  ProductPurchaseLine.fromJson(Map<String, dynamic> json){
    id = json["id"];
    discount = json["discount"];
    productId = json["productId"];
    quantity = json["quantity"];
  }

}