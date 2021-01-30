import 'dart:io';

import 'package:appointment/home/OnHomeView.dart';
import 'package:appointment/utils/values/Constant.dart';
import 'package:dio/dio.dart';

import 'BasePresenter.dart';


class APIClient extends BasePresenter<OnHomeView>{

  static final BASEURL = 'https://www.googleapis.com/calendar/v3/calendars/';
  final calendarListUrl = "https://www.googleapis.com/calendar/v3/users/me/";
  final calendarEventList= "https://www.googleapis.com/calendar/v3/calendars/";
  final deleteApi = "https://www.googleapis.com/calendar/v3/calendars/";

  Dio dio = new Dio();
  OnHomeView view;
  APIClient(this.view);

  Future<dynamic> api({String apiName, method,dynamic body, String token,String endPoint,String user}) async{
    Response response;
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
                /// calendar Event List
                try {
                  response = await dio.get(calendarEventList+ Constant.email+"/"+ apiName);
                  responseJson = _returnResponse(response);

                } on DioError catch (e) {
                  responseJson = _returnResponse(e.response);
                }
                break;
            }
            break;

          case Method.PUT:
            response = await dio.put(BASEURL + endPoint, data: body);
            break;

          case Method.DELETE:
            dio.options.headers["Authorization"] = "Bearer " + token;
            response = await dio.delete(deleteApi+user+"/"+apiName+"/"+endPoint);
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
        // print('STATUS::::$response');
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