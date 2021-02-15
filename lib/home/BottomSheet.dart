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
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'OnHomeView.dart';

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

  MyBottomSheet(
      {this.token,
      this.list,
      this.itemList,
      this.title,
      this.description,
      this.getStartDate,
      this.getendDate,
      this.timeZone,
      this.isEdit,
      this.eventID,
      this.isCreatedOrUpdate});

  @override
  _MyBottomSheetState createState() => _MyBottomSheetState();
}

class _MyBottomSheetState extends State<MyBottomSheet> implements OnHomeView, IsAcceptAppointment {
  DateTime _startDateTime;
  HomePresenter _presenter;
  TextEditingController title = TextEditingController();
  TextEditingController desc = TextEditingController();
  FocusNode _titleFocus = FocusNode();
  FocusNode _discFocus = FocusNode();
  bool loader = false;
  String setEmail;
  TimeOfDay selectedStartTime;
  TimeOfDay selectedEndTime;
  bool isVisible = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
    _discFocus.unfocus();
  }

  @override
  void initState() {
    super.initState();
    widget.isEdit
        ? _startDateTime = widget.getStartDate.toLocal()
        : _startDateTime = DateTime.now();

    startDate = _startDateTime.year.toString() +
        "-" +
        _startDateTime.month.toString() +
        "-" +
        _startDateTime.day.toString();

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
      _endTime = (_startDateTime.toLocal().hour + 1).toString() +
          ":" +
          _startDateTime.toLocal().minute.toString() +
          ":" +
          _startDateTime.toLocal().second.toString();
    }

    end = DateTime(_startDateTime.year, _startDateTime.month,
        _startDateTime.day, int.parse(_endHour), int.parse(_endMinute));

    /*set text for edit*/
    widget.isEdit ? title.text = widget.title : null;
    widget.isEdit ? desc.text = widget.description : null;
    widget.isEdit ? setEmail = Constant.email : null;

    selectedStartTime = TimeOfDay();
    selectedEndTime = TimeOfDay();

    widget.isEdit? isVisible = true: isVisible = false;

  }

  @override
  Widget build(BuildContext context) {
    return Form(
      autovalidateMode: AutovalidateMode.always,
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
                              contentPadding: EdgeInsets.only(top: Dimen().dp_10, bottom: Dimen().dp_10, left: 12),

                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 0, color: Colors.transparent)),

                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 0, color: Colors.transparent)),

                              errorBorder: OutlineInputBorder(borderSide: BorderSide(
                                  width: 1, color: Colors.red)),

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

                                  Visibility(
                                    visible: isVisible,
                                    child: Text(
                                      setEmail ?? "",
                                      style: TextStyle(fontSize: 12, fontFamily: 'poppins_regular'),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
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

                        // child: Column(
                        //   children: [
                        //     Row(
                        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //       children: [
                        //           Text(
                        //             Resources.from(context, Constant.languageCode).strings.event,
                        //             style: TextStyle(fontSize: 15, fontFamily: 'poppins_medium'),
                        //             textAlign: TextAlign.end),
                        //
                        //           Padding(
                        //             padding: EdgeInsets.only(top: 5, bottom: 5),
                        //             child: Icon(
                        //               Icons.keyboard_arrow_down,
                        //               size: 20,
                        //             ),
                        //           ),
                        //       ],
                        //     ),
                        //
                        //      Visibility(
                        //        visible: isVisible,
                        //        child: Text(
                        //          setEmail ?? "",
                        //          style: TextStyle(fontSize: 12, fontFamily: 'poppins_regular'),
                        //          overflow: TextOverflow.ellipsis,
                        //        ),
                        //      )
                        //   ],
                        // ),

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
                          maxLength: 100,
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
                        )),

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
                          style:
                          TextStyle(fontSize: 14, fontFamily: 'poppins_medium'),
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

                    ProgressButton(isAccept: this, text: widget.isEdit ? 'Update' : 'save', formKey: _formKey, isVisible: isVisible)
                  ],
                ),
              ),
            ],
          )
      ),
    );
  }

  void createAppointment() {
    _presenter = new HomePresenter(this, token: widget.token);
    _presenter.attachView(this);

    widget.isEdit
        ? _presenter.updatevent(
            endDate: startDate + "T" + _endTime,
            startDate: startDate + "T" + _startTime,
            timeZone: widget.timeZone,
            summary: title.text,
            description: desc.text,
            id: widget.eventID,
            email: setEmail)
        : _presenter.setAppointment(
            endDate: startDate + "T" + _endTime,
            startDate: startDate + "T" + _startTime,
            timeZone: _startDateTime.timeZoneName,
            summary: title.text,
            description: desc.text);
  }

  // Toast toast = Toast();

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
                    itemCount: widget.itemList.length,
                    itemBuilder: (_, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            setEmail = widget.itemList[index].summary;
                            Constant.email = widget.itemList[index].id;
                            Navigator.pop(context);
                            isVisible = true;
                            FocusScope.of(context).requestFocus(new FocusNode());
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
                                    backgroundColor:
                                        widget.itemList[index].id == setEmail ? Palette.colorPrimary : Colors.grey),
                              ),
                              Container(
                                child: Expanded(
                                  child: Text(
                                    widget.itemList[index].summary,
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
    // toast.overLay = false;
    // toast.showOverLay(message, Colors.white, Colors.black54, context);
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
  onDelete(delete) {}


  @override
  void isAccept() {
    print('called::::');
    createAppointment();
  }
}
