import 'package:appointment/home/MyAppointment.dart';
import 'package:appointment/home/home_view_model.dart';
import 'package:appointment/utils/DBProvider.dart';
import 'package:appointment/utils/values/Palette.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  // google-site-verification=MOk_ae6Hu96QUj8TYw_iQhU_8ww7WGudmAbTLfO8lWk

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Palette.colorPrimary,
          automaticallyImplyLeading: false,
          title: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
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
              Container(
                child: Icon(Icons.settings, size: 30),
              )
            ],
          )
      ),

      // body: DefaultTabController(
      //   length: 2,
      //   child: Container(
      //     child: Column(
      //       children: [
      //         Container(
      //           color: Colors.grey.withOpacity(0.1),
      //           child: TabBar(
      //             indicator: UnderlineTabIndicator(
      //               borderSide: BorderSide(color: Palette.colorPrimary, width: 2.0),
      //               insets: EdgeInsets.fromLTRB(45.0, 0.0, 45.0, 0.0),
      //             ),
      //
      //             tabs: [
      //               Padding(
      //                   padding: EdgeInsets.all(12),
      //                   child: Text("My Appointment", style: TextStyle(fontSize: 12, fontFamily: 'poppins_medium', color: Palette.colorPrimary))
      //               ),
      //
      //               Padding(
      //                   padding: EdgeInsets.all(12),
      //                   child: Text("Other Appointment", style: TextStyle(fontSize: 12, fontFamily: 'poppins_medium', color: Palette.colorPrimary))
      //               ),
      //             ],
      //           ),
      //         ),
      //
      //         Expanded(
      //             child: Container(
      //               decoration: BoxDecoration(
      //                   borderRadius: BorderRadius.only(
      //                       topLeft: Radius.circular(30), topRight: Radius.circular(30)
      //                   ), color: Colors.white
      //               ),
      //
      //               child: TabBarView(
      //                 children: [
      //                   MyAppointment(),
      //                   OtherAppointment(),
      //                 ],
      //               ),
      //             )
      //         )
      //       ],
      //     ),
      //   ),
      // ),

      body: MyAppointment(),
    );
  }
}
