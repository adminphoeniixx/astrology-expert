// To parse this JSON data, do
//
//     final earningDetailsModel = earningDetailsModelFromJson(jsonString);

import 'dart:convert';

import 'package:astro_partner_app/utils/enum.dart';

EarningDetailsModel earningDetailsModelFromJson(String str) =>
    EarningDetailsModel.fromJson(json.decode(str));

String earningDetailsModelToJson(EarningDetailsModel data) =>
    json.encode(data.toJson());

class EarningDetailsModel {
  bool? success;
  dynamic message;
  Data? data;
  dynamic currencySymbol;
  RequestStatus requestStatus;

  EarningDetailsModel({
    this.success,
    this.message,
    this.data,
    this.currencySymbol,
    this.requestStatus = RequestStatus.initial,
  });

  factory EarningDetailsModel.fromJson(Map<String, dynamic> json) =>
      EarningDetailsModel(
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
  Earning? earning;

  Data({this.earning});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    earning: json["earning"] == null ? null : Earning.fromJson(json["earning"]),
  );

  Map<String, dynamic> toJson() => {"earning": earning?.toJson()};
}

class Earning {
  dynamic expertId;
  dynamic financialYear;
  dynamic weekNumber;
  DateTime? weekStart;
  DateTime? weekEnd;
  dynamic totalCommission;
  dynamic payableAmount;
  dynamic payoutStatus;
  dynamic payoutDate;
  dynamic utr;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<Transaction>? transactions;
  dynamic expertName;
  dynamic id;

  Earning({
    this.expertId,
    this.financialYear,
    this.weekNumber,
    this.weekStart,
    this.weekEnd,
    this.totalCommission,
    this.payableAmount,
    this.payoutStatus,
    this.payoutDate,
    this.utr,
    this.createdAt,
    this.updatedAt,
    this.transactions,
    this.expertName,
    this.id,
  });

  factory Earning.fromJson(Map<String, dynamic> json) => Earning(
    expertId: json["expert_id"],
    financialYear: json["financial_year"],
    weekNumber: json["week_number"],
    weekStart: json["week_start"] == null
        ? null
        : DateTime.parse(json["week_start"]),
    weekEnd: json["week_end"] == null ? null : DateTime.parse(json["week_end"]),
    totalCommission: json["total_commission"],
    payableAmount: json["payable_amount"],
    payoutStatus: json["payout_status"],
    payoutDate: json["payout_date"],
    utr: json["utr"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
    transactions: json["transactions"] == null
        ? []
        : List<Transaction>.from(
            json["transactions"]!.map((x) => Transaction.fromJson(x)),
          ),
    expertName: json["expert_name"],
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "expert_id": expertId,
    "financial_year": financialYear,
    "week_number": weekNumber,
    "week_start":
        "${weekStart!.year.toString().padLeft(4, '0')}-${weekStart!.month.toString().padLeft(2, '0')}-${weekStart!.day.toString().padLeft(2, '0')}",
    "week_end":
        "${weekEnd!.year.toString().padLeft(4, '0')}-${weekEnd!.month.toString().padLeft(2, '0')}-${weekEnd!.day.toString().padLeft(2, '0')}",
    "total_commission": totalCommission,
    "payable_amount": payableAmount,
    "payout_status": payoutStatus,
    "payout_date": payoutDate,
    "utr": utr,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "transactions": transactions == null
        ? []
        : List<dynamic>.from(transactions!.map((x) => x.toJson())),
    "expert_name": expertName,
    "id": id,
  };
}

class Transaction {
  DateTime? date;
  dynamic commission;
  dynamic tds;
  dynamic tdsPercentage;
  dynamic payableAmount;
  dynamic serviceSessionId;
  dynamic status;
  SessionDetailData? sessionData;

  Transaction({
    this.date,
    this.commission,
    this.tds,
    this.tdsPercentage,
    this.payableAmount,
    this.serviceSessionId,
    this.status,
    this.sessionData,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    commission: json["commission"],
    tds: json["tds"],
    tdsPercentage: json["tds_percentage"],
    payableAmount: json["payable_amount"],
    serviceSessionId: json["service_session_id"],
    status: json["status"],
    sessionData: json["session_data"] == null
        ? null
        : SessionDetailData.fromJson(json["session_data"]),
  );

  Map<String, dynamic> toJson() => {
    "date": date?.toIso8601String(),
    "commission": commission,
    "tds": tds,
    "tds_percentage": tdsPercentage,
    "payable_amount": payableAmount,
    "service_session_id": serviceSessionId,
    "status": status,
    "session_data": sessionData?.toJson(),
  };
}

class SessionDetailData {
  dynamic id;
  dynamic orderId;
  dynamic roomId;
  dynamic token;
  dynamic userId;
  dynamic startDate;
  dynamic startTime;
  dynamic status;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? date;
  dynamic customerName;
  dynamic serviceName;
  dynamic expertId;
  dynamic serviceType;
  dynamic audioFile;
  dynamic astrologerName;
  dynamic astrologerImage;
  dynamic sessionTime;
  dynamic endTime;
  dynamic notes;
  dynamic preferLanguage;
  Order? order;

