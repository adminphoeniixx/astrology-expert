// To parse this JSON data, do
//
//     final reviewListModel = reviewListModelFromJson(jsonString);

import 'dart:convert';

import 'package:astro_partner_app/utils/enum.dart';

ReviewListModel reviewListModelFromJson(String str) =>
    ReviewListModel.fromJson(json.decode(str));

String reviewListModelToJson(ReviewListModel data) =>
    json.encode(data.toJson());

class ReviewListModel {
  bool? success;
  Astrologer? astrologer;
  List<Rating>? ratings;
  String? currencySymbol;
  RequestStatus requestStatus;

  ReviewListModel({
    this.success,
    this.astrologer,
    this.ratings,
    this.currencySymbol,
    this.requestStatus = RequestStatus.initial,
  });

  factory ReviewListModel.fromJson(Map<String, dynamic> json) =>
      ReviewListModel(
        success: json["success"],
        astrologer: json["astrologer"] == null
            ? null
            : Astrologer.fromJson(json["astrologer"]),
        ratings: json["ratings"] == null
            ? []
            : List<Rating>.from(
                json["ratings"]!.map((x) => Rating.fromJson(x)),
              ),
        currencySymbol: json["currency_symbol"],
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "astrologer": astrologer?.toJson(),
    "ratings": ratings == null
        ? []
        : List<dynamic>.from(ratings!.map((x) => x.toJson())),
    "currency_symbol": currencySymbol,
  };
}

class Astrologer {
  int? id;
  String? name;
  int? rating;
  int? totalRatings;

  Astrologer({this.id, this.name, this.rating, this.totalRatings});

  factory Astrologer.fromJson(Map<String, dynamic> json) => Astrologer(
    id: json["id"],
    name: json["name"],
    rating: json["rating"],
    totalRatings: json["total_ratings"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "rating": rating,
    "total_ratings": totalRatings,
  };
}

class Rating {
  String? id;
  int? orderId;
  String? consultType;
  String? servicveType;
  int? rating;
  String? description;
  DateTime? createdAt;
  Customer? customer;

  Rating({
    this.id,
    this.orderId,
    this.consultType,
    this.servicveType,
    this.rating,
    this.description,
    this.createdAt,
    this.customer,
  });

  factory Rating.fromJson(Map<String, dynamic> json) => Rating(
    id: json["id"],
    orderId: json["order_id"],
    consultType: json["consult_type"],
    servicveType: json["servicve_type"],
    rating: json["rating"],
    description: json["description"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    customer: json["customer"] == null
        ? null
        : Customer.fromJson(json["customer"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_id": orderId,
    "consult_type": consultType,
    "servicve_type": servicveType,
    "rating": rating,
    "description": description,
    "created_at": createdAt?.toIso8601String(),
    "customer": customer?.toJson(),
  };
}

class Customer {
  int? id;
  String? name;

  Customer({this.id, this.name});

  factory Customer.fromJson(Map<String, dynamic> json) =>
      Customer(id: json["id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}
