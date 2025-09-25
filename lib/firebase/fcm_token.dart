
import 'package:astro_partner_app/constants/string_const.dart';
import 'package:astro_partner_app/helper/local_storage.dart' show BasePrefs;
import 'package:firebase_messaging/firebase_messaging.dart';

Future<String?> fcmTokenMonitor()async{
  String? status;
  Stream<String> tokenStream;
  await FirebaseMessaging.instance.getToken().then((value) {
    if(value!=null && value.isNotEmpty){
      BasePrefs.saveData(deviceToken, value);
      status = value;
    }else{
      status = "";
    }
  });
  tokenStream = FirebaseMessaging.instance.onTokenRefresh;
  tokenStream.listen((event) {
    if(event.isNotEmpty){
      BasePrefs.saveData(deviceToken, event);
      status = event;
    }else{
      status = "";
    }
  });
  return status;
}