import 'package:flutter/cupertino.dart';

import 'StringEn.dart';
import 'StringGu.dart';
import 'StringHi.dart';

abstract class Strings {
  String get title;
  String get googleBtnText;
  String get outLookBtnText;
  String get signInText;
  String get saveBtn;
  String get date;
  String get location;
  String get start;
  String get bottomSheetTfTitle;
  String get bottomSheetTfDesc;
  String get event;
  String get end;
  String get update;
  //સુધારો
  String get dialogPastEvent;
  //તમે પાછલી ઇવેન્ટ બનાવી શકતા નથી
  //You can't create past event
  String get dialogCreateOwnEvent;
  //તમે તમારી નિમણૂક સ્વીકારવાનો પ્રયાસ કરી રહ્યાં છો
  //You trying to accept your appointment
  String get okay;
  //બરાબર
  //okay
  String get cancel;
  //રદ કરો
  //cancel
  String get endTimeDialog;
  //End time should be greater than Start time
  //અંતિમ સમય પ્રારંભ સમય કરતા વધારે હોવો જોઈએ
  String get startTimeDialog;
  //પ્રારંભ સમય વર્તમાન સમય કરતા વધારે હોવો જોઈએ
  //Start time should be greater than Current time
  String get eventCreateMsg;
  //Appointment created successfully
  //નિમણૂક સફળતાપૂર્વક બનાવવામાં આવી
  String get eventUpdateMsg;
  //Appointment updated successfully
  //નિમણૂક સફળતાપૂર્વક સુધારો કર્યું
  String get selectCalendar;
  //Select current calender
  //વર્તમાન કેલેન્ડર પસંદ કરો
  String get errorTitleTxt;
  //Please add title
  //કૃપા કરીને શીર્ષક ઉમેરો
  String get errorDescTxt;
  //Please add description
  //કૃપા કરીને વર્ણન ઉમેરો
  String get errorDescLength;
  //Description must be 50 char long
  //વર્ણન 50 અક્ષર લાંબું હોવું જોઈએ
  String get invalidData;
  //Data is not valid
  //ડેટા માન્ય નથી
  String get createNewEvent;
  //Create New Event
  //નવી ઇવેન્ટ બનાવો
  String get showMore;
  //...વધારે બતાવ
  //...Show more
  String get showLess;
  // show less
  // ઓછા બતાવો
  String get accept;
  //Accept
  //સ્વીકારો
  String get conformDelete;
  //Are you sure you want to delete this Event?
  //શું તમે ખરેખર આ ઇવેન્ટને કા.ી નાખવા માંગો છો?
  String get no;
  //ના
  //No
  String get yes;
  //હા
  //Yes
  String get delete;
  //delete
  //हटाए
  //કા .ી નાખો
  String get defaultUser;
  //डिफॉल्ट उपयोगकर्ता
  //ડિફॉलલ્ટ વપરાશકર્તા
  //Default User
  String get checkInternet;
  // ઇન્ટરનેટ કનેક્શન ઉપલબ્ધ નથી
  //कोई इंटरनेट कनेक्शन उपलब्ध नहीं है
  //No Internet connection available!
  String get apply;
  String get home;
  //હોમ
  //Home
  //होम
  String get map;
  //नक्शा
  //નકશો
  //Map
  String get more;
  //More
  //વધુ
  //अधिक
  String get eventDeleteMsg;

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