  SessionDetailData({
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
    this.order,
  });

  factory SessionDetailData.fromJson(Map<String, dynamic> json) => SessionDetailData(
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
    serviceType: json["service_type"],
    audioFile: json["audio_file"],
    astrologerName: json["astrologer_name"],
    astrologerImage: json["astrologer_image"],
    sessionTime: json["session_time"],
    endTime: json["end_time"],
    notes: json["notes"],
    preferLanguage: json["prefer_language"],
    order: json["order"] == null ? null : Order.fromJson(json["order"]),
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
    "service_type": serviceType,
    "audio_file": audioFile,
    "astrologer_name": astrologerName,
    "astrologer_image": astrologerImage,
    "session_time": sessionTime,
    "end_time": endTime,
    "notes": notes,
    "prefer_language": preferLanguage,
    "order": order?.toJson(),
  };
}

class Order {
  dynamic id;
  dynamic name;
  dynamic email;
  dynamic mobile;
  dynamic city;
  dynamic state;
  dynamic pincode;
  dynamic address;
  dynamic customerId;
  dynamic couponCode;
  dynamic subTotal;
  dynamic tax;
  dynamic discount;
  dynamic total;
  dynamic status;
  dynamic paymentStatus;
  dynamic productId;
  DateTime? date;
  dynamic time;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic orderType;
  dynamic serviceType;
  dynamic transactionId;
  dynamic expertId;
  dynamic cashfreeSessionId;
  dynamic cfOrderId;
  dynamic paymentSessionId;
  dynamic addressId;
  dynamic amount;
  dynamic walletDeduction;
  DateTime? sessionDate;
  dynamic startTime;
  dynamic endTime;
  dynamic customerName;
  dynamic taxRate;
  dynamic serviceTypeName;
  dynamic addressType;

  Order({
    this.id,
    this.name,
    this.email,
    this.mobile,
    this.city,
    this.state,
    this.pincode,
    this.address,
    this.customerId,
    this.couponCode,
    this.subTotal,
    this.tax,
    this.discount,
    this.total,
    this.status,
    this.paymentStatus,
    this.productId,
    this.date,
    this.time,
    this.createdAt,
    this.updatedAt,
    this.orderType,
    this.serviceType,
    this.transactionId,
    this.expertId,
    this.cashfreeSessionId,
    this.cfOrderId,
    this.paymentSessionId,
    this.addressId,
    this.amount,
    this.walletDeduction,
    this.sessionDate,
    this.startTime,
    this.endTime,
    this.customerName,
    this.taxRate,
    this.serviceTypeName,
    this.addressType,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    mobile: json["mobile"],
    city: json["city"],
    state: json["state"],
    pincode: json["pincode"],
    address: json["address"],
    customerId: json["customer_id"],
    couponCode: json["coupon_code"],
    subTotal: json["sub_total"],
    tax: json["tax"],
    discount: json["discount"],
    total: json["total"],
    status: json["status"],
    paymentStatus: json["payment_status"],
    productId: json["product_id"],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    time: json["time"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
    orderType: json["order_type"],
    serviceType: json["service_type"],
    transactionId: json["transaction_id"],
    expertId: json["expert_id"],
    cashfreeSessionId: json["cashfree_session_id"],
    cfOrderId: json["cf_order_id"],
    paymentSessionId: json["payment_session_id"],
    addressId: json["address_id"],
    amount: json["amount"],
    walletDeduction: json["wallet_deduction"],
    sessionDate: json["session_date"] == null
        ? null
        : DateTime.parse(json["session_date"]),
    startTime: json["start_time"],
    endTime: json["end_time"],
    customerName: json["customer_name"],
    taxRate: json["tax_rate"],
    serviceTypeName: json["service_type_name"],
    addressType: json["address_type"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "mobile": mobile,
    "city": city,
    "state": state,
    "pincode": pincode,
    "address": address,
    "customer_id": customerId,
    "coupon_code": couponCode,
    "sub_total": subTotal,
    "tax": tax,
    "discount": discount,
    "total": total,
    "status": status,
    "payment_status": paymentStatus,
    "product_id": productId,
    "date":
        "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
    "time": time,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "order_type": orderType,
    "service_type": serviceType,
    "transaction_id": transactionId,
    "expert_id": expertId,
    "cashfree_session_id": cashfreeSessionId,
    "cf_order_id": cfOrderId,
    "payment_session_id": paymentSessionId,
    "address_id": addressId,
    "amount": amount,
    "wallet_deduction": walletDeduction,
    "session_date":
        "${sessionDate!.year.toString().padLeft(4, '0')}-${sessionDate!.month.toString().padLeft(2, '0')}-${sessionDate!.day.toString().padLeft(2, '0')}",
    "start_time": startTime,
    "end_time": endTime,
    "customer_name": customerName,
    "tax_rate": taxRate,
    "service_type_name": serviceTypeName,
    "address_type": addressType,
  };
}
