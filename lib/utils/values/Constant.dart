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
}