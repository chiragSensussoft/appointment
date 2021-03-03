import 'dart:convert';

import 'package:appointment/home/model/CalendarList.dart';
import 'package:appointment/home/presenter/HomePresentor.dart';
import 'package:appointment/interface/IsAcceptAppointment.dart';
import 'package:appointment/interface/IsCreatedOrUpdate.dart';
import 'package:appointment/utils/progressbar.dart';
import 'package:appointment/utils/values/Constant.dart';
import 'package:appointment/utils/values/Dimen.dart';
import 'package:appointment/utils/values/Palette.dart';
import 'package:appointment/utils/values/Strings/Strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofence/geofence.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'OnHomeView.dart';


class MyBottomSheet extends StatefulWidget {
  String title, description;
  bool isEdit;
  String summary;
  DateTime getStartDate, getendDate;
  String timeZone;
  String eventID;
  IsCreatedOrUpdate isCreatedOrUpdate;
  String calenderId;
  LatLng latLng;
  String address;
  bool isDelete;
  DeleteEvent deleteEvent;


  MyBottomSheet({this.title,
      this.description,
      this.getStartDate,
      this.getendDate,
      this.timeZone,
      this.isEdit,
      this.eventID,
      this.isCreatedOrUpdate,
      this.calenderId,
      this.latLng,
      this.address,
  this.isDelete,
  this.deleteEvent});

  @override
  _MyBottomSheetState createState() => _MyBottomSheetState();
}

class _MyBottomSheetState extends State<MyBottomSheet> implements OnHomeView, IsAcceptAppointment {
  DateTime _startDateTime;
  HomePresenter _presenter;
  TextEditingController title = TextEditingController();
  TextEditingController desc = TextEditingController();
  TextEditingController location = TextEditingController();
  FocusNode _titleFocus = FocusNode();
  FocusNode _discFocus = FocusNode();
  bool loader = false;
  TimeOfDay selectedStartTime;
  TimeOfDay selectedEndTime;
  bool isVisible = false;
  final _formKey = GlobalKey<FormState>();
  SharedPreferences _sharedPreferences;
  String address = "";
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  String token;
  List<dynamic> itemList;


  @override
  void dispose() {
    super.dispose();
    _discFocus.unfocus();
  }

