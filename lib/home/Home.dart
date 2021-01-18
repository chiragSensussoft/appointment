import 'package:appointment/login/DBProvider.dart';
import 'package:appointment/utils/Palette.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final dbHelper = DatabaseHelper.instance;
  var data;

  @override
  void initState() {
    super.initState();
    _query();
  }
  void _query() async {
    final allRows = await dbHelper.queryAllRows();
    allRows.forEach((row) {
      print(row);
    });
  }

  DateTime _dateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: AppBar(
          backgroundColor: Palette.colorPrimary,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Text(data.length != 0?data[0]['fName']:"ABCD"),
              FlatButton(
                onPressed: (){
                  _selectDate(context);
                  print(_dateTime);
                },
                child: Text('Select Date'),
              )
            ],
          ),
        ),
      ),
    );
  }
  _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _dateTime)
      setState(() {
        _dateTime = picked;
      });
  }

  datePicker(){
    return showDialog(
      context: context,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
              ),
              child: Text('foobar'),
            )
          ],
        ),
      ),
      builder: (_){
        return _selectDate(context);
      }
    );
  }

}