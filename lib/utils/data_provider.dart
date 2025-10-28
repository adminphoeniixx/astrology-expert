// ignore_for_file: unnecessary_null_comparison

import 'dart:io';

import 'package:astro_partner_app/constants/string_const.dart';
import 'package:astro_partner_app/helper/local_storage.dart';
import 'package:astro_partner_app/validator/validate.dart';

Future<String?> getAccessToken() async {
  var token = await BasePrefs.readData(accessToken).onError((
    error,
    stackTrace,
  ) {
    return null;
  });
  if (isValidString(token)) {
    return token;
  }
  return null;
}

Future<int?> getUserId() async {
  var token = await BasePrefs.readData(userId).onError((error, stackTrace) {
    return null;
  });
  if (isValidString(token)) {
    return int.parse(token);
  }
  return null;
}

// Future<int?> getLiveGameId() async {
//   var token = await BasePrefs.readData(liveGameId).onError((error, stackTrace) {
//     return null;
//   });
//   if (isValidString(token)) {
//     return int.parse(token);
//   }
//   return null;
// }
// Future<void> setLiveGameId(int value) async {
//   BasePrefs.saveData(liveGameId, value);
// }

// Future<String?> getDeviceToken() async {
//   String? token =
//       await BasePrefs.readData(deviceToken).onError((error, stackTrace) {
//     return null;
//   });
//   if (token != null) {
//     if (await fcmTokenMonitor() != null) {
//       fcmTokenMonitor().then((value) {
//         if (value != null) {
//           token = value;
//         }
//       });
//     } else {
//       token = null;
//     }
//   }
//   return token;
// }

// Future<int?> getNotificationId() async {
//   dynamic token =
//       await BasePrefs.readData(notificationId).onError((error, stackTrace) {
//     printLog("ghjvvghv", error.toString());
//     return null;
//   });

//   return int.parse(token ?? 0);
// }

Future<Map<String, String>> authHeader() async {
  Map<String, String> header;
  var value = await BasePrefs.readData(
    accessToken,
  ).onError((error, stackTrace) => null);
  await BasePrefs.readData(isIndia).onError((error, stackTrace) => "true");
  if (value != null) {
    var token = await BasePrefs.readData(
      accessToken,
    ).onError((error, stackTrace) => null);
    header = {
      "Accept": "application/json",
      'is_india': "true",
      HttpHeaders.authorizationHeader: "Bearer $token",
    };
  } else {
    header = {"Accept": "application/json"};
  }
  return header;
}

// Future<bool> isUserInIndia() async {
//   try {
//     // Request location permission
//     LocationPermission permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.denied ||
//         permission == LocationPermission.deniedForever) {
//       return false; // Permission denied case
//     }
//     // Get current position
//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//     // Get the address using latitude and longitude
//     List<Placemark> placemarks =
//         await placemarkFromCoordinates(position.latitude, position.longitude);
//     // Check if the country is India
//     if (placemarks.isNotEmpty) {
//       return placemarks.first.country == 'India';
//     }
//   } catch (e) {
//     print(e); // Handle error
//   }
//   return false; // Return false in case of error or if not India
// }

Future<Map<String, String>> uniqueAuthHeader() async {
  Map<String, String> header;
  var value = await BasePrefs.readData(
    accessToken,
  ).onError((error, stackTrace) => null);
  if (value != null) {
    var token = await BasePrefs.readData(
      accessToken,
    ).onError((error, stackTrace) => null);
    header = {"Accept": "application/json", "Authorization": "Bearer $token"};
  } else {
    header = {"Accept": "application/json"};
  }
  return header;
}
