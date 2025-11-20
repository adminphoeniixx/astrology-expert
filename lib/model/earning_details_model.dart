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
  dynamic weekStart;
  dynamic weekEnd;
  dynamic totalCommission;
  dynamic payableAmount;
  dynamic payoutStatus;
  dynamic payoutDate;
  dynamic utr;
  dynamic createdAt;
  dynamic updatedAt;
  List<Transaction>? transactions;
  dynamic id;
  dynamic expertName;

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
    this.id,
    this.expertName,
  });

  factory Earning.fromJson(Map<String, dynamic> json) => Earning(
    expertId: json["expert_id"],
    financialYear: json["financial_year"],
    weekNumber: json["week_number"],
    weekStart: json["week_start"] == null
        ? null
        : DateTime.parse(json["week_start"]),
    weekEnd: json["week_end"] == null ? null : DateTime.parse(json["week_end"]),
    totalCommission: json["total_commission"]?.toDouble(),
    payableAmount: json["payable_amount"]?.toDouble(),
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
    id: json["id"],
    expertName: json["expert_name"],
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
    "id": id,
    "expert_name": expertName,
  };
}

class Transaction {
  dynamic date;
  dynamic commission;
  dynamic tds;
  dynamic tdsPercentage;
  dynamic payableAmount;
  dynamic serviceSessionId;
  dynamic status;
  dynamic serviceTypeLabel;
  dynamic sessionDate;
  dynamic sessionDurationMin;
  dynamic sessionDurationSec;
  dynamic sessionCharge;
  dynamic sessionCurrency;
  dynamic customerName;
  SessionDetailData? sessionData;

  Transaction({
    this.date,
    this.commission,
    this.tds,
    this.tdsPercentage,
    this.payableAmount,
    this.serviceSessionId,
    this.status,
    this.serviceTypeLabel,
    this.sessionDate,
    this.sessionDurationMin,
    this.sessionDurationSec,
    this.sessionCharge,
    this.sessionCurrency,
    this.customerName,
    this.sessionData,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    commission: json["commission"],
    tds: json["tds"]?.toDouble(),
    tdsPercentage: json["tds_percentage"],
    payableAmount: json["payable_amount"]?.toDouble(),
    serviceSessionId: json["service_session_id"],
    status: json["status"],
    serviceTypeLabel: json["service_type_label"],
    sessionDate: json["session_date"] == null
        ? null
        : DateTime.parse(json["session_date"]),
    sessionDurationMin: json["session_duration_min"],
    sessionDurationSec: json["session_duration_sec"],
    sessionCharge: json["session_charge"],
    sessionCurrency: json["session_currency"],
    customerName: json["customer_name"],
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
    "service_type_label": serviceTypeLabel,
    "session_date":
        "${sessionDate!.year.toString().padLeft(4, '0')}-${sessionDate!.month.toString().padLeft(2, '0')}-${sessionDate!.day.toString().padLeft(2, '0')}",
    "session_duration_min": sessionDurationMin,
    "session_duration_sec": sessionDurationSec,
    "session_charge": sessionCharge,
    "session_currency": sessionCurrency,
    "customer_name": customerName,
    "session_data": sessionData?.toJson(),
  };
}

class SessionDetailData {
  dynamic id;
  dynamic orderId;
  dynamic customerName;
  dynamic serviceName;
  dynamic astrologerName;
  dynamic startTime;
  dynamic endTime;
  dynamic date;
  Order? order;

  SessionDetailData({
    this.id,
    this.orderId,
    this.customerName,
    this.serviceName,
    this.astrologerName,
    this.startTime,
    this.endTime,
    this.date,
    this.order,
  });

  factory SessionDetailData.fromJson(Map<String, dynamic> json) =>
      SessionDetailData(
        id: json["id"],
        orderId: json["order_id"],
        customerName: json["customer_name"],
        serviceName: json["service_name"],
        astrologerName: json["astrologer_name"],
        startTime: json["start_time"],
        endTime: json["end_time"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        order: json["order"] == null ? null : Order.fromJson(json["order"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_id": orderId,
    "customer_name": customerName,
    "service_name": serviceName,
    "astrologer_name": astrologerName,
    "start_time": startTime,
    "end_time": endTime,
    "date":
        "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
    "order": order?.toJson(),
  };
}

class Order {
  dynamic id;
  dynamic name;
  dynamic totalAmount;
  dynamic payableAmount;
  dynamic paymentStatus;
  dynamic sessionTime;

  Order({
    this.id,
    this.name,
    this.totalAmount,
    this.payableAmount,
    this.paymentStatus,
    this.sessionTime,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json["id"],
    name: json["name"],
    totalAmount: json["total_amount"]?.toDouble(),
    payableAmount: json["payable_amount"]?.toDouble(),
    paymentStatus: json["payment_status"],
    sessionTime: json["session_time"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "total_amount": totalAmount,
    "payable_amount": payableAmount,
    "payment_status": paymentStatus,
    "session_time": sessionTime,
  };
}
