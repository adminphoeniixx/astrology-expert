import 'dart:io';


import 'package:astro_partner_app/model/media_upload_model.dart';
import 'package:astro_partner_app/services/web_request_constants.dart';
import 'package:astro_partner_app/utils/data_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';

class FirebaseServiceRequest {
  // Method to mark a message as seen
  static Future<void> sendMediaMessage({
    required dynamic roomId,
    required String subCollection,
    required int receiverId,
    required int senderId,
    required String mediaUrl,
  }) async {
    final messageId = FirebaseFirestore.instance
        .collection('chat')
        .doc('order_$roomId')
        .collection(subCollection)
        .doc()
        .id; // Auto-generated message ID
    await FirebaseFirestore.instance
        .collection('chat')
        .doc('order_$roomId')
        .collection(subCollection)
        .doc(messageId) // Use the auto-generated ID
        .set({
      'dateTime': Timestamp.now(), // ✅ Corrected      'isSeen': false,
      'msgType': 'Media',
      'receiverId': receiverId,
      'senderId': senderId,
      'msg': mediaUrl,
      'messageId': messageId, // Store the auto-generated message ID
    });
  }

  static Future<void> sendTextMessage({
    required String message,
    required dynamic roomId,
    required String subCollection,
    required int receiverId,
    required int senderId,
  }) async {
    final messageId = FirebaseFirestore.instance
        .collection('chat')
        .doc('order_$roomId')
        .collection(subCollection)
        .doc()
        .id; // Auto-generated message ID

    await FirebaseFirestore.instance
        .collection('chat')
        .doc('order_$roomId')
        .collection(subCollection)
        .doc(messageId) // Use the auto-generated ID
        .set({
      'msg': message,
      'dateTime': Timestamp.now(), // ✅ Corrected
      'isSeen': false,
      'msgType': 'text',
      'receiverId': receiverId,
      'senderId': senderId,
      'id': messageId, // Store the message ID if needed
    });
  }

  static Future<void> markAsSeen({
    required dynamic roomId,
    required String msgId,
    required String subCollection,
  }) async {
    await FirebaseFirestore.instance
        .collection('chat')
        .doc('order_$roomId')
        .collection(subCollection) // Use the sub-collection for messages
        .doc(msgId) // Specific message ID
        .update({'isSeen': true});
  }

  // upload_service.dart

  static Future<MediaUploadModel> uploadMedia({
    required File file,
    required Function(double) onProgress, // Progress callback
  }) async {
    Dio dio = Dio();
    String apiUrl = GetBaseUrl + GetDomainUrl + UPLOAD_MEDIA_API;
    // Set the authorization header
    dio.options.headers = await authHeader();

    try {
      // Create FormData with file
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path,
            filename: file.path.split('/').last),
      });

      // Make the POST request
      final response = await dio.post(
        apiUrl,
        data: formData,
        onSendProgress: (int sent, int total) {
          double progress = sent / total;
          onProgress(progress); // Callback for progress tracking
        },
      );

      print("##########MEDIA UPLOAD###########");
      print(response.data);
      print("##########MEDIA UPLOAD###########");
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse response data to UploadResponse
        return MediaUploadModel.fromJson(response.data);
      } else {
        return MediaUploadModel(
            mediaUrl: "",
            message: 'status code is ${response.statusCode}',
            status: false);
      }
    } catch (e) {
      // Handle any exceptions and rethrow
      return MediaUploadModel(mediaUrl: "", message: "$e", status: false);
    }
  }
}
