
import 'package:appointment/interface/BaseLoaderView.dart';

abstract class OnHomeView extends BaseLoaderView{
  onSuccessRes(response);
  onEventSuccess(response,calendarResponse);
}