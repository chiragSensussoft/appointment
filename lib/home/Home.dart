import 'dart:convert';

import 'package:appointment/google_map/GeoFenceMap.dart';
import 'package:appointment/home/MyAppointment.dart';
import 'package:appointment/home/OnHomeView.dart';
import 'package:appointment/home/home_view_model.dart';
import 'package:appointment/home/presenter/HomePresentor.dart';
import 'package:appointment/utils/DBProvider.dart';
import 'package:appointment/utils/bottom_navigation/fab_bottom_app_bar.dart';
import 'package:appointment/utils/values/Constant.dart';
import 'package:appointment/utils/values/Strings/Strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'model/CalendarList.dart';


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

class Home extends StatefulWidget  {

  @override
  HomeState createState() => HomeState();
}


class HomeState extends State<Home> implements OnHomeView{
  final dbHelper = DatabaseHelper.instance;
  var data;
  String url;
  String userName = '';
  String email = '';
  bool visibility = true;
  ScrollController controller;
  HomeViewModel model;
  String access_token = '';
  FirebaseUser user;
  HomePresenter presenter;
  List<Item> itemList = List.empty(growable: true);

  GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
      "https://www.googleapis.com/auth/userinfo.profile",
      "https://www.googleapis.com/auth/calendar.events",
      "https://www.googleapis.com/auth/calendar"
    ],
    clientId: "148622577769-nq42nevup780o2699h0ohtj1stsapmjj.apps.googleusercontent.com",
  );

  Future<String> refreshToken() async {
    final GoogleSignInAccount googleSignInAccount =
    await googleSignIn.signInSilently();
    final GoogleSignInAuthentication googleSignInAuthentication =
    await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final FirebaseAuth _auth = FirebaseAuth.instance;
    await _auth.signInWithCredential(credential);
    print("Access token 1 ==> ${googleSignInAuthentication.accessToken}");

    _sharedPreferences.setString(Constant.ACCESS_TOKEN, googleSignInAuthentication.accessToken);
    access_token = googleSignInAuthentication.accessToken;
    print("Id token 1 ==> $access_token");

    AuthResult authResult = await _auth.signInWithCredential(credential);
    user = authResult.user;
    Constant.email = user.email;
    Constant.token = googleSignInAuthentication.accessToken;
    presenter = new HomePresenter(this, token: googleSignInAuthentication.accessToken);
    presenter.attachView(this);
    presenter.getCalendar(googleSignInAuthentication.accessToken);

    return googleSignInAuthentication.accessToken;
  }


  void initState() {
    _query();
    refreshToken();
    controller = ScrollController();
    super.initState();
    setValue();
  }

  _query() async {
    // final query = "28, S Zone Road, Chandanvan Society, Surat 395007, Gujarat Chandanvan Society Surat India";
    // var addresses = await Geocoder.local.findAddressesFromQuery(query);
    // var first = addresses.first;
    // print("HELLO POOJA::::::${first.featureName} : ${first.coordinates}");

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
  int selectedIndex = 1;


  void _selectedTab(int index) {
    setState(() {
      selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    model = HomeViewModel(homestate: this);

    return Container(
      color: Colors.blue,
      child: SafeArea(
        top: true,
        child: Scaffold(
          extendBody: true,
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
                                margin: EdgeInsets.only(right: 5),
                                child: Text(text,textAlign: TextAlign.center,style: TextStyle(fontSize: 16,color: Colors.white),),
                              ),
                              Container(
                                child: Icon(Icons.language,color: Colors.white.withOpacity(0.9),),
                              ),
                            ],
                          ),
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
            onTabSelected: (index){
              _selectedTab(index);
              setState(() {
                selectedIndex = index;
              });
            },
            items: [
              FABBottomAppBarItem(iconData: Icon(Icons.calendar_today,size:25,color: selectedIndex == 0 ? Colors.blue : Colors.black.withOpacity(0.7),), text: 'Home'),
              FABBottomAppBarItem(iconData: SvgPicture.asset("images/mapAppoint.svg",height: 22,width: 22,color: selectedIndex == 1 ? Colors.blue : Colors.black.withOpacity(0.7),), text: 'Home'),
              FABBottomAppBarItem(iconData: Icon(Icons.more_vert,size: 25,color: selectedIndex == 2 ? Colors.blue : Colors.black.withOpacity(0.7)), text: 'More'),
            ],
          ),

          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: (){
              print('CALLED:::');
              model.openBottomSheetView(isEdit: false, openfrom: "Home");
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
          child: GeoFenceMap(),
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
              child: Text("हिन्दी",style: TextStyle(fontSize: 12,color: text =="हिन्दी"?Colors.blue:Colors.black))
          ),
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


  @override
  onCreateEvent(response) {

  }

  @override
  onDelete(delete) {

  }

  @override
  onErrorHandler(String error) {

  }

  @override
  onEventSuccess(response, calendarResponse) {

  }

  @override
  onHideLoader() {

  }

  @override
  onShowLoader() {

  }

  @override
  onSuccessRes(response) {
    itemList.clear();
    setState(() {
      List<dynamic> data = response;
      for (int i = 0; i < data.length; i++) {
        if (data[i]['accessRole'] == "owner") {
          itemList.add(Item.fromJson(data[i]));
          _sharedPreferences.setString(Constant.ITEM_LIST, json.encode(itemList));
        }
      }
    });
  }

  @override
  onUpdateEvent(response) {

  }
}
