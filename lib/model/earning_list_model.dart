// To parse this JSON data, do
//
//     final earningListModel = earningListModelFromJson(jsonString);

import 'dart:convert';

import 'package:astro_partner_app/utils/enum.dart';

EarningListModel earningListModelFromJson(String str) =>
    EarningListModel.fromJson(json.decode(str));

String earningListModelToJson(EarningListModel data) =>
    json.encode(data.toJson());

class EarningListModel {
  bool? success;
  String? message;
  Data? data;
  String? currencySymbol;
  RequestStatus requestStatus;

  EarningListModel({
    this.success,
    this.message,
    this.data,
    this.currencySymbol,
    this.requestStatus = RequestStatus.initial,
  });

  factory EarningListModel.fromJson(Map<String, dynamic> json) =>
      EarningListModel(
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
  Earnings? earnings;
  List<dynamic>? filters;
  List<String>? financialYears;
  Pagination? pagination;

  Data({this.earnings, this.filters, this.financialYears, this.pagination});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    earnings: json["earnings"] == null
        ? null
        : Earnings.fromJson(json["earnings"]),
    filters: json["filters"] == null
        ? []
        : List<dynamic>.from(json["filters"]!.map((x) => x)),
    financialYears: json["financial_years"] == null
        ? []
        : List<String>.from(json["financial_years"]!.map((x) => x)),
    pagination: json["pagination"] == null
        ? null
        : Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "earnings": earnings?.toJson(),
    "filters": filters == null
        ? []
        : List<dynamic>.from(filters!.map((x) => x)),
    "financial_years": financialYears == null
        ? []
        : List<dynamic>.from(financialYears!.map((x) => x)),
    "pagination": pagination?.toJson(),
  };
}

class Earnings {
  List<EarningData>? data;
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? total;
  int? from;
  int? to;
  dynamic prevPageUrl;
  dynamic nextPageUrl;

  Earnings({
    this.data,
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
    this.from,
    this.to,
    this.prevPageUrl,
    this.nextPageUrl,
  });

  factory Earnings.fromJson(Map<String, dynamic> json) => Earnings(
    data: json["data"] == null
        ? []
        : List<EarningData>.from(
            json["data"]!.map((x) => EarningData.fromJson(x)),
          ),
    currentPage: json["current_page"],
    lastPage: json["last_page"],
    perPage: json["per_page"],
    total: json["total"],
    from: json["from"],
    to: json["to"],
    prevPageUrl: json["prev_page_url"],
    nextPageUrl: json["next_page_url"],
  );

  Map<String, dynamic> toJson() => {
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
    "current_page": currentPage,
    "last_page": lastPage,
    "per_page": perPage,
    "total": total,
    "from": from,
    "to": to,
    "prev_page_url": prevPageUrl,
    "next_page_url": nextPageUrl,
  };
}

class EarningData {
  int? expertId;
  String? financialYear;
  int? weekNumber;
  DateTime? weekStart;
  DateTime? weekEnd;
  int? totalCommission;
  int? payableAmount;
  String? payoutStatus;
  dynamic payoutDate;
  dynamic utr;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<Transaction>? transactions;
  String? expertName;
  String? id;
  dynamic bankName;
  int? totalTds;

  EarningData({
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
    this.bankName,
    this.totalTds,
  });

  factory EarningData.fromJson(Map<String, dynamic> json) => EarningData(
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
    bankName: json["bank_name"],
    totalTds: json["total_tds"],
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
    "bank_name": bankName,
    "total_tds": totalTds,
  };
}

class Transaction {
  DateTime? date;
  int? commission;
  int? tds;
  int? tdsPercentage;
  int? payableAmount;
  int? serviceSessionId;
  String? status;
  SessionData? sessionData;

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
        : SessionData.fromJson(json["session_data"]),
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

class SessionData {
  bool? incrementing;
  bool? preventsLazyLoading;
  bool? exists;
  bool? wasRecentlyCreated;
  bool? timestamps;
  bool? usesUniqueIds;

  SessionData({
    this.incrementing,
    this.preventsLazyLoading,
    this.exists,
    this.wasRecentlyCreated,
    this.timestamps,
    this.usesUniqueIds,
  });

  factory SessionData.fromJson(Map<String, dynamic> json) => SessionData(
    incrementing: json["incrementing"],
    preventsLazyLoading: json["preventsLazyLoading"],
    exists: json["exists"],
    wasRecentlyCreated: json["wasRecentlyCreated"],
    timestamps: json["timestamps"],
    usesUniqueIds: json["usesUniqueIds"],
  );

  Map<String, dynamic> toJson() => {
    "incrementing": incrementing,
    "preventsLazyLoading": preventsLazyLoading,
    "exists": exists,
    "wasRecentlyCreated": wasRecentlyCreated,
    "timestamps": timestamps,
    "usesUniqueIds": usesUniqueIds,
  };
}

class Pagination {
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? total;

  Pagination({this.currentPage, this.lastPage, this.perPage, this.total});

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json["current_page"],
    lastPage: json["last_page"],
    perPage: json["per_page"],
    total: json["total"],
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "last_page": lastPage,
    "per_page": perPage,
    "total": total,
  };
}
