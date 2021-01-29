import 'dart:math';

import 'package:appointment/home/model/CalendarList.dart';
import 'package:appointment/home/presenter/HomePresentor.dart';
import 'package:appointment/utils/Toast.dart';
import 'package:appointment/utils/values/Constant.dart';
import 'package:appointment/utils/values/Dimen.dart';
import 'package:appointment/utils/values/Palette.dart';
import 'package:appointment/utils/values/Strings/Strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'OnHomeView.dart';

class MyBottomSheet extends StatefulWidget {
  final String token;
  final List<Item> list;
  final List<Item> itemList;

  MyBottomSheet({this.token,this.list,this.itemList});

  @override
  _MyBottomSheetState createState() => _MyBottomSheetState();
}

class _MyBottomSheetState extends State<MyBottomSheet> implements OnHomeView{
  DateTime _startDateTime = DateTime.now();
  DateTime _currentTime = DateTime.now();

  HomePresenter _presenter;
  TextEditingController title =  TextEditingController();
  TextEditingController desc = TextEditingController();
  bool isVisible;
  int temp;
  @override
  void initState() {
    super.initState();
    startTime = _startDateTime.hour.toString() + ":" + _startDateTime.minute.toString();
    tempDate = DateFormat('EE, d MMM, yyyy').format(_currentTime);
    temp = _startDateTime.hour + 1;
    _endTime = temp.toString() + ":" + "00" ;
    print(_endTime);
    print(startTime);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
                padding: EdgeInsets.only(left: Dimen().dp_20,right: Dimen().dp_20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20.0),
                        topRight: const Radius.circular(20.0))),
                child: ListView(
                  children: [
                    Container(
                      child: Icon(Icons.remove,size: 40,color: Palette.colorPrimary,),
                    ),
                    Container(
                        child: TextFormField(
                          controller: title,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(top: Dimen().dp_10,bottom: Dimen().dp_10,left: 12),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(color: Palette.colorPrimary)
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 0,color: Colors.transparent)
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 0,color: Colors.transparent)
                              ),
                              fillColor: Colors.grey[200],
                              filled: true,
                              hintText: Resources.from(context,Constant.languageCode).strings.bottomSheetTfTitle,
                              hintStyle: TextStyle(fontSize: 15,fontFamily: 'poppins_medium')
                          ),
                          style: TextStyle(fontSize: 15,fontFamily: 'poppins_medium'),
                          cursorColor: Colors.black,
                        )
                    ),
                   GestureDetector(
                     child:Container(
                        margin: EdgeInsets.only(top: Dimen().dp_10),
                        child: Container(
                          padding: EdgeInsets.all(12),
                          alignment: Alignment.centerLeft,
                          color: Colors.grey[200],
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(Resources.from(context,Constant.languageCode).strings.event,style: TextStyle(fontSize: 15,fontFamily: 'poppins_medium'),textAlign: TextAlign.end,),
                                  Text('chirag.1sensussoft@gmail.com',style: TextStyle(fontSize: 12,fontFamily: 'poppins_regular'),textAlign: TextAlign.end,overflow: TextOverflow.ellipsis,)
                                ],
                              ),
                              Icon(Icons.keyboard_arrow_down,size: 25,)
                            ],
                          ),
                        )
                    ),
                     onTap: (){
                       calendarListDialog();
                       },
                   ),
                    Container(
                        margin: EdgeInsets.only(top: Dimen().dp_10),
                        child: TextFormField(
                          controller: desc,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 0,color: Colors.transparent)
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 0,color: Colors.transparent)
                              ),
                              fillColor: Colors.grey[200],
                              filled: true,
                              hintText: Resources.from(context,Constant.languageCode).strings.bottomSheetTfDesc,
                              hintStyle: TextStyle(fontSize: 15,fontFamily: 'poppins_medium')
                          ),
                          style: TextStyle(fontSize: 15,fontFamily: 'poppins_medium'),
                          cursorColor: Colors.black,
                          maxLines: 4,
                        )
                    ),
                    Container(
                      margin: EdgeInsets.only(top: Dimen().dp_10),
                      alignment: Alignment.centerLeft,
                      child: Text(Resources.from(context,Constant.languageCode).strings.date,style: TextStyle(fontSize: 15,fontFamily: 'poppins_medium'),),
                    ),
                    Container(
                            child: FlatButton(
                              onPressed: (){
                                _selectDate(context);
                              },
                              color: Colors.grey[200],
                              child: Text(tempDate??DateFormat('EE, d MMM, yyyy').format(_currentTime),style: TextStyle(fontSize: 15,fontFamily: 'poppins_medium'),),
                            ),
                          ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: Dimen().dp_10),
                                alignment: Alignment.centerLeft,
                                child: Text(Resources.from(context,Constant.languageCode).strings.start,style: TextStyle(fontSize: 15,fontFamily: 'poppins_medium'),),
                              ),
                              Container(
                                child: FlatButton(
                                  onPressed: (){
                                    _selectTime(context);
                                  },
                                  minWidth: MediaQuery.of(context).size.width * 0.40,
                                  color: Colors.grey[200],
                                  child: Text(startTime??"",style: TextStyle(fontSize: 15,fontFamily: 'poppins_medium'),),
                                ),
                              ),
                            ],
                          ),
                         Column(
                           children: [
                             Container(
                               margin: EdgeInsets.only(top: Dimen().dp_10),
                               alignment: Alignment.centerLeft,
                               child: Text(Resources.from(context,Constant.languageCode).strings.end,style: TextStyle(fontSize: 15,fontFamily: 'poppins_medium'),),
                             ),
                             Container(
                               child: FlatButton(
                                 onPressed: (){
                                   _endSelectTime(context);
                                 },
                                 minWidth: MediaQuery.of(context).size.width * 0.40,
                                 color: Colors.grey[200],
                                 child: Text(_endTime??"",style: TextStyle(fontSize: 15,fontFamily: 'poppins_medium'),),
                               ),
                             ),
                           ],
                           crossAxisAlignment: CrossAxisAlignment.start,
                         )
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: Dimen().dp_20,left: 80,right: 80),
                        child:FlatButton(
                          child: Text(Resources.from(context,Constant.languageCode).strings.saveBtn,style: TextStyle(fontSize: 15,fontFamily: 'poppins_medium',color: Colors.white)),
                          minWidth: MediaQuery.of(context).size.width * 0.30,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          onPressed: (){
                            // Constant.email = "chirag.1sensussoft@gmail.com";
                            _presenter = new HomePresenter(this,endDate: startDate+"T"+_endTime,startDate: startDate+"T"+startTime,timeZone: _currentTime.timeZoneName,summary: desc.text,token: widget.token);
                            _presenter.attachView(this);
                            _presenter.setAppointment();
                          },
                          color: Palette.colorPrimary,
                        )
                    ),
                  ],
                )
    );
  }
  ///Start Date
  String tempDate;
  String startDate;
  _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _currentTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(_currentTime.year + 25),
    );
    if (picked != null && picked != _startDateTime)
      setState(() {
        _startDateTime = picked;
        tempDate = DateFormat('EE, d MMM, yyyy').format(_startDateTime);
        startDate = _startDateTime.year.toString()  + "-" +_startDateTime.month.toString() + "-" + _startDateTime.day.toString();
      });
    print(startDate);
    return picked;
  }


  ///Start Time
  String _hour, startTime,_minute;
  TimeOfDay selectedTime = TimeOfDay();
  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null)
      setState(() {
          selectedTime = picked;
        _hour = selectedTime.hour.toString();
        _minute = selectedTime.minute.toString();
        startTime = _hour +":"+ _minute.toString();
      });
  }

  ///End Time
  String _endHour, _endTime,_endMinute;

  TimeOfDay endSelectedTime = TimeOfDay();
  Future<Null> _endSelectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null)
      setState(() {
        selectedTime = picked;
        _endHour = selectedTime.hour.toString();
        _endMinute = selectedTime.minute.toString();
        _endTime = _endHour +":"+ _endMinute.toString();
      });
  }

  calendarListDialog(){
    return showDialog(
      context: context,
      builder: (_){
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(Dimen().dp_20),
            height: MediaQuery.of(context).size.height * 0.30,
            child: ListView.builder(
              itemCount: widget.itemList.length,
              itemBuilder: (_,index){
                return Column(
                  children: [
                    SizedBox(height: Dimen().dp_20,),
                    Row(
                      children: [
                        Container(
                          margin: EdgeInsets.only(right: 10),
                          height: 20,
                          width: 20,
                          child:CircleAvatar(
                            backgroundColor: nextColor(),
                          ),
                        ),
                        Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width /2,
                                child: Text(
                                  widget.itemList[index].summary,overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: 'poppins_regular',
                                      color:
                                      Colors.black),
                                ),
                              ),

                            ],
                          ),
                      ],
                    ),
                  ],
                );
              },
            )
          )
        );
      }
    );
  }
  
  static const _MAX_VALUE = 0xFF00B8D4;
  final _random = Random();
  Color nextColor() => Color(_random.nextInt(_MAX_VALUE));

  @override
  onShowLoader() {
    setState(() {
      isVisible = true;
    });
  }

  @override
  onHideLoader() {
    setState(() {
      isVisible = false;
    });
  }

  @override
  onErrorHandler(String message) {
    setState(() {
      isVisible = false;
    });
    Toast toast = Toast();
    toast.overLay = false;
    toast.showOverLay(message, Colors.white, Colors.black54, context);
    // print('onError:::$message');
  }

  @override
  onSuccessRes(response) {
    print('onSucess:::$response');

  }

  @override
  onEventSuccess(response) {

  }

}
