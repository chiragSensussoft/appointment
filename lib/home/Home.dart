import 'package:appointment/home/MyAppointment.dart';
import 'package:appointment/home/home_view_model.dart';
import 'package:appointment/utils/DBProvider.dart';
import 'package:appointment/utils/values/Constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';


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
  HomeState createState() => HomeState();
}


class HomeState extends State<Home>{
  HomeViewModel model;
  final dbHelper = DatabaseHelper.instance;
  var data;
  String url;
  String userName = '';
  String email = '';
  bool visibility = true;
  ScrollController controller = ScrollController();
  var _value;

  void initState() {
    _query();
    super.initState();
  }

  _query() async {
    print('isCalled:::');
    Database db = await DatabaseHelper.instance.database;
    List<String> columnsToSelect = [
      DatabaseHelper.columnfName,
      DatabaseHelper.columnEmail,
      DatabaseHelper.columnPhotoUrl,
      DatabaseHelper.columnAccessToken,
    ];
    String whereString = '${DatabaseHelper.columnId} = ?';
    int rowId = 1;
    List<dynamic> whereArguments = [rowId];
    List<Map> result = await db.query(
        DatabaseHelper.table,
        columns: columnsToSelect,
        where: whereString,
        whereArgs: whereArguments);

    setState(() {
      url = result[0]['photoUrl'];
      userName = result[0]['fName'];
      email = result[0]['email'];
    });
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      child: SafeArea(
        top: true,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue,
            automaticallyImplyLeading: false,
            title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          url != null ?CircleAvatar(
                            backgroundImage: NetworkImage(url,),
                          ):Image.asset('images/ic_defult.png',fit: BoxFit.contain,height: 32),

                          Container(
                            margin: EdgeInsets.only(left: 10,right: 10),
                            child:Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    child: Text(userName!=''?userName : "Default User", style: TextStyle(fontSize: 17))
                                ),
                                Container(
                                    child: Text(email!=''?email:" ", style: TextStyle(fontSize: 12))
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),


                    GestureDetector(
                      child: Container(
                        // child: Icon(Icons.settings, size: 30),
                        child: DropdownButton(
                            underline: Container(height: 0),
                            icon: Icon(Icons.language),
                            value: _value,
                            items: [
                              DropdownMenuItem(
                                child: Text('English',style: TextStyle(fontSize: 14),),
                                onTap: (){
                                  setState(() {
                                    Constant.languageCode = 'en';
                                    languageCode(code: Constant.languageCode);
                                  });
                                },
                                value: 1,
                              ),
                              DropdownMenuItem(
                                child: Text("Hindi",style: TextStyle(fontSize: 14)),
                                onTap: (){
                                  setState(() {
                                    Constant.languageCode = 'hi';
                                    languageCode(code: Constant.languageCode);
                                  });
                                },
                                value: 2,
                              ),
                              DropdownMenuItem(
                                  child: Text("Gujarati",style: TextStyle(fontSize: 14)),
                                  onTap: (){
                                    setState(() {
                                      Constant.languageCode = 'gu';
                                      languageCode(code: Constant.languageCode);
                                    });
                                  },
                                  value: 3
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _value = value;
                              });
                            }),
                      ),

                    )
                  ],
                )
          ),

          body: MyAppointment(controller),
        ),
      ),
    );
  }
  SharedPreferences _sharedPreferences;
  Future<void> languageCode({String code})async{
    _sharedPreferences = await SharedPreferences.getInstance();
    _sharedPreferences.setString(Constant().languageKey, code);
  }

  setValue()async{
    _sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      switch(_sharedPreferences.getString(Constant().languageKey)){
        case 'gu':
          return _value = 3;
        case 'hi':
          return _value = 2;
        default:
          return _value = 1;
      }
    });
  }
}
