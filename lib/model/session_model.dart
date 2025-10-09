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
  List<ServiceType>? serviceTypes;
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
        : List<ServiceType>.from(
            json["service_types"]!.map((x) => ServiceType.fromJson(x)),
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
  dynamic id;
  String? name;
  String? description;
  String? price;
  String? sellingPrice;
  dynamic image;
  dynamic status;
  dynamic categoryId;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic taxGroup;
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
  dynamic the1;
  dynamic the2;
  dynamic the3;
  dynamic the4;
  dynamic all;

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

class ServiceType {
  dynamic id;
  String? name;

  ServiceType({this.id, this.name});

  factory ServiceType.fromJson(Map<String, dynamic> json) =>
      ServiceType(id: json["id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}

class Sessions {
  List<SessionsData>? data;
  dynamic currentPage;
  dynamic lastPage;
  dynamic perPage;
  dynamic total;
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
        : List<SessionsData>.from(
            json["data"]!.map((x) => SessionsData.fromJson(x)),
          ),
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
  dynamic orderId;
  String? roomId;
  dynamic token;
  dynamic userId;
  dynamic customerId;
  dynamic expertId;
  DateTime? date;
  DateTime? startDate;
  String? startTime;
  String? endTime;
  String? status;
  dynamic serviceType;
  String? customerName;
  String? serviceName;
  String? astrologerName;
  String? astrologerImage;
  dynamic preferLanguage;
  dynamic sessionTime;
  String? notes;
  DateTime? updatedAt;
  DateTime? createdAt;
  String? id;
  dynamic orderType;
  dynamic audioFile;
  dynamic createdBy;
  String? createdVia;

  SessionsData({
    this.orderId,
    this.roomId,
    this.token,
    this.userId,
    this.customerId,
    this.expertId,
    this.date,
    this.startDate,
    this.startTime,
    this.endTime,
    this.status,
    this.serviceType,
    this.customerName,
    this.serviceName,
    this.astrologerName,
    this.astrologerImage,
    this.preferLanguage,
    this.sessionTime,
    this.notes,
    this.updatedAt,
    this.createdAt,
    this.id,
    this.orderType,
    this.audioFile,
    this.createdBy,
    this.createdVia,
  });

  factory SessionsData.fromJson(Map<String, dynamic> json) => SessionsData(
    orderId: json["order_id"],
    roomId: json["room_id"],
    token: json["token"],
    userId: json["user_id"],
    customerId: json["customer_id"],
    expertId: json["expert_id"],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    startDate: json["start_date"] == null
        ? null
        : DateTime.parse(json["start_date"]),
    startTime: json["start_time"],
    endTime: json["end_time"],
    status: json["status"],
    serviceType: json["service_type"],
    customerName: json["customer_name"],
    serviceName: json["service_name"],
    astrologerName: json["astrologer_name"],
    astrologerImage: json["astrologer_image"],
    preferLanguage: json["prefer_language"],
    sessionTime: json["session_time"],
    notes: json["notes"],
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    id: json["id"],
    orderType: json["order_type"],
    audioFile: json["audio_file"],
    createdBy: json["created_by"],
    createdVia: json["created_via"],
  );

  Map<String, dynamic> toJson() => {
    "order_id": orderId,
    "room_id": roomId,
    "token": token,
    "user_id": userId,
    "customer_id": customerId,
    "expert_id": expertId,
    "date":
        "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
    "start_date":
        "${startDate!.year.toString().padLeft(4, '0')}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}",
    "start_time": startTime,
    "end_time": endTime,
    "status": status,
    "service_type": serviceType,
    "customer_name": customerName,
    "service_name": serviceName,
    "astrologer_name": astrologerName,
    "astrologer_image": astrologerImage,
    "prefer_language": preferLanguage,
    "session_time": sessionTime,
    "notes": notes,
    "updated_at": updatedAt?.toIso8601String(),
    "created_at": createdAt?.toIso8601String(),
    "id": id,
    "order_type": orderType,
    "audio_file": audioFile,
    "created_by": createdBy,
    "created_via": createdVia,
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
  dynamic slotId;
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
