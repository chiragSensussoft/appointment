import 'package:appointment/home/home_view_model.dart';
import 'package:appointment/home/model/CalendarEvent.dart';
import 'package:appointment/home/presenter/HomePresentor.dart';
import 'package:appointment/utils/DBProvider.dart';
import 'package:appointment/utils/Toast.dart';
import 'package:appointment/utils/values/Palette.dart';
import 'package:appointment/home/BottomSheet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:appointment/utils/values/Constant.dart';
import 'OnHomeView.dart';
import 'model/CalendarList.dart';
import 'package:intl/intl.dart';


class LifecycleEventHandler extends WidgetsBindingObserver {
  final AsyncCallback resumeCallBack;
  final AsyncCallback suspendingCallBack;

  LifecycleEventHandler({
    this.resumeCallBack,
    this.suspendingCallBack,
  });

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        if (resumeCallBack != null) {
          await resumeCallBack();
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        if (suspendingCallBack != null) {
          await suspendingCallBack();
        }
        break;
    }
  }
}


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

class HomeState extends State<Home> with WidgetsBindingObserver implements OnHomeView {
  HomeViewModel model;
  final dbHelper = DatabaseHelper.instance;
  var data;
  String url;
  String userName;
  String email;
  bool visibility = true;

  List<Item> _list = List.empty(growable: true);
  List<Item> itemList = List.empty(growable: true);
  List<EventItem> eventItem = List.empty(growable: true);
  // List<CalendarEvent> calendarEventList = List.empty(growable: true);

  HomePresenter _presenter;
  bool isVisible;
  SharedPreferences _sharedPreferences;
  String access_token = '';
  FirebaseUser user;

  GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: ['email',
    'https://www.googleapis.com/auth/contacts.readonly',
    "https://www.googleapis.com/auth/userinfo.profile",
    "https://www.googleapis.com/auth/calendar.events",
    "https://www.googleapis.com/auth/calendar"],
    clientId: "148622577769-nq42nevup780o2699h0ohtj1stsapmjj.apps.googleusercontent.com",
  );


  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();

    init();
    refreshToken();
    _query();

    WidgetsBinding.instance.addObserver(
        LifecycleEventHandler(resumeCallBack: () async => setState(() {
          print('onresume::::;');
          print('getEmail::::;${Constant.email}');
          _presenter.getCalendarEvent(access_token);
        }))
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }


  init() async{
    _sharedPreferences = await SharedPreferences.getInstance();
  }


  _query() async {
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

    url = result[0]['photoUrl'];
    userName = result[0]['fName'];
    email = result[0]['email'];
  }

  @override
  Widget build(BuildContext context) {
    model = HomeViewModel(this);
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Palette.colorPrimary,
            automaticallyImplyLeading: false,
            title: new Row
              (
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:
              [
                Row(
                  children: [
                    url != null ?CircleAvatar(
                      backgroundImage: NetworkImage(url,),
                    ):Image.asset('images/ic_defult.png',fit: BoxFit.contain,height: 32,),

                    Container(
                      margin: EdgeInsets.only(left: 10,right: 10),
                      child:Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              child: Text(userName??"Default User",style: TextStyle(fontSize: 17),)
                          ),
                          Container(
                              child: Text(email??"",style: TextStyle(fontSize: 12),)
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Container(
                  child: Icon(Icons.settings,size: 30,),
                )
              ],
            )
        ),
        body: RefreshIndicator(child: Container(
          color: Colors.grey[200],
          child: isVisible == false ?eventItem.length != 0?
          ListView.builder(
            itemCount: eventItem.length,
            itemBuilder: (_,index){
              return Padding(
                padding: EdgeInsets.all(5),
                child: GestureDetector(
                  onTap: (){
                    model.detailSheet(index);
                  },
                  child: Dismissible(
                    key: Key(eventItem[index].description),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction){
                    },
                    confirmDismiss: (DismissDirection dismissDirection) async {
                      switch(dismissDirection) {
                        case DismissDirection.startToEnd:
                        // whatHappened = 'ARCHIVED';
                          return await _showConfirmationDialog(context, 'Archive',index) == true;
                        case DismissDirection.endToStart:
                        // whatHappened = 'DELETED';
                          return await _showConfirmationDialog(context, 'Delete',index) == true;
                        case DismissDirection.horizontal:
                        case DismissDirection.vertical:
                        case DismissDirection.up:
                        case DismissDirection.down:
                          assert(false);
                      }
                      return false;
                    },
                    child: Material(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: Container(
                          height: 120,
                          padding: EdgeInsets.only(top: 8,bottom: 8,left: 18,right: 18),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children:[
                                          Column(
                                            children: [
                                              Container(
                                                margin: EdgeInsets.only(top: 5),
                                                child: Text("Summary",style: TextStyle(fontSize: 14,fontFamily: "poppins_medium"),),
                                              ),
                                              Container(child: Text(eventItem[index].summary.toString(),style: TextStyle(fontSize: 14,fontFamily: "poppins_regular")),),
                                              Container(
                                                margin: EdgeInsets.only(top: 5),
                                                child: Text('Description',style: TextStyle(fontSize: 14,fontFamily: "poppins_medium")),
                                              ),
                                              Container(
                                                child: Text(eventItem[index].description,style: TextStyle(fontSize: 14,fontFamily: "poppins_regular")),
                                              ),
                                            ],
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                          ),

                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                margin: EdgeInsets.only(top: 5),
                                                child:Text('From',style: TextStyle(fontSize: 14,fontFamily: "poppins_medium"),),
                                              ),
                                              Container(
                                                child: Text(DateFormat('EE, d MMM, yyyy').format(eventItem[index].start.dateTime.toLocal())
                                                    +"  "+eventItem[index].start.dateTime.toLocal().hour.toString()+":"+eventItem[index].start.dateTime.toLocal().minute.toString()
                                                    ,style: TextStyle(fontSize: 14,fontFamily: "poppins_regular")),),
                                              Container(
                                                margin: EdgeInsets.only(top: 5),
                                                child:Text('To',style: TextStyle(fontSize: 14,fontFamily: "poppins_medium"),),
                                              ),
                                              Container(
                                                child: Text(DateFormat('EE, d MMM, yyyy').format(eventItem[index].end.dateTime.toLocal())
                                                    +"  "+eventItem[index].end.dateTime.toLocal().hour.toString()+":"+eventItem[index].end.dateTime.toLocal().minute.toString()
                                                    ,style: TextStyle(fontSize: 14,fontFamily: "poppins_regular")),),
                                            ],
                                          )
                                        ]
                                    ),

                                  ],
                                ),
                              ),
                            ],
                          )
                      ),

                    ),
                  ),
                ),
              );
            },
          ):Center(child: Text("No Event Created"),):
          Center(
            child: CircularProgressIndicator(),),
          ), onRefresh:(){
          print('onrefresh::::$access_token');
          return _presenter.getCalendarEvent(access_token);
        } ),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            backgroundColor: Palette.colorPrimary,
            onPressed: (){
              showModalBottomSheet(
                  backgroundColor: Colors.transparent,
                  context: context,
                  isScrollControlled: true,
                  isDismissible: true,
                  enableDrag: true,
                  builder: (context) {
                    return DraggableScrollableSheet(
                        initialChildSize: 0.80,
                        expand: true,
                        builder: (context, scrollController) {
                          // return MyBottomSheet(token: _sharedPreferences.getString(Constant.ACCESS_TOKEN),list: _list,itemList: itemList);
                          return MyBottomSheet(token: access_token,list: _list,itemList: itemList);
                        }
                    );
                  }
              ).whenComplete(() => {
              _presenter.getCalendarEvent(access_token)
              });
            }
        )
    );
  }
  Future<bool> _showConfirmationDialog(BuildContext context, String action,int index) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Do you want to $action this item?'),
          actions: <Widget>[
            FlatButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.pop(context, false); // showDialog() returns true
              },
            ),
            FlatButton(
              child: const Text('Yes'),
              onPressed: () {
                _presenter.deleteEvent(eventItem[index].id, eventItem[index].creator.email);
                Navigator.pop(context, true);
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
      isVisible = true;
    });
  }

  @override
  onHideLoader() {
    setState(() {
      isVisible = false;
    });
  }

  @override
  onErrorHandler(String message){
    Toast toast = Toast();
    toast.overLay = false;
    toast.showOverLay(message, Colors.white, Colors.black54, context);
    setState(() {
      isVisible = false;
    });
  }

  @override
  onSuccessRes(response) {
    setState(() {
      List<dynamic> data = response;
      _list.addAll(data.map((i) => Item.fromJson(i)).toList());

      for(int i=0;i<data.length;i++){
        if(data[i]['accessRole']=="owner"){
          itemList.add(Item.fromJson(data[i]));
        }
      }
    });
  }

  Map<String, dynamic> map;

  @override
  onEventSuccess(response,calendarResponse) {
    print("success ${response.runtimeType}");

    setState(() {
      eventItem.clear();
      map = calendarResponse;
      List<dynamic> data = response;
      eventItem.addAll(data.map((e)=> EventItem.fromJson(e)).toList());
    });
  }


  Future<String> refreshToken() async {
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signInSilently();
    final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

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

    _presenter = new HomePresenter(this, token: googleSignInAuthentication.accessToken);
    _presenter.attachView(this);
    _presenter.getCalendar(googleSignInAuthentication.accessToken);
    _presenter.getCalendarEvent(googleSignInAuthentication.accessToken);

    return googleSignInAuthentication.accessToken; //new token
  }

}
