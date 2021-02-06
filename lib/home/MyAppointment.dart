import 'package:appointment/home/home_view_model.dart';
import 'package:appointment/home/model/CalendarEvent.dart';
import 'package:appointment/home/model/CalendarList.dart';
import 'package:appointment/home/presenter/HomePresentor.dart';
import 'package:appointment/utils/DBProvider.dart';
import 'package:appointment/utils/RoundShapeButton.dart';
import 'package:appointment/utils/Toast.dart';
import 'package:appointment/utils/values/Constant.dart';
import 'package:appointment/utils/values/Dimen.dart';
import 'package:appointment/utils/values/Palette.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:sqflite/sqflite.dart';
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
  String url;
  String userName = '';
  String email = '';
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


  @override
  void initState() {
    super.initState();
    fetchLinkData();
    init();
    refreshToken();
    _query();
  }

  init() async{
    _sharedPreferences = await SharedPreferences.getInstance();
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
    model = HomeViewModel(this);

    return Scaffold(
      key: _scaffoldKey,
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
                  onTap: () async{
                      model.detailSheet(eventItem[index].start.dateTime);

                      String startDate = eventItem[index].start.dateTime.toLocal().year.toString() +"-"+ eventItem[index].start.dateTime.toLocal().month.toString()+"-"+eventItem[index].start.dateTime.toLocal().day.toString();
                      String startTime = eventItem[index].start.dateTime.toLocal().hour.toString() +":"+ eventItem[index].start.dateTime.toLocal().minute.toString()+":"+"00";
                      print("Date ${startDate+"T"+startTime}");
                      String endDate = eventItem[index].end.dateTime.toLocal().year.toString() +"-"+ eventItem[index].end.dateTime.toLocal().month.toString()+"-"+eventItem[index].end.dateTime.toLocal().day.toString();
                      String endTime = eventItem[index].end.dateTime.toLocal().hour.toString() +":"+ eventItem[index].end.dateTime.toLocal().minute.toString()+":"+"00";


                      dynamicLink = await createDynamicLink(title: eventItem[index].summary,desc: eventItem[index].description,startDate: startDate+"T"+startTime,endDate: endDate+"T"+endTime
                      ,email: email,photoUrl: url,senderName: userName,timeZone: eventItem[index].start.timeZone);
                      print("Dynamic Link: $dynamicLink");
                  },

                  child: Dismissible(
                    key: Key(eventItem[index].description),
                    // direction: DismissDirection.endToStart,

                    confirmDismiss: (DismissDirection dismissDirection) async {
                      switch(dismissDirection) {
                        case DismissDirection.startToEnd:
                          return await _showShareDialog(context, "Share", index);

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
                                    // FlatButton(
                                    //   color:
                                    //   Colors.blue,
                                    //   height: 100,
                                    //   onPressed: () async {
                                    //     Share.share(dynamicLink.toString());
                                    //   },
                                    //   child: Text(dynamicLink.toString()??""),
                                    // ),
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
          return _presenter.getCalendarEvent();
        }
        ),
      ),

        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            backgroundColor: Palette.colorPrimary,
            onPressed: ()async{
              print(dynamicLink);

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
                _presenter.getCalendarEvent()
              });
              // showAsBottomSheet("Chirag", url, "2021-06-02", "2021-06-02", "Online Classes", "Online classes in zoom meeting");
            }
        )
    );
  }

  var dynamicLink;

  Future<Uri> createDynamicLink({@required title,@required desc,@required startDate,@required endDate,@required email,@required photoUrl,@required senderName,@required timeZone}) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://appointmrnt.page.link',
      link: Uri.parse('https://appointmrnt.page.link/appointment?summary=$title&description=$desc&startDate=$startDate&endDate=$endDate&senderEmail=$email&senderPhoto=$photoUrl&senderName=$senderName&timeZone=$timeZone'),
      androidParameters: AndroidParameters(
        packageName: 'com.ck.appointment',
        minimumVersion: 1,
      ),
      iosParameters: IosParameters(
        bundleId: 'com.ck.appointment',
        minimumVersion: '1',
        appStoreId: '',
      ),
    );
    final link = await parameters.buildUrl();
    final ShortDynamicLink shortenedLink = await DynamicLinkParameters.shortenUrl(
      link,
      DynamicLinkParametersOptions(shortDynamicLinkPathLength: ShortDynamicLinkPathLength.unguessable),
    );
    return shortenedLink.shortUrl;
  }

  Future<bool> _showConfirmationDialog(BuildContext context, String action,int index) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Do you want to $action this Event?'),
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

  Future<bool> _showShareDialog(BuildContext context, String action,int index) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Do you want to $action this Event?'),
          actions: <Widget>[
            FlatButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            FlatButton(
              child: const Text('Yes'),
              onPressed: () async{
                String startDate = eventItem[index].start.dateTime.toLocal().year.toString() +"-"+ eventItem[index].start.dateTime.toLocal().month.toString()+"-"+eventItem[index].start.dateTime.toLocal().day.toString();
                String startTime = eventItem[index].start.dateTime.toLocal().hour.toString() +":"+ eventItem[index].start.dateTime.toLocal().minute.toString()+":"+"00";
                print("Date ${startDate+"T"+startTime}");
                String endDate = eventItem[index].end.dateTime.toLocal().year.toString() +"-"+ eventItem[index].end.dateTime.toLocal().month.toString()+"-"+eventItem[index].end.dateTime.toLocal().day.toString();
                String endTime = eventItem[index].end.dateTime.toLocal().hour.toString() +":"+ eventItem[index].end.dateTime.toLocal().minute.toString()+":"+"00";

                dynamicLink = await createDynamicLink(title: eventItem[index].summary,desc: eventItem[index].description,startDate: startDate+"T"+startTime,endDate: endDate+"T"+endTime
                    ,email: email,photoUrl: url,senderName: userName,timeZone: eventItem[index].start.timeZone);
                print("Dynamic Link: $dynamicLink");
                if(dynamicLink!=""){
                  Share.share(dynamicLink.toString());
                  Navigator.pop(context, false);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void fetchLinkData() async {
    var link = await FirebaseDynamicLinks.instance.getInitialLink();

    handleLinkData(link);

    FirebaseDynamicLinks.instance.onLink(onSuccess: (PendingDynamicLinkData dynamicLink) async {
      handleLinkData(dynamicLink);
    });
  }
  Toast toast = Toast();
  void handleLinkData(PendingDynamicLinkData data) {
    final Uri uri = data?.link;
    if(uri != null) {
      final queryParams = uri.queryParameters;
      if(queryParams.length > 0) {
        String summary = queryParams["summary"];
        String description = queryParams['description'];
        String startDate = queryParams['startDate'];
        String endDate = queryParams['endDate'];
        String senderEmail = queryParams['senderEmail'];
        String senderPhoto = queryParams['senderPhoto'];
        String senderName = queryParams['senderName'];
        String timeZone = queryParams['timeZone'];
        print("My summary is: $summary");
        print("My description is: $description");
        print("My startDate is: $startDate");
        print("My endDate is: $endDate");
        print("Sender Email is: $senderEmail");
        print("Sender Photo is: $senderPhoto");
        print("sender Name is: $senderName");
        print("timeZone Name is: $timeZone");

        if(summary.isEmpty||description.isEmpty||startDate.isEmpty||endDate.isEmpty||senderName.isEmpty||senderPhoto.isEmpty||senderEmail.isEmpty){
          toast.overLay = false;
          toast.showOverLay("Data is not valid", Colors.white, Colors.black54, context,seconds: 3);
        }
        else{
          print("Enter in Else");
          refreshToken();
          Future.delayed(Duration(seconds: 2)).whenComplete(() => {
          showAsBottomSheet(senderName,senderPhoto,senderEmail,startDate,endDate,summary,description,timeZone)
          });
        }

      }
    }
  }

  void showAsBottomSheet(String senderName,senderEmail,senderPhoto,startDate,endDate,summary,description,timeZone) async {
     return await showSlidingBottomSheet(
        context,
        builder: (context) {
          return SlidingSheetDialog(
            elevation: 8,
            cornerRadius: 16,
            snapSpec: const SnapSpec(
              snap: false,
              positioning: SnapPositioning.relativeToAvailableSpace,
            ),
            duration: Duration(milliseconds: 300),
            builder: (context, state) {
              return Material(
                child: Container(
                  padding: EdgeInsets.only(left: 20,right: 20,top: 10,bottom: 10),
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        child: Text("Share Event",style: TextStyle(fontSize: 17,fontFamily: "poppins_medium"),),
                      ),
                      Row(
                        children: [
                          Container(
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(senderPhoto),
                            ),
                          ),
                          SizedBox(width: 20,),
                          Container(
                            child: Text(senderName),
                          )
                        ],
                      ),
                      SizedBox(height: 10,),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(summary),
                      ),
                      SizedBox(height: 10,),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(description),
                      ),
                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                child:Text('From',style: TextStyle(fontSize: 17,fontFamily: "poppins_medium"),),
                              ),
                              Container(
                                child:Text(startDate),
                              )
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                child:Text('To',style: TextStyle(fontSize: 17,fontFamily: "poppins_medium"),),
                                alignment: Alignment.centerLeft,
                              ),
                              Container(
                                child:Text(endDate),
                              )
                            ],
                          )
                        ],
                      ),
                      SizedBox(height: 20,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: 100,
                            height: 45,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.red
                            ),
                            child: IconButton(
                              onPressed: (){
                                Navigator.pop(context);
                              },
                              color: Colors.white,
                              icon: Icon(Icons.close_rounded),
                            ),
                          ),
                          Container(
                            width: 100,
                            height: 45,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.green
                            ),
                            child: IconButton(
                              onPressed: (){
                                    // _presenter.attachView(this);
                                    _presenter.setAppointment(summary: summary,endDate: endDate,startDate: startDate,description: description,timeZone: timeZone);
                                    _presenter.getCalendarEvent();
                                    Navigator.pop(context);
                              },
                              color: Colors.white,
                              icon: Icon(Icons.done),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        }
    );
  }
  ScrollController controller = ScrollController(keepScrollOffset: false);
  @override
  onShowLoader() {
    print("Show Loader");
    setState(() {
      isVisible = true;
    });
  }

  @override
  onHideLoader() {
    print("Hide Loader");
    setState(() {
      isVisible = false;
    });
  }

  @override
  onErrorHandler(String message){
    Toast toast = Toast();
    toast.overLay = false;
    toast.showOverLay(message, Colors.white, Colors.black54, context,seconds: 3);
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
    _presenter.getCalendarEvent();

    return googleSignInAuthentication.accessToken; //new token
  }

  @override
  onCreateEvent(response) {
    print('onSucess:::$response');
  }


}
