import 'package:astro_partner_app/utils/enum.dart';

class ApiResponse {
  ApiResponse({
    this.status,
    this.message = "",
    this.requestStatus = RequestStatus.initial,
  });

  dynamic status;
  dynamic message;
  RequestStatus requestStatus;

  factory ApiResponse.fromJson(Map<String, dynamic> json) =>
      ApiResponse(status: json["status"] ?? false, message: json["message"]);

  Map<String, dynamic> toJson() => {"status": status, "message": message};
}
