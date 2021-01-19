import 'package:appointment/utils/RoundShapeButton.dart';
import 'package:appointment/utils/values/Dimen.dart';
import 'package:appointment/utils/values/Palette.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyBottomSheet extends StatefulWidget {
  final String name;

  MyBottomSheet({this.name});

  @override
  _MyBottomSheetState createState() => _MyBottomSheetState();
}

class _MyBottomSheetState extends State<MyBottomSheet> {
  DateTime _dateTime = DateTime.now();
  DateTime _currentTime = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        initialChildSize: 0.90,
        expand: true,
        builder: (context, scrollController) {
          return  Container(
                padding: EdgeInsets.only(left: Dimen().dp_20,right: Dimen().dp_20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20.0),
                        topRight: const Radius.circular(20.0))),
                child: Column(
                  children: [
                    Container(
                      child: Icon(Icons.remove,size: 40,color: Palette.colorPrimary,),
                    ),
                    Container(
                        child: TextFormField(
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
                              hintText: 'Add title',
                              hintStyle: TextStyle(fontSize: 15,fontFamily: 'poppins_medium')
                          ),
                          style: TextStyle(fontSize: 15,fontFamily: 'poppins_medium'),
                          cursorColor: Colors.black,
                        )
                    ),
                    Container(
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
                                  Text('Events',style: TextStyle(fontSize: 15,fontFamily: 'poppins_medium'),textAlign: TextAlign.end,),
                                  Text('chirag.1sensussoft@gmail.com',style: TextStyle(fontSize: 12,fontFamily: 'poppins_regular'),textAlign: TextAlign.end,)
                                ],
                              ),
                              Icon(Icons.keyboard_arrow_down,size: 25,)

                            ],
                          ),
                        )
                    ),
                    Container(
                        margin: EdgeInsets.only(top: Dimen().dp_10),
                        child: TextFormField(
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
                              hintText: 'Add Description',
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
                      child: Text('From',style: TextStyle(fontSize: 15,fontFamily: 'poppins_medium'),),
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: FlatButton(
                              onPressed: (){
                                _selectDate(context);
                              },
                              minWidth: MediaQuery.of(context).size.width * 0.50,
                              color: Colors.grey[200],
                              child: Text(date??"Tue, 19 Jan, 2021",style: TextStyle(fontSize: 15,fontFamily: 'poppins_medium'),),
                            ),
                          ),
                          Container(
                            child: FlatButton(
                              onPressed: (){},
                              minWidth: MediaQuery.of(context).size.width * 0.30,
                              color: Colors.grey[200],
                              child: Text('18:00',style: TextStyle(fontSize: 15,fontFamily: 'poppins_medium'),),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: Dimen().dp_10),
                      alignment: Alignment.centerLeft,
                      child: Text('To',style: TextStyle(fontSize: 15,fontFamily: 'poppins_medium'),),
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: FlatButton(
                              onPressed: (){},
                              minWidth: MediaQuery.of(context).size.width * 0.50,
                              color: Colors.grey[200],
                              child: Text('Tue, 19 Jan, 2021',style: TextStyle(fontSize: 15,fontFamily: 'poppins_medium'),),
                            ),
                          ),
                          Container(
                            child: FlatButton(
                              onPressed: (){},
                              minWidth: MediaQuery.of(context).size.width * 0.30,
                              color: Colors.grey[200],
                              child: Text('19:00',style: TextStyle(fontSize: 15,fontFamily: 'poppins_medium'),),
                            ),
                          ),

                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: Dimen().dp_10,left: 80,right: 80),
                        child:RoundShapeButton(
                          onPressed: (){},
                          text: 'Save',
                          radius: 15,
                          fontSize: 15,
                          width: 0,
                          color: Colors.white,
                          icon: Image.asset(''),
                          fontFamily: 'poppins_medium',
                        )
                    ),
                  ],
                )
          );
        }
    );
  }
  String date;
  _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _currentTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(_currentTime.year + 25),
    );
    if (picked != null && picked != _dateTime)
      setState(() {
        _dateTime = picked;
        date = _dateTime.year.toString() + "-" + _dateTime.day.toString() + "-" +_dateTime.month.toString() ;
      });
    print(_dateTime);
    return picked;
  }
  double _height;
  double _width;

  String _setTime, _setDate;

  String _hour, _minute, _time;

  String dateTime;

  DateTime selectedDate = DateTime.now();

  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00,);
  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null)
      setState(() {
        selectedTime = picked;
        _hour = selectedTime.hour.toString();
        _minute = selectedTime.minute.toString();
        _time = _hour + ':' + _minute ;
      });
  }
}
