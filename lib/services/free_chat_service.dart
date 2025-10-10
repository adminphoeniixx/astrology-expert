import 'dart:io';

import 'package:astro_partner_app/model/media_upload_model.dart';
import 'package:astro_partner_app/services/web_request_constants.dart';
import 'package:astro_partner_app/utils/data_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';

class FreeFirebaseServiceRequest {
  // Method to mark a message as seen
  static Future<void> sendMediaMessage({
    required dynamic roomId,
    required dynamic subCollection,
    required dynamic receiverId,
    required dynamic senderId,
    required dynamic mediaUrl,
    required dynamic customerName,
  }) async {
    final messageId = FirebaseFirestore.instance
        .collection('free_chat')
        .doc('$roomId')
        .collection(subCollection)
        .doc()
        .id; // Auto-generated message ID
    await FirebaseFirestore.instance
        .collection('free_chat')
        .doc('$roomId')
        .collection(subCollection)
        .doc(messageId) // Use the auto-generated ID
        .set({
          'dateTime': Timestamp.now(), // ✅ Corrected      'isSeen': false,
          'msgType': 'Media',
          'receiverId': receiverId,
          'senderId': senderId,
          'is_first_message': false,
          'msg': mediaUrl,
          'messageId': messageId, // Store the auto-generated message ID
        });
    await FirebaseFirestore.instance
        .collection('free_chat_session')
        .doc('$roomId')
        .set({
          'created_at': Timestamp.now(), // ✅ Corrected
          'receiverId': receiverId,
          'customer_id': senderId,
          'customer_name': customerName,
          'main_created_at': Timestamp.now(),
          'order_id': roomId, // Store the message ID if needed
        }, SetOptions(merge: true));
  }

  static Future<void> sendTextMessage({
    required dynamic message,
    required dynamic roomId,
    required dynamic subCollection,
    required dynamic receiverId,
    required dynamic senderId,
    required dynamic customerName,
  }) async {
    final messageId = FirebaseFirestore.instance
        .collection('free_chat')
        .doc('$roomId')
        .collection(subCollection)
        .doc()
        .id; // Auto-generated message ID

    await FirebaseFirestore.instance
        .collection('free_chat')
        .doc('$roomId')
        .collection(subCollection)
        .doc(messageId) // Use the auto-generated ID
        .set({
          'msg': message,
          'dateTime': Timestamp.now(), // ✅ Corrected
          'isSeen': false,
          'msgType': 'text',
          'is_first_message': false,
          'senderId': senderId,
          'id': messageId, // Store the message ID if needed
        });

    await FirebaseFirestore.instance
        .collection('free_chat_session')
        .doc('$roomId')
        .set({
          'created_at': Timestamp.now(), // ✅ Corrected
          'receiverId': receiverId,
          'customer_id': senderId,
          'main_created_at': Timestamp.now(),

          'customer_name': customerName,
          'order_id': roomId, // Store the message ID if needed
        }, SetOptions(merge: true));
  }

  static Future<void> markAsSeen({
    required dynamic roomId,
    required dynamic msgId,
    required dynamic subCollection,
  }) async {
    await FirebaseFirestore.instance
        .collection('free_chat')
        .doc('$roomId')
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
    String apiUrl = GetBaseUrl + GetDomainUrl3 + UPLOAD_MEDIA_API;
    // Set the authorization header
    dio.options.headers = await authHeader();
    print("!!!!!!!!!!!!!!!!!uploadMedia!!!!!!!!!!!!!!!!!!!!!");
    print(apiUrl);
    print("!!!!!!!!!!!!!!!!!uploadMedia!!!!!!!!!!!!!!!!!!!!!");

    try {
      // Create FormData with file
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });

      //   // Make the POST request
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
          status: false,
        );
      }
    } catch (e) {
      // Handle any exceptions and rethrow
      return MediaUploadModel(mediaUrl: "", message: "$e", status: false);
    }
  }
}
