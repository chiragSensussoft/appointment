import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class Constant{
  String languageKey = "code";
  static String languageCode;


  /// Api end points
  final event = 'events';
  final calendar = "calendarList";
  static String email;
  static String SET_CAL_ID;


  static String ACCESS_TOKEN = 'access_token';
  static String USER_NAME = 'user_name';
  static String FROM_DATE = 'from_date';
  static String TO_DATE = 'to_date';
  static String CURRENT_LOCATION = 'current_location';
  static String ITEM_LIST = 'item_list';
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


  static getCurrentLocation({State state}) async {
    LatLng _lng;
    try {
      Geolocator geolocator = Geolocator()..forceAndroidLocationManager = true;
      Position position = await Geolocator().getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      state.setState(() async {
         _lng = LatLng(position.latitude, position.longitude);
        _getLocation(_lng);
      });
      return _lng;

    } catch (err) {
      print(err.message);
    }
  }

  static void _getLocation(LatLng latLng) async {
    print("getLocation:::${latLng.latitude}   ${latLng.longitude}");
    final coordinates = new Coordinates(latLng.latitude, latLng.longitude);
    var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);

    var first = addresses.first;
    print("CALLED::::${first.featureName} : ${first.addressLine}");
  }

}