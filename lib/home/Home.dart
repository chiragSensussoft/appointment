import 'package:appointment/home/MyAppointment.dart';
import 'package:appointment/home/home_view_model.dart';
import 'package:appointment/utils/DBProvider.dart';
import 'package:appointment/utils/bottom_navigation/fab_bottom_app_bar.dart';
import 'package:appointment/utils/values/Constant.dart';
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
  final dbHelper = DatabaseHelper.instance;
  var data;
  String url;
  String userName = '';
  String email = '';
  bool visibility = true;
  ScrollController controller;

  void initState() {
    _query();
    controller = ScrollController();
    super.initState();
    setValue();
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
  int selectedIndex = 0;


  void _selectedTab(int index) {
    setState(() {
      selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    // model = HomeViewModel(state1: this);

    return Container(
      color: Colors.blue,
      child: SafeArea(
        top: true,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: Container(
              color: Colors.blue,
              padding: EdgeInsets.only(left: 10,right: 10),
              child: GestureDetector(
                child: Row(
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                          child: Text(userName!=''?userName : Resources(context, Constant.languageCode).strings.defaultUser, style: TextStyle(fontSize: 17,color: Colors.white))
                                      ),
                                      Container(
                                          child: Text(email!=''?email:" ", style: TextStyle(fontSize: 12,color: Colors.white))
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),

                    GestureDetector(
                          child: Container(
                            // width: 80,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  // alignment: Alignment.center,
                                  margin: EdgeInsets.only(right: 5),
                                  child: Text(text,textAlign: TextAlign.center,style: TextStyle(fontSize: 16,color: Colors.white),),
                                ),
                                Container(
                                  child: Icon(Icons.language,color: Colors.white.withOpacity(0.9),),
                                ),
                              ],
                            ),
                            // color: Colors.white,
                          ),
                          onTap: () {
                            _showPopupMenu(context);
                          },
                        )
                  ],
                ),
              ),
            )
          ),

          body: _widgetOptions(selectedIndex),

          bottomNavigationBar: FABBottomAppBar(
            color: Colors.grey,
            selectedColor: Colors.blue,
            notchedShape: CircularNotchedRectangle(),
            onTabSelected: _selectedTab,
            items: [
              FABBottomAppBarItem(iconData: Icons.home_outlined, text: 'Home'),
              FABBottomAppBarItem(iconData: Icons.map, text: 'Map'),
              FABBottomAppBarItem(iconData: Icons.more_vert, text: 'More'),
            ],
          ),

          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: (){
              // model.openBottomSheetView(isEdit: false);
            },
          ),
        ),
      ),
    );
  }

  _widgetOptions(int index){
    switch(index){
      case 0:
        return Container(
          child: MyAppointment(controller),
        );
        break;

      case 1:
        return Container(
          child: Text("HEllo"),
        );
        break;

      case 2:
        break;
    }
  }

  _showPopupMenu(BuildContext context) async {
    await showMenu(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10)
      ),
      position: RelativeRect.fromLTRB(MediaQuery.of(context).size.width, 45, 0, 00),
      items: [
        PopupMenuItem(
          value: 0,
          child: Container(
            alignment: Alignment.center,
              child: Text('English',style: TextStyle(fontSize: 12,color: text =="English"?Colors.blue:Colors.black),),
          ),
          // enabled: enable1,
        ),
        PopupMenuItem(
          value: 1,
          child: Container(
              alignment: Alignment.center,
              child: Text("हिन्दी",style: TextStyle(fontSize: 12,color: text =="हिन्दी"?Colors.blue:Colors.black))),
          // enabled: enable2,
        ),
        PopupMenuItem(
          value: 2,
          child: Container(
              alignment: Alignment.center,
              child: Text("ગુજરાતી",style: TextStyle(fontSize: 12,color: text =="ગુજરાતી"?Colors.blue:Colors.black))),
          // enabled: enable3,
        ),
      ],
      elevation: 8.0,
    ).then((value){
      if(value!=null)
        if(value == 0){
          setState(() {
            text = "English";
            Constant.languageCode = 'en';
            languageCode(code: Constant.languageCode);
          });
        }
      if(value == 1){
        setState(() {
          text = "हिन्दी";
          Constant.languageCode = 'hi';
          languageCode(code: Constant.languageCode);
        });
      }
      if(value == 2){
        setState(() {
          text = "ગુજરાતી";
          Constant.languageCode = 'gu';
          languageCode(code: Constant.languageCode);
        });
      }
    });
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
         // setState(() {
         //   text = "ગુજરાતી";
         //   selectedIndex =2;
         // });
         //  break;
          return text = "ગુજરાતી";
        case 'hi':
          // text = "हिन्दी";
          // selectedIndex = 1;
          // break;
          return text = "हिन्दी";
        default:
          // text = "English";
          // selectedIndex = 0;
          // break;
          return text = "English";
      }
    });
  }

}
