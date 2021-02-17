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
    print('TTT:::::${token}');
    apiHelper = APIClient(view);
  }

      Future setAppointment({String description, String summary,String startDate,
        String endDate,String timeZone}) async {

        view.onShowLoader();

        Response postResponse = await apiHelper.api(apiName:Constant().event,method:  Method.POST,
            body:jsonEncode({
              "end": {
                "dateTime": endDate,
                "timeZone": timeZone
              },
              "start": {
                "dateTime": startDate,
                "timeZone": timeZone
              },
              "summary": summary,
              "description": description
            }),token: token);

        if (postResponse.statusCode == 200) {
          isViewAttached ? getView().onCreateEvent(postResponse.data) : null;
          view.onHideLoader();

        } else {
          view.onHideLoader();
    }

  }

  Future getCalendar(String authToken)async{
    view.onShowLoader();
    print('authToken::$authToken');

    Response getCalendarList = await apiHelper.api(token: authToken,method: Method.GET,apiName: Constant().calendar,endPoint:Constant().calendar);

    if (getCalendarList.statusCode == 200) {
      isViewAttached ? getView().onSuccessRes(getCalendarList.data['items']) : null;
      view.onHideLoader();
    } else {
      view.onHideLoader();
    }
  }
  
  
  Future getCalendarEvent({pageToken, maxResult, minTime, bool isPageToken, maxTime}) async{
    isPageToken == false?view.onShowLoader():null;
    print('get_list:1::${Constant().event}');
    Response getCalendarEventList = await apiHelper.api(token: token, method: Method.GET,isPageToken: isPageToken,
        apiName: Constant().event, endPoint: Constant().event,pageToken: pageToken,
        maxResult: maxResult.toString(),timeMin: minTime.toString(), timeMax: maxTime.toString());

    print('statusCode::::${getCalendarEventList.statusCode}');

    if(getCalendarEventList.statusCode == 200){
      isViewAttached ? getView().onEventSuccess(getCalendarEventList.data['items'],getCalendarEventList.data) : null;
      view.onHideLoader();
    }else{
      print('ELSE::::');
      view.onHideLoader();
    }
  }

  Future deleteEvent(id,email)async{
    view.onShowLoader();
    Response deleteCalendarEvent = await apiHelper.api(method: Method.DELETE,token: token,endPoint: id,apiName: Constant().event,
        user: email);
    if(deleteCalendarEvent.runtimeType == null){
      print("RunTimeType${deleteCalendarEvent.runtimeType}");
    }
    else{
      view.onDelete(id);
      view.onHideLoader();
      // Response getCalendarEventList = await apiHelper.api(token: token,method: Method.GET,apiName: Constant().event,endPoint: Constant().event,isPageToken: false,maxResult: "10",currentTime: DateTime.now().toUtc().toString());
      // if(getCalendarEventList.statusCode == 200){
      //   isViewAttached ? getView().onEventSuccess(getCalendarEventList.data['items'],getCalendarEventList.data) : null;
      //   view.onHideLoader();
      //   print("RunTimeType${deleteCalendarEvent.runtimeType}");
      // }else{
      //   view.onHideLoader();
      //   print("RunTimeType${deleteCalendarEvent.runtimeType}");
      // }
    }
  }

  Future updatevent({String id, String email, String description, String summary, String startDate,
    String endDate,String timeZone})async{

    print("Token $token");
    print("description $description");
    print("summary $summary");
    print("timeZone $timeZone");
    print("End Date $endDate");
    print("Start Date $startDate");
    print("ID::: $id");
    print("email::: $email");

    if(timeZone==null){
      timeZone = "IST";
    }

    view.onShowLoader();

    Response postResponse = await apiHelper.api(apiName:Constant().event, method: Method.PUT,
        endPoint: id, user: email,token: token,
        body:jsonEncode(
            {
          "end": {
            "dateTime": endDate,
            "timeZone": timeZone
          },
          "start": {
            "dateTime": startDate,
            "timeZone": timeZone
          },
          "summary": summary,
          "description": description
        }
        )
    );
    print('update:::${postResponse.statusCode}');
    if (postResponse.statusCode == 200) {
      isViewAttached ? getView().onUpdateEvent(postResponse.data) : null;
      view.onHideLoader();

    } else {
      view.onHideLoader();
    }
  }

}