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
    id = json["id"];
    bookingId = json["booking"];
    for (var line in json["lines"]){
      lines.add(ProductBookingLine.fromJson(line));
    }

  }
}