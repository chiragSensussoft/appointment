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

abstract class IsCreatedOrUpdate{
  onCreatUpdate(bool bool);
}

class MyBottomSheet extends StatefulWidget {
  final String token;
  final List<Item> list;
  final List<Item> itemList;
  String title, description;
  bool isEdit;
  String summary;
  DateTime getStartDate, getendDate;
  String timeZone;
  String eventID;
  IsCreatedOrUpdate isCreatedOrUpdate;

  MyBottomSheet({this.token, this.list, this.itemList, this.title, this.description,
    this.getStartDate, this.getendDate, this.timeZone, this.isEdit, this.eventID, this.isCreatedOrUpdate});

  @override
  _MyBottomSheetState createState() => _MyBottomSheetState();
}

class _MyBottomSheetState extends State<MyBottomSheet> implements OnHomeView{
  DateTime _startDateTime;
  HomePresenter _presenter;
  TextEditingController title =  TextEditingController();
  TextEditingController desc = TextEditingController();
  FocusNode _titleFocus = FocusNode();
  FocusNode _discFocus = FocusNode();
  bool loader = false;
  String setEmail;
  TimeOfDay selectedStartTime;
  TimeOfDay selectedEndTime;


  @override
  void dispose() {
    super.dispose();
    _discFocus.unfocus();
  }

