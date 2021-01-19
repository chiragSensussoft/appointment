import 'dart:io';

import 'package:appointment/home/OnHomeView.dart';
import 'package:dio/dio.dart';

import 'BasePresenter.dart';


class APIClient extends BasePresenter<OnHomeView>{

  static final BASEURL = 'https://www.googleapis.com/calendar/v3/calendars/chirag.1sensussoft@gmail.com/';
  Dio dio = new Dio();
  OnHomeView view;
  APIClient(this.view);

  Future<dynamic> api(String apiName, method, dynamic body, String token) async{
    Response response;
    var responseJson;
    print(body);

    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {

        switch(method){
          case Method.POST:
            dio.options.headers["Bearer Token"] = token;
            try {
              response = await dio.post(BASEURL + apiName, data: body);
              responseJson = _returnResponse(response);

            } on DioError catch (e) {
              responseJson = _returnResponse(e.response);
            }
            break;

          case Method.GET:
            response = await dio.get(BASEURL + apiName);
            break;

          case Method.PUT:
            response = await dio.put(BASEURL + apiName, data: body);
            break;

          case Method.DELETE:
            response = await dio.delete(BASEURL + apiName, data: body);
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

Future<bool> IsInternetConencted() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
     return true;
    }
  } on SocketException catch (_) {
    return false;
  }
}

enum Method{POST,GET,DELETE,PUT}