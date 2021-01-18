import 'package:appointment/home/createAppointment/CreateAppointment.dart';
import 'package:appointment/utils/DBProvider.dart';
import 'package:appointment/utils/values/Dimen.dart';
import 'package:appointment/utils/values/Palette.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final String name;

  Home({this.name});

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
  DateTime _currentTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: AppBar(
          backgroundColor: Palette.colorPrimary,
        ),
      ),
      body: Container(
        color: Colors.grey[200],
        child: ListView.builder(
          itemCount: 10,
          itemBuilder: (_,index){
            return Container(
              padding: EdgeInsets.only(left: Dimen().dp_20,right: Dimen().dp_20),
              height: 40,
              child: Card(
                color: Colors.white,
                child: Text("Item $index",textAlign: TextAlign.center,),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Palette.colorPrimary,
        onPressed: (){
          Navigator.push(context, CupertinoPageRoute(
              builder: (_) => CreateAppointment(),
          )
          );
        },
      ),
    );
  }

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
      });
    print(_dateTime);
  }

}