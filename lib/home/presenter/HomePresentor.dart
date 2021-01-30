import 'dart:convert';

import 'package:appointment/utils/APIClient.dart';
import 'package:appointment/utils/BasePresenter.dart';
import 'package:appointment/utils/values/Constant.dart';
import 'package:dio/dio.dart';

import '../OnHomeView.dart';

class HomePresenter extends BasePresenter<OnHomeView>  {
  OnHomeView view;
  APIClient apiHelper;
  String token;
  HomePresenter(this.view,{this.token}) {
    apiHelper = APIClient(view);
  }

  // var token = 'ya29.a0AfH6SMAynmQVP8rt-t-e3cJk25Rj5HAEYC44OH60dqr6s3NVe-Yls_yAA67vFiXsUMju2obc3QH4k_zQvvrffzz3TR8CNXS22e5t-qeFTREzgtGAWaXA4py1vFAqF2Wa9es5PiAnlZT3ur4tBRXQ9vgAwH2YkjLr3vk3sd6T0Lc';

      Future setAppointment({String description, String summary,String startDate, String endDate,String timeZone}) async {
        print("Token $token");
        print("End Date $endDate:00");
        print("Start Date $startDate:00");
        view.onShowLoader();
        Response postResponse = await apiHelper.api(
             apiName:Constant().event,method:  Method.POST,
            body:jsonEncode({
              "end": {
                "dateTime": endDate+":"+"00",
                "timeZone": timeZone
              },
              "start": {
                "dateTime": startDate+":"+"00",
                "timeZone": timeZone
              },
              "summary": summary,
              "description": description
            }),token: token);

        if (postResponse.statusCode == 200) {
          isViewAttached ? getView().onSuccessRes(postResponse.data) : null;
          view.onHideLoader();

        } else {
          view.onHideLoader();
    }
  }

  Future getCalendar()async{
    view.onShowLoader();
    Response getCalendarList = await apiHelper.api(token: token,method: Method.GET,apiName: Constant().calendar,endPoint:Constant().calendar );

    if (getCalendarList.statusCode == 200) {
      isViewAttached ? getView().onSuccessRes(getCalendarList.data['items']) : null;
      view.onHideLoader();
    } else {
      view.onHideLoader();
    }
  }
  
  Future getCalendarEvent() async{
    view.onShowLoader();
    Response getCalendarEventList = await apiHelper.api(token: token,method: Method.GET,apiName: Constant().event,endPoint: Constant().event);
    if(getCalendarEventList.statusCode == 200){
      isViewAttached ? getView().onEventSuccess(getCalendarEventList.data['items']) : null;
      view.onHideLoader();
    }else{
      view.onHideLoader();
    }
  }

  Future deleteEvent(id,email)async{
    view.onShowLoader();
    Response deleteCalendarEvent = await apiHelper.api(method: Method.DELETE,token: token,endPoint: id,apiName: Constant().event,user: email);
    if(deleteCalendarEvent.runtimeType == null){
      print("RunTimeType${deleteCalendarEvent.runtimeType}");
    }
    else{
      // view.onShowLoader();
      Response getCalendarEventList = await apiHelper.api(token: token,method: Method.GET,apiName: Constant().event,endPoint: Constant().event);
      if(getCalendarEventList.statusCode == 200){
        isViewAttached ? getView().onEventSuccess(getCalendarEventList.data['items']) : null;
        view.onHideLoader();
        print("RunTimeType${deleteCalendarEvent.runtimeType}");
      }else{
        view.onHideLoader();
        print("RunTimeType${deleteCalendarEvent.runtimeType}");
      }
    }
  }

}