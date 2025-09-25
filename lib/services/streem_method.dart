// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:stream_video_flutter/stream_video_flutter.dart';

// Future<Call?> createAudioRoom(
//     {required String callId,
//     required String apiKey,
//     required String userId,
//     required String userName,
//     required String role,
//     required String userToken}) async {
//   try {
//     // Set up our call object
//     await initlizedStreemVideo(
//         apiKey: apiKey,
//         role: role,
//         userId: userId,
//         userName: userName,
//         userToken: userToken);
//     final call = StreamVideo.instance.makeCall(
//         callType: StreamCallType.defaultType(),
//         id: callId,
//         preferences: DefaultCallPreferences());
//     final result = await call.getOrCreate(); // Call object is created
//     if (result.isSuccess) {
//       await call.join();
//       await call.goLive();
//       return call; // Return the call object
//     } else {
//       debugPrint('Not able to create a call.');
//       return null; // Return null if call creation fails
//     }
//   } catch (e) {
//     debugPrint('Error creating audio room: $e');
//     return null; // Return null if an exception occurs
//   }
// }

// Future<void> initlizedStreemVideo(
//     {required String apiKey,
//     required String userId,
//     required String userName,
//     required String role,
//     required String userToken}) async {
//   try {
//     StreamVideo.reset(); // Reset the StreamVideo instance
//     StreamVideo(apiKey,
//         user: User(info: UserInfo(name: userName, id: userId, role: role)),
//         userToken: userToken);
//   } catch (e) {
//     debugPrint('Error initializing StreamVideo: $e');
//     rethrow; // Rethrow the exception to be handled by the caller
//   }
// }
