// To parse this JSON data, do
//
//     final sessionsModel = sessionsModelFromJson(jsonString);

import 'dart:convert';

import 'package:astro_partner_app/utils/enum.dart';

SessionsModel sessionsModelFromJson(String str) =>
    SessionsModel.fromJson(json.decode(str));

String sessionsModelToJson(SessionsModel data) => json.encode(data.toJson());

class SessionsModel {
  bool? success;
  String? message;
  Data? data;
  String? currencySymbol;
  RequestStatus requestStatus;

  SessionsModel({
    this.success,
    this.message,
    this.data,
    this.currencySymbol,
    this.requestStatus = RequestStatus.initial,
  });

  factory SessionsModel.fromJson(Map<String, dynamic> json) => SessionsModel(
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
  Sessions? sessions;
  List<Product>? products;
  Slots? slots;
  DateTime? todayDate;
  List<ServiceTypeElement>? serviceTypes;
  ServiceCounts? serviceCounts;
  String? currentFilter;

  Data({
    this.sessions,
    this.products,
    this.slots,
    this.todayDate,
    this.serviceTypes,
    this.serviceCounts,
    this.currentFilter,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    sessions: json["sessions"] == null
        ? null
        : Sessions.fromJson(json["sessions"]),
    products: json["products"] == null
        ? []
        : List<Product>.from(json["products"]!.map((x) => Product.fromJson(x))),
    slots: json["slots"] == null ? null : Slots.fromJson(json["slots"]),
    todayDate: json["today_date"] == null
        ? null
        : DateTime.parse(json["today_date"]),
    serviceTypes: json["service_types"] == null
        ? []
        : List<ServiceTypeElement>.from(
            json["service_types"]!.map((x) => ServiceTypeElement.fromJson(x)),
          ),
    serviceCounts: json["service_counts"] == null
        ? null
        : ServiceCounts.fromJson(json["service_counts"]),
    currentFilter: json["current_filter"],
  );

  Map<String, dynamic> toJson() => {
    "sessions": sessions?.toJson(),
    "products": products == null
        ? []
        : List<dynamic>.from(products!.map((x) => x.toJson())),
    "slots": slots?.toJson(),
    "today_date":
        "${todayDate!.year.toString().padLeft(4, '0')}-${todayDate!.month.toString().padLeft(2, '0')}-${todayDate!.day.toString().padLeft(2, '0')}",
    "service_types": serviceTypes == null
        ? []
        : List<dynamic>.from(serviceTypes!.map((x) => x.toJson())),
    "service_counts": serviceCounts?.toJson(),
    "current_filter": currentFilter,
  };
}

class Product {
  int? id;
  String? name;
  String? description;
  String? price;
  String? sellingPrice;
  dynamic image;
  dynamic status;
  int? categoryId;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? taxGroup;
  String? priceInDolor;
  String? sellingPriceInDolar;

  Product({
    this.id,
    this.name,
    this.description,
    this.price,
    this.sellingPrice,
    this.image,
    this.status,
    this.categoryId,
    this.createdAt,
    this.updatedAt,
    this.taxGroup,
    this.priceInDolor,
    this.sellingPriceInDolar,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json["id"],
    name: json["name"],
    description: json["description"],
    price: json["price"],
    sellingPrice: json["selling_price"],
    image: json["image"],
    status: json["status"],
    categoryId: json["category_id"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
    taxGroup: json["tax_group"],
    priceInDolor: json["price_in_dolor"],
    sellingPriceInDolar: json["selling_price_in_dolar"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "price": price,
    "selling_price": sellingPrice,
    "image": image,
    "status": status,
    "category_id": categoryId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "tax_group": taxGroup,
    "price_in_dolor": priceInDolor,
    "selling_price_in_dolar": sellingPriceInDolar,
  };
}

class ServiceCounts {
  int? the1;
  int? the2;
  int? the3;
  int? the4;
  int? all;

  ServiceCounts({this.the1, this.the2, this.the3, this.the4, this.all});

  factory ServiceCounts.fromJson(Map<String, dynamic> json) => ServiceCounts(
    the1: json["1"],
    the2: json["2"],
    the3: json["3"],
    the4: json["4"],
    all: json["all"],
  );

  Map<String, dynamic> toJson() => {
    "1": the1,
    "2": the2,
    "3": the3,
    "4": the4,
    "all": all,
  };
}

class ServiceTypeElement {
  dynamic id;
  String? name;

  ServiceTypeElement({this.id, this.name});

  factory ServiceTypeElement.fromJson(Map<String, dynamic> json) =>
      ServiceTypeElement(id: json["id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}

class Sessions {
  List<SessionsData>? data;
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? total;
  dynamic nextPageUrl;
  dynamic prevPageUrl;

  Sessions({
    this.data,
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory Sessions.fromJson(Map<String, dynamic> json) => Sessions(
    data: json["data"] == null
        ? []
        : List<SessionsData>.from(json["data"]!.map((x) => SessionsData.fromJson(x))),
    currentPage: json["current_page"],
    lastPage: json["last_page"],
    perPage: json["per_page"],
    total: json["total"],
    nextPageUrl: json["next_page_url"],
    prevPageUrl: json["prev_page_url"],
  );

  Map<String, dynamic> toJson() => {
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
    "current_page": currentPage,
    "last_page": lastPage,
    "per_page": perPage,
    "total": total,
    "next_page_url": nextPageUrl,
    "prev_page_url": prevPageUrl,
  };
}

class SessionsData {
  int? id;
  int? orderId;
  String? roomId;
  dynamic token;
  int? userId;
  dynamic startDate;
  String? startTime;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? date;
  String? customerName;
  String? serviceName;
  int? expertId;
  DatumServiceType? serviceType;
  dynamic audioFile;
  String? astrologerName;
  String? astrologerImage;
  String? sessionTime;
  String? endTime;
  dynamic notes;
  dynamic preferLanguage;
  String? orderType;

  SessionsData({
    this.id,
    this.orderId,
    this.roomId,
    this.token,
    this.userId,
    this.startDate,
    this.startTime,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.date,
    this.customerName,
    this.serviceName,
    this.expertId,
    this.serviceType,
    this.audioFile,
    this.astrologerName,
    this.astrologerImage,
    this.sessionTime,
    this.endTime,
    this.notes,
    this.preferLanguage,
    this.orderType,
  });

  factory SessionsData.fromJson(Map<String, dynamic> json) => SessionsData(
    id: json["id"],
    orderId: json["order_id"],
    roomId: json["room_id"],
    token: json["token"],
    userId: json["user_id"],
    startDate: json["start_date"],
    startTime: json["start_time"],
    status: json["status"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    customerName: json["customer_name"],
    serviceName: json["service_name"],
    expertId: json["expert_id"],
    serviceType: json["service_type"] == null
        ? null
        : DatumServiceType.fromJson(json["service_type"]),
    audioFile: json["audio_file"],
    astrologerName: json["astrologer_name"],
    astrologerImage: json["astrologer_image"],
    sessionTime: json["session_time"],
    endTime: json["end_time"],
    notes: json["notes"],
    preferLanguage: json["prefer_language"],
    orderType: json["order_type"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_id": orderId,
    "room_id": roomId,
    "token": token,
    "user_id": userId,
    "start_date": startDate,
    "start_time": startTime,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "date":
        "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
    "customer_name": customerName,
    "service_name": serviceName,
    "expert_id": expertId,
    "service_type": serviceType?.toJson(),
    "audio_file": audioFile,
    "astrologer_name": astrologerName,
    "astrologer_image": astrologerImage,
    "session_time": sessionTime,
    "end_time": endTime,
    "notes": notes,
    "prefer_language": preferLanguage,
    "order_type": orderType,
  };
}

class DatumServiceType {
  int? id;
  String? name;
  String? image;
  dynamic status;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? description;
  String? showSlots;
  String? dollerDescription;

  DatumServiceType({
    this.id,
    this.name,
    this.image,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.description,
    this.showSlots,
    this.dollerDescription,
  });

  factory DatumServiceType.fromJson(Map<String, dynamic> json) =>
      DatumServiceType(
        id: json["id"],
        name: json["name"],
        image: json["image"],
        status: json["status"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        description: json["description"],
        showSlots: json["show_slots"],
        dollerDescription: json["doller_description"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "image": image,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "description": description,
    "show_slots": showSlots,
    "doller_description": dollerDescription,
  };
}

class Slots {
  List<Afternoon>? morning;
  List<Afternoon>? afternoon;
  List<Afternoon>? evening;
  List<Afternoon>? night;

  Slots({this.morning, this.afternoon, this.evening, this.night});

  factory Slots.fromJson(Map<String, dynamic> json) => Slots(
    morning: json["Morning"] == null
        ? []
        : List<Afternoon>.from(
            json["Morning"]!.map((x) => Afternoon.fromJson(x)),
          ),
    afternoon: json["Afternoon"] == null
        ? []
        : List<Afternoon>.from(
            json["Afternoon"]!.map((x) => Afternoon.fromJson(x)),
          ),
    evening: json["Evening"] == null
        ? []
        : List<Afternoon>.from(
            json["Evening"]!.map((x) => Afternoon.fromJson(x)),
          ),
    night: json["Night"] == null
        ? []
        : List<Afternoon>.from(
            json["Night"]!.map((x) => Afternoon.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "Morning": morning == null
        ? []
        : List<dynamic>.from(morning!.map((x) => x.toJson())),
    "Afternoon": afternoon == null
        ? []
        : List<dynamic>.from(afternoon!.map((x) => x.toJson())),
    "Evening": evening == null
        ? []
        : List<dynamic>.from(evening!.map((x) => x.toJson())),
    "Night": night == null
        ? []
        : List<dynamic>.from(night!.map((x) => x.toJson())),
  };
}

class Afternoon {
  int? slotId;
  String? name;
  String? startTime;
  String? endTime;
  dynamic period;
  dynamic status;

  Afternoon({
    this.slotId,
    this.name,
    this.startTime,
    this.endTime,
    this.period,
    this.status,
  });

  factory Afternoon.fromJson(Map<String, dynamic> json) => Afternoon(
    slotId: json["slot_id"],
    name: json["name"],
    startTime: json["start_time"],
    endTime: json["end_time"],
    period: json["period"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "slot_id": slotId,
    "name": name,
    "start_time": startTime,
    "end_time": endTime,
    "period": period,
    "status": status,
  };
}
