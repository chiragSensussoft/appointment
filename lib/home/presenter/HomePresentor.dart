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
  HomePresenter(this.view,{this.endDate,this.timeZone,this.startDate,this.summary}) {
    apiHelper = APIClient(view);
  }

  var token = 'ya29.a0AfH6SMCEAuBqk2qUnH4tgNLBma6cMxomsPLyf6qgwqcdrK6Pr7KuiW8Oo38wv5VD_o9UjuOqbRbcOGU_gzikiqzQQ1wePK1WrbxUOVO9m1otIbi-CLNPmITkhndYylq7AeAWQPd7DsJN8uvfPnyDSm9KKwrK5IaTh2NP5-CbN6g';

      Future getText() async {
        view.onShowLoader();

        Response response = await apiHelper.api(
            Constant().event, Method.POST,
            jsonEncode({
              "end": {
                "dateTime": endDate,
                "timeZone": timeZone
              },
              "start": {
                "dateTime": startDate,
                "timeZone": timeZone
              },
              "summary": summary
            }), token);

        if (response.statusCode == 200) {
          isViewAttached ? getView().onSuccessRes(response.data['data']) : null;
          view.onHideLoader();

        } else {
          view.onHideLoader();
    }
  }
}