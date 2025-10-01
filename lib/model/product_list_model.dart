// To parse this JSON data, do
//
//     final productListModel = productListModelFromJson(jsonString);

import 'dart:convert';

import 'package:astro_partner_app/utils/enum.dart';

ProductListModel productListModelFromJson(String str) =>
    ProductListModel.fromJson(json.decode(str));

String productListModelToJson(ProductListModel data) =>
    json.encode(data.toJson());

class ProductListModel {
  bool? success;
  String? message;
  Data? data;
  String? currencySymbol;
  RequestStatus requestStatus;

  ProductListModel({
    this.success,
    this.message,
    this.data,
    this.currencySymbol,
    this.requestStatus = RequestStatus.initial,
  });

  factory ProductListModel.fromJson(Map<String, dynamic> json) =>
      ProductListModel(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        currencySymbol: json["currency_symbol"],
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
    "currency_symbol": currencySymbol,
  };
}

class Data {
  int? sessionId;
  List<Product>? products;
  int? totalProducts;
  int? selectedCount;

  Data({this.sessionId, this.products, this.totalProducts, this.selectedCount});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    sessionId: json["session_id"],
    products: json["products"] == null
        ? []
        : List<Product>.from(json["products"]!.map((x) => Product.fromJson(x))),
    totalProducts: json["total_products"],
    selectedCount: json["selected_count"],
  );

  Map<String, dynamic> toJson() => {
    "session_id": sessionId,
    "products": products == null
        ? []
        : List<dynamic>.from(products!.map((x) => x.toJson())),
    "total_products": totalProducts,
    "selected_count": selectedCount,
  };
}

class Product {
  int? id;
  String? name;
  String? description;
  String? price;
  String? sellingPrice;
  String? priceInDolor;
  String? sellingPriceInDolar;
  int? categoryId;
  bool? isSelected;
  DateTime? createdAt;
  DateTime? updatedAt;

  Product({
    this.id,
    this.name,
    this.description,
    this.price,
    this.sellingPrice,
    this.priceInDolor,
    this.sellingPriceInDolar,
    this.categoryId,
    this.isSelected,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json["id"],
    name: json["name"],
    description: json["description"],
    price: json["price"],
    sellingPrice: json["selling_price"],
    priceInDolor: json["price_in_dolor"],
    sellingPriceInDolar: json["selling_price_in_dolar"],
    categoryId: json["category_id"],
    isSelected: json["is_selected"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "price": price,
    "selling_price": sellingPrice,
    "price_in_dolor": priceInDolor,
    "selling_price_in_dolar": sellingPriceInDolar,
    "category_id": categoryId,
    "is_selected": isSelected,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
