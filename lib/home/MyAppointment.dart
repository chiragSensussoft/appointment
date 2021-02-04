import 'package:appointment/home/home_view_model.dart';
import 'package:appointment/home/model/CalendarEvent.dart';
import 'package:appointment/home/model/CalendarList.dart';
import 'package:appointment/home/presenter/HomePresentor.dart';
import 'package:appointment/utils/Toast.dart';
import 'package:appointment/utils/values/Constant.dart';
import 'package:appointment/utils/values/Palette.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'BottomSheet.dart';
import 'OnHomeView.dart';


class MyAppointment extends StatefulWidget {

  @override
  MyAppointmentState createState() => MyAppointmentState();
}

class MyAppointmentState extends State<MyAppointment> implements OnHomeView {
  bool isVisible;
  List<Item> _list = List.empty(growable: true);
  List<Item> itemList = List.empty(growable: true);
  List<EventItem> eventItem = List.empty(growable: true);
  HomeViewModel model;
  HomePresenter _presenter;
  SharedPreferences _sharedPreferences;

  GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: ['email',
      'https://www.googleapis.com/auth/contacts.readonly',
      "https://www.googleapis.com/auth/userinfo.profile",
      "https://www.googleapis.com/auth/calendar.events",
      "https://www.googleapis.com/auth/calendar"],
    clientId: "148622577769-nq42nevup780o2699h0ohtj1stsapmjj.apps.googleusercontent.com",
  );

  String access_token = '';
  FirebaseUser user;


  @override
  void initState() {
    super.initState();
    init();
    refreshToken();
  }

  init() async{
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    model = HomeViewModel(this);

    return Scaffold(
      body: Container(
        child: RefreshIndicator(
            child: Container(
          color: Colors.grey[200],
          child: isVisible == false ?eventItem.length != 0?

          ListView.builder(
            itemCount: eventItem.length,
            itemBuilder: (_,index){
              return Padding(
                padding: EdgeInsets.all(5),
                child: GestureDetector(
                  onTap: (){
                    model.detailSheet(eventItem[index].start.dateTime);
                  },

                  child: Dismissible(
                    key: Key(eventItem[index].description),
                    direction: DismissDirection.endToStart,

                    confirmDismiss: (DismissDirection dismissDirection) async {
                      switch(dismissDirection) {
                        case DismissDirection.startToEnd:
                          return await _showConfirmationDialog(context, 'Archive',index) == true;

                        case DismissDirection.endToStart:
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
                          // height: 120,
                          padding: EdgeInsets.only(top: 8,bottom: 8,left: 18,right: 18),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children:[
                                          Expanded(
                                            child: Column(
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
                                                  child: Text(eventItem[index].description!=null?eventItem[index].description:"",style: TextStyle(fontSize: 14,fontFamily: "poppins_regular")),
                                                ),
                                              ],
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                            ),
                                            flex: 8,
                                          ),

                                          Expanded(
                                            flex: 6,
                                            child: Column(
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
                                            ),
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
          ):
          Center(child: Text("No Event Created")):
          Center(
            child: CircularProgressIndicator()
          ),
          ),
            onRefresh:(){
          print('onrefresh::::${access_token}');
          return _presenter.getCalendarEvent(access_token);
        }
        ),
      ),

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
                          return MyBottomSheet(token: access_token, list: _list, itemList: itemList);
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
                Navigator.pop(context, false);
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
