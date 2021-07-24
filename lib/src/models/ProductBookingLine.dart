class ProductBookingLine {
  int quantity;
  int discount;
  int productId;

  ProductBookingLine({
    this.quantity,
    this.discount,
    this.productId,
  });

  ProductBookingLine.fromJson(Map<String, dynamic> json){
    quantity = json["quantity"];
    discount = json["discount"];
    productId = json["productId"];
  }
}