  init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    token = _sharedPreferences.getString(Constant.ACCESS_TOKEN);
    itemList = json.decode(_sharedPreferences.getString(Constant.ITEM_LIST));
    print('getList:::$itemList');
  }


  @override
  void initState() {
    super.initState();
    init();

    // widget.isEdit? address = widget.address: widget.latLng!= null?getLocation() : null;

    print("fmfnfhgfj::::${widget.address}");
    if (widget.isEdit) {
      widget.address != null ? address = widget.address : address = null;
    } else {
      widget.latLng != null ? getLocation() :  address = null;
    }

    widget.isEdit ? _startDateTime = widget.getStartDate.toLocal() : _startDateTime = DateTime.now();

    startDate = _startDateTime.year.toString() + "-" + _startDateTime.month.toString() + "-" + _startDateTime.day.toString();

    _startHour = _startDateTime.hour.toString();
    _startMinute = _startDateTime.minute.toString();
    _startTime = Constant.getTimeFormat(_startDateTime);

    start = DateTime(_startDateTime.year, _startDateTime.month,
        _startDateTime.day, int.parse(_startHour), int.parse(_startMinute));

    if (widget.isEdit) {
      _endHour = widget.getendDate.toLocal().hour.toString();
      _endMinute = widget.getendDate.toLocal().minute.toString();
      _endTime = Constant.getTimeFormat(widget.getendDate.toLocal());

    } else {
      _endHour = (_startDateTime.toLocal().hour + 1).toString();
      _endMinute = _startDateTime.toLocal().minute.toString();
      _endTime = (_startDateTime.toLocal().hour + 1).toString() + ":" +
          _startDateTime.toLocal().minute.toString() + ":" + _startDateTime.toLocal().second.toString();
    }

    end = DateTime(_startDateTime.year, _startDateTime.month,
        _startDateTime.day, int.parse(_endHour), int.parse(_endMinute));

    /*set text for edit*/
    widget.isEdit ? title.text = widget.title : null;
    widget.isEdit ? desc.text = widget.description : null;
    Constant.SET_CAL_ID = Constant.SET_CAL_ID==null ? Constant.email : Constant.SET_CAL_ID;

    selectedStartTime = TimeOfDay();
    selectedEndTime = TimeOfDay();

    initPlatformState();

    var initializationSettingsAndroid = new AndroidInitializationSettings('@mipmap/ic_launcher.png');
    var initializationSettingsIOS = IOSInitializationSettings(onDidReceiveLocalNotification: null);
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: null);
  }

  getLocation() async {
    final coordinates = new Coordinates(widget.latLng.latitude, widget.latLng.longitude);
    var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    setState(() {
      address = first.addressLine;
    });
  }

  Future<void> initPlatformState() async {
    if (!mounted) return;
    Geofence.initialize();
    Geofence.startListening(GeolocationEvent.entry, (entry) {
      scheduleNotification("Entry of a georegion", "Welcome to: ${entry.id}");
    });

    Geofence.startListening(GeolocationEvent.exit, (entry) {
      scheduleNotification("Exit of a georegion", "Byebye to: ${entry.id}");
    });

    setState(() {});
  }

  void scheduleNotification(String title, String subtitle) {
    print("scheduling one with $title and $subtitle");
    Future.delayed(Duration(seconds: 5)).then((result) async {
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
          'your channel id', 'your channel name', 'your channel description',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker');
      var iOSPlatformChannelSpecifics = IOSNotificationDetails();
      var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(0, title, subtitle, platformChannelSpecifics, payload: 'item x');
    });
  }


 _getLocation(LatLng latLng) async {
    final coordinates = new Coordinates(latLng.latitude, latLng.longitude);
    var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    setState(() {
      address = first.addressLine;
    });

    print("CALLED::::${first.addressLine}");
    return first.addressLine;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
          padding: EdgeInsets.only(left: Dimen().dp_20, right: Dimen().dp_20),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20.0),
                  topRight: const Radius.circular(20.0)
              )
          ),

          child: Column(
            children: [
              Container(
                child: Icon(Icons.remove, size: 40, color: Palette.colorPrimary),
              ),

              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Container(
                        child: TextFormField(
                          controller: title,
                          focusNode: _titleFocus,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(top: Dimen().dp_10, bottom: Dimen().dp_10, left: 12,right: 12),

                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 0, color: Colors.transparent)),

                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 0, color: Colors.transparent)),

                              errorBorder: OutlineInputBorder(borderSide: BorderSide(width: 1, color: Colors.red)),

                              fillColor: Colors.grey[200],
                              filled: true,
                              hintText: Resources.from(context, Constant.languageCode).strings.bottomSheetTfTitle,
                              hintStyle: TextStyle(fontSize: 14, fontFamily: 'poppins_medium')),

                          style: TextStyle(fontSize: 14, fontFamily: 'poppins_medium'),
                          cursorColor: Colors.black,
                          onSaved: (val) {
                            _titleFocus.unfocus();
                          },

                          validator: (value) {
                            if (value.isEmpty) {
                              return Resources.from(context, Constant.languageCode).strings.errorTitleTxt;
                            }
                            return null;
                          },
                        ),
                    ),

                    GestureDetector(
                      child: Container(
                        margin: EdgeInsets.only(top: 10),
                        padding: EdgeInsets.all(10),
                        alignment: Alignment.centerLeft,
                        color: Colors.grey[200],

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    Resources.from(context, Constant.languageCode).strings.event,
                                    style: TextStyle(fontSize: 14, fontFamily: 'poppins_medium'),
                                    textAlign: TextAlign.end,
                                  ),

                                  Text(
                                    Constant.SET_CAL_ID ?? "",
                                    style: TextStyle(fontSize: 12, fontFamily: 'poppins_regular'),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.only(top: 5, bottom: 5),
                              child: Icon(
                                Icons.keyboard_arrow_down,
                                size: 20,
                              ),
                            )
                          ],
                        ),
                      ),

                      onTap: () {
                        setState(() {
                          calendarListDialog();
                        });
                      },
                    ),

                    Container(
                        margin: EdgeInsets.only(top: Dimen().dp_10),
                        child: TextFormField(
                          controller: desc,
                          focusNode: _discFocus,
                          maxLength: 500,
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 0, color: Colors.transparent)),

                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 0, color: Colors.transparent)),

                              errorBorder: OutlineInputBorder(borderSide: BorderSide(
                                  width: 1, color: Colors.red)),

                              fillColor: Colors.grey[200],
                              filled: true,
                              hintText: Resources.from(context, Constant.languageCode).strings.bottomSheetTfDesc, hintStyle: TextStyle(
                              fontSize: 14, fontFamily: 'poppins_medium')), style: TextStyle(fontSize: 14, fontFamily: 'poppins_medium'),
                          cursorColor: Colors.black,
                          maxLines: 4,
                          onSaved: (val) {
                            _discFocus.unfocus();
                          },

                          validator: (value) {
                            if (value.isEmpty) {
                              return Resources.from(context, Constant.languageCode).strings.errorDescTxt;

                            }else if(value.length<50){
                              return Resources.from(context, Constant.languageCode).strings.errorDescLength;
                            }
                            return null;
                          },
                        )
                    ),

                    Visibility(
                      visible: address!=null,
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: Dimen().dp_10),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              Resources.from(context, Constant.languageCode).strings.location,
                              style: TextStyle(fontSize: 14, fontFamily: 'poppins_medium'),
                            ),
                          ),

                          Container(
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.only(top: 10),
                            padding: EdgeInsets.only(top: 12, bottom: 12, left: 10, right: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                            ),
                            child: Expanded(
                              child: Text(
                                address??"",
                                style: TextStyle(fontSize: 14, fontFamily: "poppins_regular", color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),


                    Container(
                      margin: EdgeInsets.only(top: Dimen().dp_10),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        Resources.from(context, Constant.languageCode).strings.date,
                        style: TextStyle(fontSize: 14, fontFamily: 'poppins_medium'),
                      ),
                    ),

                    Container(
                      child: FlatButton(
                        onPressed: () {
                          _discFocus.unfocus();
                          _selectDate(context);
                        },
                        color: Colors.grey[200],
                        child: Text(
                          DateFormat('EE, d MMM, yyyy').format(_startDateTime),
                          style: TextStyle(fontSize: 14, fontFamily: 'poppins_medium'),
                        ),
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
                                child: Text(
                                  Resources.from(context, Constant.languageCode).strings.start,
                                  style: TextStyle(fontSize: 14, fontFamily: 'poppins_medium'),
                                ),
                              ),

                              Container(
                                child: FlatButton(
                                  onPressed: () {
                                    _selectTime(context);
                                  },
                                  minWidth: MediaQuery.of(context).size.width * 0.40,
                                  color: Colors.grey[200],
                                  child: Text(
                                    _startTime ?? "", style: TextStyle(fontSize: 14, fontFamily: 'poppins_medium'),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Column(
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: Dimen().dp_10),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  Resources.from(context, Constant.languageCode).strings.end,
                                  style: TextStyle(fontSize: 14, fontFamily: 'poppins_medium'),
                                ),
                              ),

                              Container(
                                child: FlatButton(
                                  onPressed: () {
                                    _endSelectTime(context);
                                  },
                                  minWidth: MediaQuery.of(context).size.width * 0.40,
                                  color: Colors.grey[200],
                                  child: Text(
                                    _endTime ?? "", style: TextStyle(fontSize: 14, fontFamily: 'poppins_medium'),
                                  ),
                                ),
                              ),
                            ],
                            crossAxisAlignment: CrossAxisAlignment.start,
                          )
                        ],
                      ),
                    ),

                    // Container(
                    //     margin: EdgeInsets.only(top: Dimen().dp_20, left: 80, right: 80, bottom: 20),
                    //     child: FlatButton(
                    //       child: Text(widget.isEdit ? Resources.from(context,Constant.languageCode).strings.update : Resources.from(context,Constant.languageCode).strings.saveBtn,
                    //           style: TextStyle(fontSize: 16, fontFamily: 'poppins_medium', color: Colors.white)),
                    //       minWidth: MediaQuery.of(context).size.width * 0.30,
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(30),
                    //       ),
                    //
                    //       onPressed: () {
                    //         if (_formKey.currentState.validate()) {
                    //           if(isVisible){
                    //             createAppointment();
                    //
                    //           }else{
                    //             Constant.showToast(Resources.from(context, Constant.languageCode).strings.selectCalendar, Toast.LENGTH_SHORT);
                    //             // toast.overLay = false;
                    //             // toast.showOverLay(Resources.from(context, Constant.languageCode).strings.selectCalendar, Colors.white, Colors.black54, context);
                    //           }
                    //         }
                    //       },
                    //       color: Palette.colorPrimary,
                    //     )
                    // ),

                    SizedBox(height: 20),

                    ProgressButton(isAccept: this, text: widget.isEdit ? 'Update' : 'save',
                        formKey: _formKey, isVisible: true, color: Colors.blue),

                    Visibility(
                     visible: widget.isDelete,
                      child: Container(
                          margin: EdgeInsets.only(top: 20),
                          child: ProgressButton(text: "Delete", color: Colors.redAccent, id: widget.eventID, isAccept: this,
                          email: widget.calenderId)
                      ),
                    ),

                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          )
      ),
    );
  }

  void createAppointment() {
    print("pass_Adress:::::$address   $token");
    _presenter = new HomePresenter(this, token: token);
    _presenter.attachView(this);

    widget.isEdit
        ? _presenter.updatevent(
            endDate: startDate + "T" + _endTime,
            startDate: startDate + "T" + _startTime,
            timeZone: widget.timeZone,
            summary: title.text,
            description: desc.text,
            id: widget.eventID,
            email: Constant.email,
            coords: address==null?"":widget.latLng.latitude.toString()+","+widget.latLng.longitude.toString(),
            address: address)

        : _presenter.setAppointment(
            endDate: startDate + "T" + _endTime,
            startDate: startDate + "T" + _startTime,
            timeZone: _startDateTime.timeZoneName,
            summary: title.text,
            coords: address==null?"":widget.latLng.latitude.toString()+","+widget.latLng.longitude.toString(),
            description: desc.text,
            address: address);
  }

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
  String _startHour, _startTime,_startMinute;
  var start;

  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: int.parse(_startHour), minute: int.parse(_startMinute)),
    );

    if (picked != null)
      setState(() {
        selectedStartTime = picked;
        _startHour = selectedStartTime.hour.toString();
        _startMinute = selectedStartTime.minute.toString();

        start = DateTime(_startDateTime.year, _startDateTime.month, _startDateTime.day, int.parse(_startHour), int.parse(_startMinute));

        if(start.isAfter(DateTime.now())){
          _startTime = _startHour +":"+ _startMinute +":" +"00";
        }else{
          messageDialog("Start Time");
        }
      });
  }

  ///End Time
  String _endHour, _endTime,_endMinute;
  var end;

  Future<Null> _endSelectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: int.parse(_endHour), minute: int.parse(_endMinute)),
    );

    if (picked != null)
      setState(() {
        selectedEndTime = picked;
        _endHour = selectedEndTime.hour.toString();
        _endMinute = selectedEndTime.minute.toString();

        end = DateTime(_startDateTime.year, _startDateTime.month,
            _startDateTime.day, int.parse(_endHour), int.parse(_endMinute));

        if(end.isAfter(start)){
          _endTime = _endHour +":"+ _endMinute+":"+"00";
        }else{
          messageDialog("End Time");
        }
      });
  }

  calendarListDialog() {
    return showDialog(
        context: context,
        builder: (_) {
          return Dialog(
              child: Container(
                  padding: EdgeInsets.all(Dimen().dp_20),
                  height: MediaQuery.of(context).size.height * 0.30,
                  child: ListView.builder(
                    itemCount: itemList.length,
                    itemBuilder: (_, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            Constant.SET_CAL_ID = itemList[index]['summary'];
                            Constant.email = itemList[index]["id"];
                            Navigator.pop(context);
                            isVisible = true;
                            FocusScope.of(context).requestFocus(FocusNode());
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.only(top: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                margin: EdgeInsets.only(right: 10),
                                height: 15,
                                width: 15,
                                child: CircleAvatar(
                                    backgroundColor: itemList[index]["id"] == Constant.email ? Palette.colorPrimary : Colors.grey),
                              ),
                              Container(
                                child: Expanded(
                                  child: Text(
                                    itemList[index]['summary'],
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'poppins_regular',
                                        color: Colors.black),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )));
        });
  }

  Future<void> messageDialog(String dialog) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                dialog=="End Time"?Text(Resources.from(context, Constant.languageCode).strings.endTimeDialog):
                dialog=="Start Time"?Text(Resources.from(context, Constant.languageCode).strings.startTimeDialog):null,
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(Resources.from(context, Constant.languageCode).strings.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(Resources.from(context, Constant.languageCode).strings.okay),
              onPressed: () {
                Navigator.of(context).pop();
                switch(dialog){
                  case "End Time":
                    return _endSelectTime(context);
                  case "Start Time":
                    return _selectTime(context);
                }
              },
            ),
          ],
        );
      },
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
    Constant.showToast(message, Toast.LENGTH_LONG);
  }

  @override
  onSuccessRes(response) {}

  @override
  onEventSuccess(response, calendarResponse) {}

  @override
  onCreateEvent(response) {
    Navigator.pop(context);
    Constant.showToast(Resources.from(context, Constant.languageCode).strings.eventCreateMsg,Toast.LENGTH_SHORT);
    widget.isCreatedOrUpdate.onCreateUpdate(true);
  }

  @override
  onUpdateEvent(response) {
    print('onUpdate:::$response');
    Navigator.pop(context);
    Constant.showToast(Resources.from(context, Constant.languageCode).strings.eventUpdateMsg,Toast.LENGTH_SHORT);
    widget.isCreatedOrUpdate.onCreateUpdate(true);
  }

  @override
  onDelete(delete) {
    // eventItem.removeWhere((element) => element.id == delete);
    Constant.showToast(Resources.from(context, Constant.languageCode).strings.eventDeleteMsg,Toast.LENGTH_SHORT);
    Navigator.pop(context);

    // pass interface to geo fence for delete event id
    widget.deleteEvent.delete_event();
  }


  @override
  void isAccept(String str, String id, String email) {
    print('called::::$str    event_id::::$id    email::::$email');

    if(str=="Delete"){
      _presenter = new HomePresenter(this, token: token);
      _presenter.attachView(this);
      _presenter.deleteEvent(id, 'chirag.1sensussoft@gmail.com');

    }else {
      createAppointment();
    }
  }

  // Future<bool> showConfirmationDialog(BuildContext context, String str, String id) {
  //   return showDialog<bool>(
  //     context: context,
  //     barrierDismissible: true,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text(Resources.from(context, Constant.languageCode).strings.conformDelete, style: TextStyle(fontSize: 14, fontFamily: "poppins_regular"),),
  //         actions: <Widget>[
  //           FlatButton(
  //             child: Text(Resources.from(context, Constant.languageCode).strings.no),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           FlatButton(
  //             child: Text(Resources.from(context, Constant.languageCode).strings.yes),
  //             onPressed: () {
  //               _presenter.deleteEvent(id, Constant.email);
  //               Navigator.pop(context, true);
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

}


abstract class DeleteEvent{
  void delete_event();
}