  @override
  void initState() {
    super.initState();
    widget.isEdit? _startDateTime = widget.getStartDate.toLocal() :_startDateTime = DateTime.now();

    startDate = _startDateTime.year.toString()  + "-" +_startDateTime.month.toString() + "-" + _startDateTime.day.toString();

    _startTime = Constant.getTimeFormat(_startDateTime);

    widget.isEdit ?_endTime = Constant.getTimeFormat(widget.getendDate.toLocal())
        :_endTime =  (_startDateTime.toLocal().hour + 1).toString()+":"
        + _startDateTime.toLocal().minute.toString()+ ":"+ _startDateTime.toLocal().second.toString();

    /*set text for edit*/
    widget.isEdit? title.text = widget.title : null;
    widget.isEdit? desc.text = widget.description : null;
    widget.isEdit? setEmail = Constant.email : null;

    selectedStartTime = TimeOfDay(hour: _startDateTime.hour, minute: _startDateTime.minute);
    selectedEndTime = TimeOfDay(hour: _startDateTime.hour, minute: _startDateTime.minute);

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
                  focusNode: _titleFocus,
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
                  onSaved: (val){
                    _titleFocus.unfocus();
                  },
                )
            ),
            GestureDetector(
              child:Container(
                margin: EdgeInsets.only(top: 10),
                padding: EdgeInsets.all(12),
                alignment: Alignment.centerLeft,
                color: Colors.grey[200],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 9,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Resources.from(context, Constant.languageCode).strings.event,
                            style: TextStyle(
                                fontSize: 15, fontFamily: 'poppins_medium'),
                            textAlign: TextAlign.end,
                          ),
                          Text(
                            setEmail??"",
                            style: TextStyle(
                                fontSize: 12, fontFamily: 'poppins_regular'),
                            overflow: TextOverflow.ellipsis,
                          )
                        ],
                      ),
                    ),

                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 25,
                    )
                  ],
                ),
              ),
              onTap: (){
                calendarListDialog();
              },
            ),

            Container(
                margin: EdgeInsets.only(top: Dimen().dp_10),
                child: TextFormField(
                  controller: desc,
                  focusNode: _discFocus,
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

                  onSaved: (val){
                    _discFocus.unfocus();
                  },
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
                  _discFocus.unfocus();
                  _selectDate(context);
                },
                color: Colors.grey[200],
                child: Text(DateFormat('EE, d MMM, yyyy').format(_startDateTime),style: TextStyle(fontSize: 15,fontFamily: 'poppins_medium'),),
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
                          child: Text(_startTime??"",style: TextStyle(fontSize: 15,fontFamily: 'poppins_medium'),),
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
                  // child: TextStylext(Resources.from(context,Constant.languageCode).strings.saveBtn,style: TextStyle(fontSize: 15,fontFamily: 'poppins_medium',color: Colors.white)),
                  child: Text(widget.isEdit? 'Update': 'save', style: TextStyle(fontSize: 15,fontFamily: 'poppins_medium',color: Colors.white)),
                  minWidth: MediaQuery.of(context).size.width * 0.30,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),

                  onPressed: (){
                    if(title.text.isEmpty||desc.text.isEmpty||startDate == ""){
                      print(startDate);
                      toast.overLay = false;
                      toast.showOverLay("Fill all details", Colors.white, Colors.black54, context);

                      }else if(desc.text.length < 50){
                      toast.overLay = false;
                      toast.showOverLay("Description must be 50 char long!", Colors.white, Colors.black54, context);


                      } else if(startDate == DateFormat('EE, d MMM, yyyy').format(_startDateTime)){
                      toast.overLay = false;
                      toast.showOverLay("Select Date", Colors.white, Colors.black54, context);

                    } else{

                        if(_startHour!="") {
                           if(!widget.isEdit) {
                             if (int.parse(_startHour) > (_startDateTime.hour + 1)) {
                               toast.overLay = false;
                               toast.showOverLay(
                                   "End Time should be grater than Start date",
                                   Colors.white, Colors.black54, context);
                             } else {
                               createAppointment();
                             }

                           }else{
                             if(int.parse(_startHour) > widget.getendDate.hour || int.parse(_startMinute) > widget.getendDate.minute){
                               toast.overLay = false;
                               toast.showOverLay(
                                   "End Time should be grater than Start date",
                                   Colors.white, Colors.black54, context);
                             }else{
                               createAppointment();
                             }
                           }

                        }else{
                          createAppointment();
                        }
                      }
                  },
                  color: Palette.colorPrimary,
                )
            ),
          ],
        )
    );
  }


  void createAppointment() {
    _presenter = new HomePresenter(this, token: widget.token);
    _presenter.attachView(this);

    widget.isEdit?
    _presenter.updatevent(endDate: startDate+"T"+_endTime, startDate: startDate+"T"+_startTime,
        timeZone: widget.timeZone, summary: title.text, description: desc.text,
        id: widget.eventID, email: setEmail) :

    _presenter.setAppointment(endDate: startDate+"T"+_endTime,startDate: startDate+"T"+_startTime,
        timeZone: _startDateTime.timeZoneName, summary: title.text, description: desc.text);
  }


  Toast toast = Toast();

  ///Start Date
  String startDate;
  String selecteDate;

  _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _startDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(_startDateTime.year + 25),
    );

    if(picked != null && picked != _startDateTime)
      setState(() {
        _startDateTime = picked;
        startDate = _startDateTime.year.toString()  + "-" +_startDateTime.month.toString() + "-" + _startDateTime.day.toString();
      });
    print('format:::$startDate');
    return picked;
  }


  ///Start Time
  String _startHour = "", _startTime,_startMinute;

  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null)
      setState(() {
         selectedStartTime = picked;
        _startHour = selectedStartTime.hour.toString();
        _startMinute = selectedStartTime.minute.toString();

        if(_startMinute.length!=2){
          _startMinute = "0"+_startMinute;
        }
        if(_startHour.length!=2){
          _startHour = "0"+_startHour;
        }

         if(_startDateTime.day == DateTime.now().day && _startDateTime.month == DateTime.now().month){
           if(int.parse(_startHour) > DateTime.now().hour || int.parse(_startMinute) > DateTime.now().minute){
             _startTime = _startHour +":"+ _startMinute +":" +"00";
           }else{
             toast.overLay = false;
             toast.showOverLay("Start time should be greater than Current time!", Colors.white, Colors.black54, context);
           }
         }
      });
  }

  ///End Time
  String _endHour = "", _endTime,_endMinute;

  Future<Null> _endSelectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null)
          setState(() {
            selectedEndTime = picked;
            _endHour = selectedEndTime.hour.toString();
            _endMinute = selectedEndTime.minute.toString();

            if(_endMinute.length!=2){
              _endMinute = "0"+_endMinute;
            }
            if(_endHour.length!=2){
              _endHour = "0"+_endHour;
            }

            print('1::$_startHour   $_startMinute');
            print('2::$_endHour   $_endMinute');
            print('3::${_startDateTime.hour}   ${_startDateTime.minute}');

            if(_startHour!=""){
              if(int.parse(_endHour)>int.parse(_startHour) && int.parse(_endMinute) > int.parse(_startMinute)){
                _endTime = _endHour +":"+ _endMinute+":"+"00";

              }else{
                toast.overLay = false;
                toast.showOverLay("End time should be greater than Start time!", Colors.white, Colors.black54, context);
              }

            }else{
              if(_startDateTime.hour < int.parse(_endHour)  && _startDateTime.minute < int.parse(_endMinute)){
                _endTime = _endHour +":"+ _endMinute+":"+"00";
              }else{
                toast.overLay = false;
                toast.showOverLay("End time should be greater than Start time!", Colors.white, Colors.black54, context);
              }
            }
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
                      return GestureDetector(
                        onTap: (){
                          setState(() {
                            setEmail = widget.itemList[index].id;
                            Constant.email = setEmail;
                            Navigator.pop(context);
                          });
                        },

                        child: Container(
                          padding: EdgeInsets.only(top: 12),
                          child: Row(
                            children: [
                              Container(
                                margin: EdgeInsets.only(right: 10),
                                height: 20,
                                width: 20,
                                child: CircleAvatar(
                                    backgroundColor : widget.itemList[index].id ==setEmail? Palette.colorPrimary:Colors.grey),
                              ),

                              Container(
                                width: MediaQuery.of(context).size.width / 2,
                                child: Text(
                                  widget.itemList[index].summary,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: 'poppins_regular',
                                      color: Colors.black
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
              )
          );
        }
    );
  }

  @override
  onShowLoader() {
    setState(() {
      loader = true;
    });
  }

  @override
  onHideLoader() {
    setState(() {
      loader = false;
    });
  }

  @override
  onErrorHandler(String message) {
    setState(() {
      loader = true;
    });
    toast.overLay = false;
    toast.showOverLay(message, Colors.white, Colors.black54, context);
  }

  @override
  onSuccessRes(response) {
    print('onSucess:::$response');
  }

  @override
  onEventSuccess(response,calendarResponse) {
    print("success");
  }

  @override
  onCreateEvent(response) {
    print('onSucess:::$response');
    Navigator.pop(context);
    toast.overLay = false;
    toast.showOverLay("Appointment created successfully", Colors.white, Colors.black54, context);
    widget.isCreatedOrUpdate.onCreatUpdate(true);
  }

  @override
  onUpdateEvent(response) {
    print('onUpdate:::$response');
    Navigator.pop(context);
    toast.overLay = false;
    toast.showOverLay("Appointment updated successfully", Colors.white, Colors.black54, context);
    widget.isCreatedOrUpdate.onCreatUpdate(true);
  }

  @override
  onDelete(delete) {

  }

}
