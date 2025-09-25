// ignore_for_file: avoid_print


import 'package:astro_partner_app/constants/string_const.dart';
import 'package:astro_partner_app/utils/toast.dart';
import 'package:astro_partner_app/widgets/app_widget.dart';
import 'package:flutter/material.dart';
import 'enum.dart';


class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: const AlertDialog(
          content: CircularProgressIndicator()
        ));
  }
}

void showToast(BuildContext context,
    {String? msg, int? gravity, Color? color, Color? bgColor}) {
  return Toast.show(
      msg!,
    context,
    duration: Toast.lengthShort,
    gravity: gravity ?? Toast.bottom,
    backgroundColor:
        bgColor ?? Theme.of(context).highlightColor,
  );
}

class LoadingProgress extends StatelessWidget {
  const LoadingProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 600,
      color: Colors.transparent,                           
      child:  Center(
        child: CircularProgressIndicator(
          valueColor:  AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
        ),
      ),
      // this is the main reason of transparency at next screen. I am ignoring rest implementation but what i have achieved is you can see.
    );
  }
}                                                                                       
Future<String> appVersion()async{
  // PackageInfo packageInfo = await PackageInfo.fromPlatform();
  return "packageInfo.version";
}
void printLog(String tag, dynamic msg) {
  if (msg.toString().trim().isNotEmpty) {
    if ( tag.trim().isNotEmpty) {
      print("$tag => $msg");
    }
  }else{
    print("NoLogs Found");

  }
}
Widget dataNotFound() {
  return SizedBox(
    child: Column(
      children: [
        // Image.asset(ic_dataNotFound),
      const  SizedBox(
          height: 10
        ),
        text(
          DATA_NOT_FOUND,fontSize: 18, fontWeight: FontWeight.w500
        )
      ],
    ),
  );
}

ResponseStatus getResponse({RequestStatus? status}){
  if(status==RequestStatus.unauthorized) {
    return ResponseStatus.unauthorized;
  }else if(status==RequestStatus.server){
    return ResponseStatus.server;
  } else if(status==RequestStatus.failure){
    return ResponseStatus.failed;
  }else{
    return ResponseStatus.network;
  }
}