import 'dart:ui';
import 'package:appointment/utils/values/Constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


class CustomDialogBox extends StatefulWidget {
  Function(DateTime fromDate, DateTime toString) onTap;

  CustomDialogBox({this.onTap});

  @override
  _CustomDialogBoxState createState() => _CustomDialogBoxState();
}

class _CustomDialogBoxState extends State<CustomDialogBox> {
  DateTime _startDateTime;
  DateTime _endDateTime;
  var fromDate;
  var toDate;
  DateTime passFromDate;
  DateTime passToDate;
  SharedPreferences _sharedPreferences;


  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    _sharedPreferences = await SharedPreferences.getInstance();

    setState(() {


    if(_sharedPreferences.getString(Constant.FROM_DATE)==null|| _sharedPreferences.getString(Constant.TO_DATE)==null){
      _startDateTime = DateTime.now();
      _endDateTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day+1, DateTime.now().hour, DateTime.now().minute, DateTime.now().second);
    }else{
      _startDateTime = DateTime.parse(_sharedPreferences.getString(Constant.FROM_DATE));
      _endDateTime = DateTime.parse(_sharedPreferences.getString(Constant.TO_DATE));

    }

    passFromDate = _startDateTime.toUtc();
    passToDate = _endDateTime.toUtc();

    fromDate = DateFormat('EE, d MMM, yyyy HH:mm:ss').format(_startDateTime.toLocal());
    toDate = DateFormat('EE, d MMM, yyyy HH:mm:ss').format(_endDateTime.toLocal());

    print('local:::$passFromDate    $passToDate');});
  }

  // flutter: local:::2021-02-17 15:22:31.624463    2021-02-18 00:00:00.000

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context){
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 10,top: 20, right: 10,bottom: 10),
          margin: EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(color: Colors.black,offset: Offset(0,2),
                    blurRadius: 2
                ),
              ]
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              GestureDetector(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(padding: EdgeInsets.only(left: 10),
                        child: Text('From', style: TextStyle(fontSize: 14, fontFamily: 'poppins_regular', color: Colors.black))),

                    Padding(padding: EdgeInsets.only(left: 10),
                        child: Text(fromDate!=null?fromDate:"",
                        style: TextStyle(fontSize: 14, fontFamily: 'poppins_regular', color: Colors.black))),
                  ],
                ),
                onTap: (){
                  _fromDate(context);
                },
              ),

              SizedBox(height: 15),

              GestureDetector(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(padding: EdgeInsets.only(left: 10), child: Text('To', style: TextStyle(fontSize: 14, fontFamily: 'poppins_regular', color: Colors.black))),
                    Padding(padding: EdgeInsets.only(left: 10), child:
                    Text(toDate!=null?toDate:"", style: TextStyle(fontSize: 14, fontFamily: 'poppins_regular', color: Colors.black))),
                  ],
                ),

                onTap: (){
                  _toDate(context);
                },
              ),

              SizedBox(height: 15),

              Align(
                alignment: Alignment.centerRight,
                child: RaisedButton(
                  elevation: 0,
                  color: Colors.transparent,
                  // shape: RoundedRectangleBorder(
                  //   borderRadius: BorderRadius.circular(5),
                  // ),
                  child: Padding(
                    padding: EdgeInsets.all(5),
                      child: Text('Okay', textAlign: TextAlign.center, style: TextStyle(color: Colors.blue, fontSize: 14))),

                  onPressed: (){
                    Navigator.pop(context);
                    print('final:::$fromDate   $toDate');
                    widget.onTap(passFromDate, passToDate);
                  },
                ),
              )
            ],
          ),
        ),

      ],
    );
  }


  _fromDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _startDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(_startDateTime.year + 25),
    );

    if(picked != null && picked != _startDateTime)
      setState(() {
        _startDateTime = picked;
        fromDate = selectedDateTime(_startDateTime.toLocal());
      });

    passFromDate = _startDateTime.toUtc();
    print('passformt::::$passFromDate');
    _sharedPreferences.setString(Constant.FROM_DATE, _startDateTime.toString());
    return picked;
  }

  _toDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _endDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(_endDateTime.year + 25),
    );

    if(picked != null && picked != _endDateTime)
      setState(() {
        _endDateTime = picked;
        toDate = selectedDateTime(_endDateTime.toLocal());
      });

    passToDate = _endDateTime.toUtc();
    print('passToformt::::$passToDate');
    _sharedPreferences.setString(Constant.TO_DATE, _endDateTime.toString());
    return picked;
  }

  selectedDateTime(DateTime getdate){
    String dateTime;
    dateTime = DateFormat('EE, d MMM, yyyy HH:mm:ss').format(getdate);
    print('formatedDate:: $dateTime ');
    return dateTime;
  }

}
