import 'package:flutter/cupertino.dart';

import 'StringEn.dart';
import 'StringGu.dart';
import 'StringHi.dart';

abstract class Strings {
  String get title;
  String get googleBtnText;
  String get outLookBtnText;
  String get signInText;
  String get createAppointmentBtn;
  String get bottomSheetTitle;
  String get from;
  String get to;
  String get bottomSheetTfTitle;
  String get bottomSheetTfDesc;

}

class Resources {
  BuildContext _context;
  String code;
  Resources(this._context,this.code);

  Strings get strings {
    switch (code) {
      case 'hi':
        return StringsHindi();
      case 'gu':
        return StringsGujarati();
      default:
        return StringsEnglish();
    }
  }

  static Resources from(BuildContext context,String code){
    return Resources(context,code);
  }
}