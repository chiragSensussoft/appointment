import 'package:appointment/home/MyAppointment.dart';
import 'package:appointment/home/home_view_model.dart';
import 'package:appointment/utils/DBProvider.dart';
import 'package:appointment/utils/drop_down.dart';
import 'package:appointment/utils/values/Constant.dart';
import 'package:appointment/utils/values/Dimen.dart';
import 'package:appointment/utils/values/Strings/Strings.dart';
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
  String text = "English";
  int selectedIndex;

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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    Expanded(
                      child: Row(
                        children: [
                          url != null ?CircleAvatar(
                            backgroundImage: NetworkImage(url),
                          ):Image.asset('images/ic_defult.png',fit: BoxFit.contain,height: 30),

                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(left: 10,right: 10),
                              child:Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      child: Text(userName!=''?userName : Resources(context, Constant.languageCode).strings.defaultUser, style: TextStyle(fontSize: 17))
                                  ),
                                  Container(
                                      child: Text(email!=''?email:" ", style: TextStyle(fontSize: 12))
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),

                    // GestureDetector(
                    //   child: Container(
                    //     padding: EdgeInsets.zero,
                    //     child: DropdownButton(
                    //         underline: Container(height: 0),
                    //         icon: Icon(Icons.language),
                    //         value: _value,
                    //         items: [
                    //           DropdownMenuItem(
                    //             child: Text('English',style: TextStyle(fontSize: 12),),
                    //             onTap: (){
                    //               setState(() {
                    //                 Constant.languageCode = 'en';
                    //                 languageCode(code: Constant.languageCode);
                    //               });
                    //             },
                    //             value: 1,
                    //           ),
                    //           DropdownMenuItem(
                    //             child: Text("Hindi",style: TextStyle(fontSize: 12)),
                    //             onTap: (){
                    //               setState(() {
                    //                 Constant.languageCode = 'hi';
                    //                 languageCode(code: Constant.languageCode);
                    //               });
                    //             },
                    //             value: 2,
                    //           ),
                    //           DropdownMenuItem(
                    //               child: Text("Gujarati",style: TextStyle(fontSize: 12)),
                    //               onTap: (){
                    //                 setState(() {
                    //                   Constant.languageCode = 'gu';
                    //                   languageCode(code: Constant.languageCode);
                    //                 });
                    //               },
                    //               value: 3
                    //           ),
                    //         ],
                    //         onChanged: (value) {
                    //           setState(() {
                    //             _value = value;
                    //           });
                    //         }),
                    //   ),
                    //
                    // ),

                    
                    // GestureDetector(
                    //   onTap: (){
                    //
                    //
                    //   },
                    //   child: Row(
                    //     children: [
                    //       Text('English', style: TextStyle(fontSize: 10, color:Colors.white)),
                    //       SizedBox(width: 5),
                    //       Icon(Icons.language),
                    //     ],
                    //   ),
                    // ),

                    // Expanded(
                    //   flex: 1,
                    //   child: IconButton(
                    //     padding: EdgeInsets.zero,
                    //     onPressed: (){},
                    //     icon: Icon(Icons.settings, color: Colors.white),
                    //   ),
                    // )

                    Container(
                      // margin: EdgeInsets.only(right: Dimen().dp_20,top: 35),
                      alignment: Alignment.topRight,
                      child: SimpleAccountMenu(
                        text: text,
                        selectedIndex: selectedIndex,
                        borderRadius: BorderRadius.circular(10),
                        backgroundColor: Colors.white,
                        icons: [
                          Container(
                            // height:40,
                              child: Text("English",style: TextStyle(color: Colors.black,fontSize: 14),textAlign: TextAlign.center)),
                          Container(
                              child: Text("हिन्दी",style: TextStyle(color: Colors.black,fontSize: 14),textAlign: TextAlign.center)),
                          Container(
                              child: Text("ગુજરાતી",style: TextStyle(color: Colors.black,fontSize: 14),textAlign: TextAlign.center,)),
                        ],
                        onChange: (index) {
                          print(index);
                          if(index == 0){
                            setState(() {
                              text ="English";
                              selectedIndex = index;
                              Constant.languageCode = 'en';
                              languageCode(code: Constant.languageCode);
                            });
                          }
                          if(index == 1){
                            setState(() {
                              text ="हिन्दी";
                              selectedIndex = index;
                              Constant.languageCode = 'hi';
                              languageCode(code: Constant.languageCode);
                            });
                          }
                          if(index == 2){
                            setState(() {
                              text ="ગુજરાતી";
                              selectedIndex = index;
                              Constant.languageCode = 'gu';
                              languageCode(code: Constant.languageCode);
                            });
                          }
                        },
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
          return text = "ગુજરાતી";
        case 'hi':
          return text = "हिन्दी";
        default:
          return text = "English";
      }
    });
  }

}
