import 'dart:convert';

import 'package:appointment/utils/APIClient.dart';
import 'package:appointment/utils/BasePresenter.dart';
import 'package:appointment/utils/values/Constant.dart';
import 'package:dio/dio.dart';

import '../OnHomeView.dart';

class HomePresenter extends BasePresenter<OnHomeView>  {
  OnHomeView view;
  APIClient apiHelper;
  String endDate;
  String timeZone;
  String startDate;
  String summary;
  String token;
  HomePresenter(this.view,{this.endDate,this.timeZone,this.startDate,this.summary,this.token}) {
    apiHelper = APIClient(view);
  }

  // var token = 'ya29.a0AfH6SMAynmQVP8rt-t-e3cJk25Rj5HAEYC44OH60dqr6s3NVe-Yls_yAA67vFiXsUMju2obc3QH4k_zQvvrffzz3TR8CNXS22e5t-qeFTREzgtGAWaXA4py1vFAqF2Wa9es5PiAnlZT3ur4tBRXQ9vgAwH2YkjLr3vk3sd6T0Lc';

      Future getText() async {
        view.onShowLoader();

        Response postResponse = await apiHelper.api(
             apiName:Constant().event,method:  Method.POST,
            body:jsonEncode({
              "end": {
                "dateTime": endDate,
                "timeZone": timeZone
              },
              "start": {
                "dateTime": startDate,
                "timeZone": timeZone
              },
              "summary": summary
            }),token: token);

        if (postResponse.statusCode == 200) {
          isViewAttached ? getView().onSuccessRes(postResponse.data['data']) : null;
          view.onHideLoader();

        } else {
          view.onHideLoader();
    }
  }

  Future getCalendar()async{
    view.onShowLoader();
    Response getCalendarList = await apiHelper.api(token: token,method: Method.GET,apiName: Constant().calendar);

    if (getCalendarList.statusCode == 200) {
      isViewAttached ? getView().onSuccessRes(getCalendarList.data['items']) : null;
      view.onHideLoader();
    } else {
      view.onHideLoader();
    }
  }

}