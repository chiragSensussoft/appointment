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

  var token = 'ya29.a0AfH6SMC3NeAgbrgCpIUrA-B9vwpYSIYqY6TYhHBeULxPQri4ZvuDWTph8vIJVBi2gkopSj55qJQaRh6ZzMt_S0T9VYgdK11yCVZNNZYaRpS9oAmZlrgF2BXNIyueYmYthfvUS7dgbTRqtBjALOOMT_pQ0PZ8-sua0k_k6HlkOvw';

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