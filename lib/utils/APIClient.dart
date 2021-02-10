import 'dart:io';

import 'package:appointment/home/OnHomeView.dart';
import 'package:appointment/utils/values/Constant.dart';
import 'package:dio/dio.dart';

import 'BasePresenter.dart';


class APIClient extends BasePresenter<OnHomeView>{

  static final BASEURL = 'https://www.googleapis.com/calendar/v3/calendars/';
  //https://www.googleapis.com/calendar/v3/calendars/jay.sensussoft@gmail.com/events/tekmrqi30pif8ej3li0hv7c398
  final calendarListUrl = "https://www.googleapis.com/calendar/v3/users/me/";

  Dio dio = new Dio();
  OnHomeView view;
  APIClient(this.view);

  Future<dynamic> api({String apiName, method,dynamic body, String token,String endPoint,
    String user,String pageToken,String maxResult,String currentTime,bool isPageToken}) async{
    var response;
    var responseJson;

    try {
      //it Check internet connectivity
      final result = await InternetAddress.lookup('google.com');

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        switch(method){
          case Method.POST:
            print("Email ${Constant.email}");

            dio.options.headers["Authorization"] = "Bearer " + token;
            try {
              response = await dio.post(BASEURL+ Constant.email+"/"+ apiName, data: body);
              responseJson = _returnResponse(response);

            } on DioError catch (e) {
              responseJson = _returnResponse(e.response);
            }
            break;

          case Method.GET:
            dio.options.headers["Authorization"] = "Bearer " + token;
            switch(endPoint){
              case "calendarList" :
                try {
                  response = await dio.get(calendarListUrl + apiName);
                  responseJson = _returnResponse(response);

                } on DioError catch (e) {
                  responseJson = _returnResponse(e.response);
                }
                break;

              case "events":
                print('events:::::$apiName');
                print('events:::::$BASEURL');
                print('events:::::${Constant.email}');
                /* calendar Event List*/
                try {
                  String time = currentTime.replaceAll(" ", "T");
                  print("Formatted Time --->$time ----> 2011-06-03T10:00:00-07:00");
                  isPageToken == true? response = await dio.get(BASEURL+ Constant.email+"/"+ apiName+"?"+"maxResults="+maxResult+"&"+"singleEvents="+"true"+"&"+"timeMin="+time+"&"+"pageToken="+pageToken)
                      :response = await dio.get(BASEURL+ Constant.email+"/"+ apiName+"?"+"maxResults="+maxResult+"&"+"singleEvents="+"true"+"&"+"timeMin="+time);
                  responseJson = _returnResponse(response);
                  print('response:::$response');

                } on DioError catch (e) {
                  responseJson = _returnResponse(e.response);
                  print('catch::::${e.message}');
                }
                break;
            }
            break;

          case Method.PUT:
            dio.options.headers["Authorization"] = "Bearer " + token;
            try {
              response = await dio.put(BASEURL+user+'/'+apiName+'/'+endPoint);
              // response = await dio.put("https://reqbin.com/sample/put/json");
              responseJson = _returnResponse(response);
              print('try:::');

            } on DioError catch (e) {
              responseJson = _returnResponse(e.response);
              print('catch::::;${e.message}');
            }
            break;

          case Method.DELETE:
            dio.options.headers["Authorization"] = "Bearer " + token;
            response = await dio.delete(BASEURL+user+"/"+apiName+"/"+endPoint);
            break;
        }
      }
    } on SocketException catch (_) {
      view.onErrorHandler('No Internet Connected! please try again!');
    }

    return responseJson;
  }

  dynamic _returnResponse(Response response) {
    switch (response.statusCode) {
      case 200:
        print('STATUS::::$response');
        return response;

      case 400:
        view.onErrorHandler('Unauthorized Error');
        break;

      case 404:
        view.onErrorHandler('404 parameter error');
        break;

      case 500:
        view.onErrorHandler('Internal server');
        break;
    }
  }
}

enum Method{POST,GET,DELETE,PUT}