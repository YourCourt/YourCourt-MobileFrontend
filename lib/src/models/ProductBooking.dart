import 'ProductBookingLine.dart';

class ProductBooking {
  int id;
  int bookingId;
  List<ProductBookingLine> lines;

  ProductBooking({
    this.bookingId,
    this.lines,
  });

  ProductBooking.fromJson(Map<String, dynamic> json){
    List<ProductBookingLine> l = [];
    id = json["id"];
    bookingId = json["booking"];
    for (var line in json["lines"]){
      l.add(ProductBookingLine.fromJson(line));
    }
    lines = l;
  }
}