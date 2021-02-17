import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class CustomDialogBox extends StatefulWidget {
  Function(DateTime fromDate, DateTime toString) onTap;

  CustomDialogBox({this.onTap});


  @override
  _CustomDialogBoxState createState() => _CustomDialogBoxState();
}

class _CustomDialogBoxState extends State<CustomDialogBox> {
  DateTime _startDateTime = DateTime.now();
  var fromDate = DateFormat('EE, d MMM, yyyy HH:mm:ss').format(DateTime.now().toLocal());
  var toDate = DateFormat('EE, d MMM, yyyy HH:mm:ss').format(DateTime.now().toLocal());
  DateTime passFromDate;
  DateTime passToDate;

  @override
  void initState() {
    passFromDate = _startDateTime.toUtc();
    passToDate = _startDateTime.toUtc();
    super.initState();
  }


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
                        child: Text(fromDate,
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
                    Text(toDate,
                        style: TextStyle(fontSize: 14, fontFamily: 'poppins_regular', color: Colors.black))),
                  ],
                ),

                onTap: (){
                  _toDate(context);
                },
              ),

              SizedBox(height: 15),

              Align(
                alignment: Alignment.center,
                child: RaisedButton(
                  elevation: 3,
                  color: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text('Okay', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 14)),

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

  _CustomDialogBoxState();


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
    print('S::::${_startDateTime.isUtc}');
    passFromDate = _startDateTime.toUtc();
    print('passformt::::$passFromDate');
    return picked;
  }

  _toDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _startDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(_startDateTime.year + 25),
    );

    if(picked != null && picked != _startDateTime)
      setState(() {
        _startDateTime = picked;
        toDate = selectedDateTime(_startDateTime.toLocal());
      });

    passToDate = _startDateTime.toUtc();
    print('passToformt::::$passToDate');
    return picked;
  }

  selectedDateTime(DateTime getdate){
    String dateTime;
    dateTime = DateFormat('EE, d MMM, yyyy HH:mm:ss').format(getdate);
    print('formatedDate:: $dateTime ');
    return dateTime;
  }

  formated_pass_date(DateTime getdate){
    String utcdate;
    var date = getdate.toString().split(" ");
    var date_1 = date[1].split(".");
    utcdate = date[0]+"T"+date_1[0];
    print('split:::::$utcdate');
    return utcdate;
  }
}
