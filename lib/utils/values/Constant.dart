import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class Constant{
  String languageKey = "code";
  static String languageCode;

  /// Api end points
  final event = 'events';
  final calendar = "calendarList";
  static String email;

  static String ACCESS_TOKEN = 'access_token';
  static String USER_NAME = 'user_name';
  static String token;


 static getTimeFormat(DateTime dateTime){
    String date;
    String getstart = dateTime.toString();
    var str = getstart.split(" ");
    var str_1 = str[0];
    var str_2 = str[1];
    var s = str_2.split(".");
    date = s[0];
    return date;
  }


  static getFullDateFormat(DateTime date){
    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
    String strDate = dateFormat.format(date);
    String finalStr = strDate.replaceAll(" ", "T");
    return finalStr;
  }

  static int CURRENT_STEP = 0;


  static showToast(String message,length){
    Fluttertoast.showToast(
        fontSize: 14,
        msg: message,
        toastLength: length,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
    );
  }


  static Future<bool> checkInternetConnection() async {
    bool isconnected;
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        isconnected = true;
      }
    } on SocketException catch (_) {
      isconnected = false;
    }
    return isconnected;
  }

}