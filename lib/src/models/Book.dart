

import 'ProductBooking.dart';

class Book {
  int id;
  String endDate;
  String startDate;
  int userId;
  ProductBooking productBooking;
  int courtId;
  double productBookingSum;

  Book({
    this.id,
    this.endDate,
    this.startDate,
    this.userId,
    this.productBooking,
    this.courtId,
  });

  Book.fromJson(Map<String, dynamic> json){
    id = json["id"];
    endDate = json["endDate"];
    startDate = json["startDate"];
    userId = json["user"];
    if(json["productBooking"]==null){
      productBooking = null;
    } else {
      productBooking = ProductBooking.fromJson(json["productBooking"]);
    }
    courtId = json["court"];
    productBookingSum = json["productBookingSum"];

  }

}