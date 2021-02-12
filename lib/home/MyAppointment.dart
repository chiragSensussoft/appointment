import 'dart:async';

import 'package:appointment/home/home_view_model.dart';
import 'package:appointment/home/model/CalendarEvent.dart';
import 'package:appointment/home/model/CalendarList.dart';
import 'package:appointment/home/presenter/HomePresentor.dart';
import 'package:appointment/utils/DBProvider.dart';
import 'package:appointment/utils/app_bar/ScrollAppBar.dart';
import 'package:appointment/utils/Toast.dart';
import 'package:appointment/utils/values/Constant.dart';
import 'package:appointment/utils/values/Palette.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:sqflite/sqflite.dart';
import 'LoadMore.dart';
import 'OnHomeView.dart';

class MyAppointment extends StatefulWidget {
  ScrollController controller = ScrollController();

  MyAppointment(this.controller);

  @override
  MyAppointmentState createState() => MyAppointmentState();
}

class MyAppointmentState extends State<MyAppointment>with TickerProviderStateMixin implements OnHomeView {
  bool isVisible;
  List<Item> list = List.empty(growable: true);
  List<Item> itemList = List.empty(growable: true);
  List<EventItem> eventItem = List.empty(growable: true);
  HomeViewModel model;
  HomePresenter presenter;
  SharedPreferences _sharedPreferences;

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

  String access_token = '';
  FirebaseUser user;
  String url;
  String userName = '';
  String email = '';
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool loader = false;
  bool descTextShowFlag = false;
  bool isLoading = false;
  bool isShareAppointment = false;
  bool _isVisible = true;


  @override
  void initState() {
    super.initState();
    fetchLinkData();
    init();
    refreshToken();
    _query();

    _isVisible = true;
    widget.controller.addListener(() {
      if (widget.controller.position.userScrollDirection ==
          ScrollDirection.reverse) {
        setState(() {
          _isVisible = false;
        });
      }
      if (widget.controller.position.userScrollDirection ==
          ScrollDirection.forward) {
        setState(() {
          _isVisible = true;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  init() async {
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
    List<Map> result = await db.query(DatabaseHelper.table,
        columns: columnsToSelect,
        where: whereString,
        whereArgs: whereArguments);

    setState(() {
      url = result[0]['photoUrl'];
      userName = result[0]['fName'];
      email = result[0]['email'];
    });
  }

  bool loadingMore;
  bool hasMoreItems;
  Future initialLoad;
  int lastIndex;
  Future _loadMoreItems() async {
    if(widget.controller.position.pixels == widget.controller.position.maxScrollExtent){
      await presenter.getCalendarEvent(maxResult: 10,currentTime: DateTime.now().toUtc(),isPageToken: true,pageToken: map['nextPageToken']);
    }
    else{
      hasMoreItems = false;
    }
    hasMoreItems = map['nextPageToken'] != null;
  }

  @override
  Widget build(BuildContext context) {
    model = HomeViewModel(this);

    return Scaffold(
        key: _scaffoldKey,
        body: RefreshIndicator(
              child: Stack(
                children: [
                  Container(
                      color: Colors.grey[200],
                      child: isVisible == false
                          ? eventItem.length != 0
                          ? FutureBuilder(
                        future: initialLoad,
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                              return Center(child: CircularProgressIndicator());
                            case ConnectionState.done:
                              return IncrementallyLoadingListView(
                                hasMore: () => hasMoreItems,
                                itemCount: () => eventItem.length,
                                loadMore: () async {
                                  await _loadMoreItems();
                                },
                                onLoadMore: () {
                                  setState(() {
                                    loadingMore = true;
                                  });
                                },
                                onLoadMoreFinished: () {
                                  setState(() {
                                    loadingMore = false;
                                  });
                                },
                                controller: widget.controller,
                                loadMoreOffsetFromBottom: 2,
                                shrinkWrap: false,
                                physics: AlwaysScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  lastIndex = index;
                                  if ((loadingMore ?? false) && index == eventItem.length-1) {
                                    return Column(
                                      children: <Widget>[
                                        model.slideMenu(index),
                                        PlaceholderItemCard(index: index,)
                                      ],
                                    );
                                  }
                                  return model.slideMenu(index);
                                },
                              );
                            default:
                              return Text('Something went wrong');
                          }
                        },
                      )
                          : Center(child: Text("No Event Created"))
                          :  ListView.builder(
                        itemCount: 40,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (_,index){
                          return PlaceholderItemCard(index: index);
                        },
                      )
                  ),
                ],
              ),
              onRefresh: () {
                print('onrefresh::::${access_token}');
                eventItem.clear();
                hasMoreItems = true;
                return presenter.getCalendarEvent(pageToken: map['nextPageToken'],maxResult: 10,currentTime: DateTime.now().toUtc(),isPageToken: false);
              }),

      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButton: _isVisible ? FloatingActionButton(
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
        elevation: 12,
        onPressed: () {
          model.openBottomSheetView(isEdit: false);
          // showAsBottomSheet("afvbsd","Asgv","asgvasd","Asdgasdg","asdgadsg","Asdgs","adfgasdfg","adsfgad");
        },
      ) : null,
    );
  }

  var dynamicLink;

  Future<Uri> createDynamicLink(
      {@required title,
      @required desc,
      @required startDate,
      @required endDate,
      @required email,
      @required photoUrl,
      @required senderName,
      @required timeZone}) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://appointmrnt.page.link',
      link: Uri.parse(
          'https://appointmrnt.page.link/appointment?summary=$title&description=$desc&startDate=$startDate&endDate=$endDate&senderEmail=$email&senderPhoto=$photoUrl&senderName=$senderName&timeZone=$timeZone'),
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
    final ShortDynamicLink shortenedLink =
        await DynamicLinkParameters.shortenUrl(link,
      DynamicLinkParametersOptions(
          shortDynamicLinkPathLength: ShortDynamicLinkPathLength.unguessable),
    );
    return shortenedLink.shortUrl;
  }

  Future<bool> showConfirmationDialog(BuildContext context, String action, int index) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure you want to $action this Event?', style: TextStyle(fontSize: 14, fontFamily: "poppins_regular"),),
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
                presenter.deleteEvent(eventItem[index].id, eventItem[index].creator.email);
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> showShareDialog(
      BuildContext context, String action, int index) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure you want to $action this Event?', style: TextStyle(fontSize: 16, fontFamily: 'poppins_regular')),
          actions: <Widget>[
            FlatButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            FlatButton(
              child: const Text('Yes'),
              onPressed: () async {
                String startDate = eventItem[index].start.dateTime.toLocal().year.toString() + "-" + eventItem[index].start.dateTime.toLocal().month.toString() + "-" +eventItem[index].start.dateTime.toLocal().day.toString();
                String startTime = eventItem[index].start.dateTime.toLocal().hour.toString() + ":" + eventItem[index].start.dateTime.toLocal().minute.toString() + ":" +"00";
                print("Date ${startDate + "T" + startTime}");
                String endDate = eventItem[index].end.dateTime.toLocal().year.toString() + "-" + eventItem[index].end.dateTime.toLocal().month.toString() + "-" + eventItem[index].end.dateTime.toLocal().day.toString();
                String endTime = eventItem[index].end.dateTime.toLocal().hour.toString() + ":" + eventItem[index].end.dateTime.toLocal().minute.toString() + ":" + "00";

                dynamicLink = await createDynamicLink(
                    title: eventItem[index].summary,
                    desc: eventItem[index].description,
                    startDate: startDate + "T" + startTime,
                    endDate: endDate + "T" + endTime,
                    email: email,
                    photoUrl: url,
                    senderName: userName,
                    timeZone: eventItem[index].start.timeZone);

                print("Dynamic Link: $dynamicLink");

                if (dynamicLink != "") {
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
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      handleLinkData(dynamicLink);
    });
  }

  Toast toast = Toast();

  void handleLinkData(PendingDynamicLinkData data) {
    final Uri uri = data?.link;
    if (uri != null) {
      final queryParams = uri.queryParameters;
      if (queryParams.length > 0) {
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

        if (summary.isEmpty ||
            description.isEmpty ||
            startDate.isEmpty ||
            endDate.isEmpty ||
            senderName.isEmpty ||
            senderPhoto.isEmpty ||
            senderEmail.isEmpty) {
          toast.overLay = false;
          toast.showOverLay(
              "Data is not valid", Colors.white, Colors.black54, context,
              seconds: 3);
        } else {
          print("Enter in Else");
          // refreshToken();
          eventItem.clear();
          showAsBottomSheet(senderName, senderPhoto, senderEmail,
              startDate, endDate, summary, description, timeZone);
        }
      }
    }
  }

  void showAsBottomSheet(String senderName, senderPhoto, senderEmail, startDate,
      endDate, summary, description, timeZone) async {
    print('image:::$senderPhoto');

    return await showSlidingBottomSheet(context, builder: (context) {
      return SlidingSheetDialog(
        elevation: 8,
        cornerRadius: 20,
        snapSpec: const SnapSpec(
          // snap: false,
          positioning: SnapPositioning.relativeToAvailableSpace,
        ),
        duration: Duration(milliseconds: 200),
        builder: (context, state) {
          return Material(
            child: Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 15),
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: Text("Create New Event",
                        style: TextStyle(
                            fontSize: 16, fontFamily: "poppins_medium")),
                  ),
                  Row(
                    children: [
                      SizedBox(height: 20),
                      Container(
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(senderPhoto),
                        ),
                      ),
                      SizedBox(width: 15),
                      Container(
                        child: Text(senderName,
                            style: TextStyle(
                                fontSize: 16, fontFamily: "poppins_medium")),
                      )
                    ],
                  ),
                  SizedBox(height: 15),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(summary,
                        style: TextStyle(
                            fontSize: 14, fontFamily: "poppins_regular")),
                  ),
                  SizedBox(height: 15),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(description,
                        style: TextStyle(
                            fontSize: 14, fontFamily: "poppins_regular")),
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Text(
                              'From',
                              style: TextStyle(
                                  fontSize: 16, fontFamily: "poppins_medium"),
                            ),
                          ),
                          Container(
                            child: Text(startDate,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: "poppins_regular")),
                          )
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Text(
                              'To',
                              style: TextStyle(
                                  fontSize: 16, fontFamily: "poppins_medium"),
                            ),
                            alignment: Alignment.centerLeft,
                          ),
                          Container(
                            child: Text(endDate,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: "poppins_regular")),
                          )
                        ],
                      )
                    ],
                  ),

                  SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: (){
                          presenter.setAppointment(
                              summary: summary,
                              endDate: endDate,
                              startDate: startDate,
                              description: description,
                              timeZone: timeZone);
                          setState(() {
                            isShareAppointment = true;
                          });
                          // Navigator.pop(context);
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 15),
                            height: 40,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.green),

                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                    child: Text("Accept",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontFamily: "poppins_regular")),
                                    padding: EdgeInsets.only(left: 10)),
                                IconButton(
                                  iconSize: 20,
                                  onPressed: () {},
                                  color: Colors.white,
                                  icon: Icon(Icons.done),
                                )
                              ],
                            )),
                      ),

                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: Container(
                            margin: EdgeInsets.only(bottom: 15),
                            height: 40,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.red),

                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,

                              children: [
                                Padding(
                                  child: Text("Cancel",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontFamily: "poppins_regular"),),
                                  padding: EdgeInsets.only(left: 10),
                                ),

                                IconButton(
                                  iconSize: 20,
                                  padding: EdgeInsets.zero,
                                  onPressed: () {},
                                  color: Colors.white,
                                  icon: Icon(Icons.close_rounded),
                                )
                              ],
                            )),
                      )
                    ],
                  ),

                  SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  shareSheet(String senderName, senderPhoto, senderEmail, startDate,
      endDate, summary, description, timeZone){
    return showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))
      ),
      builder: (_){
        return Material(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))
          ),
          child: Container(
            padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 15),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.center,
                  child: Text("Create New Event",
                      style: TextStyle(
                          fontSize: 16, fontFamily: "poppins_medium")),
                ),
                Row(
                  children: [
                    SizedBox(height: 20),
                    Container(
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(senderPhoto),
                      ),
                    ),
                    SizedBox(width: 15),
                    Container(
                      child: Text(senderName,
                          style: TextStyle(
                              fontSize: 16, fontFamily: "poppins_medium")),
                    )
                  ],
                ),
                SizedBox(height: 15),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(summary,
                      style: TextStyle(
                          fontSize: 14, fontFamily: "poppins_regular")),
                ),
                SizedBox(height: 15),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(description,
                      style: TextStyle(
                          fontSize: 14, fontFamily: "poppins_regular")),
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(
                            'From',
                            style: TextStyle(
                                fontSize: 16, fontFamily: "poppins_medium"),
                          ),
                        ),
                        Container(
                          child: Text(startDate,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: "poppins_regular")),
                        )
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(
                            'To',
                            style: TextStyle(
                                fontSize: 16, fontFamily: "poppins_medium"),
                          ),
                          alignment: Alignment.centerLeft,
                        ),
                        Container(
                          child: Text(endDate,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: "poppins_regular")),
                        )
                      ],
                    )
                  ],
                ),

                SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: (){
                        presenter.setAppointment(
                            summary: summary,
                            endDate: endDate,
                            startDate: startDate,
                            description: description,
                            timeZone: timeZone);
                        setState(() {
                          isShareAppointment = true;
                        });
                        // Navigator.pop(context);
                      },
                      child: Container(
                          margin: EdgeInsets.only(bottom: 15),
                          height: 40,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.green),

                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                  child: Text("Accept",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontFamily: "poppins_regular")),
                                  padding: EdgeInsets.only(left: 10)),
                              IconButton(
                                iconSize: 20,
                                onPressed: () {},
                                color: Colors.white,
                                icon: Icon(Icons.done),
                              )
                            ],
                          )),
                    ),

                    GestureDetector(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: Container(
                          margin: EdgeInsets.only(bottom: 15),
                          height: 40,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.red),

                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,

                            children: [
                              Padding(
                                child: Text("Cancel",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontFamily: "poppins_regular"),),
                                padding: EdgeInsets.only(left: 10),
                              ),

                              IconButton(
                                iconSize: 20,
                                padding: EdgeInsets.zero,
                                onPressed: () {},
                                color: Colors.white,
                                icon: Icon(Icons.close_rounded),
                              )
                            ],
                          )),
                    )
                  ],
                ),

                SizedBox(height: 10),
              ],
            ),
          ),
        );
      }
    );
  }


  @override
  onShowLoader() {
    print("Show Loader");
    setState(() {
      isVisible = true;
      loader = true;
    });
  }

  @override
  onHideLoader() {
    print("Hide Loader");
    setState(() {
      isVisible = false;
      loader = false;
    });
  }

  @override
  onErrorHandler(String message) {
    Toast toast = Toast();
    toast.overLay = false;
    loader = true;
    toast.showOverLay(message, Colors.white, Colors.black54, context,
        seconds: 3);
    setState(() {
      isVisible = false;
    });
  }

  @override
  onSuccessRes(response) {
    setState(() {
      List<dynamic> data = response;
      list.addAll(data.map((i) => Item.fromJson(i)).toList());

      for (int i = 0; i < data.length; i++) {
        if (data[i]['accessRole'] == "owner") {
          itemList.add(Item.fromJson(data[i]));
        }
      }
    });
  }

  Map<String, dynamic> map;

  @override
  onEventSuccess(response, calendarResponse) {
    print("success ${response.runtimeType}");

    setState(() {
      map = calendarResponse;
      List<dynamic> data = response;
      eventItem.addAll(data.map((e) => EventItem.fromJson(e)).toList());
    });
    print("Length${eventItem.length}");
  }

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

    _sharedPreferences.setString(
        Constant.ACCESS_TOKEN, googleSignInAuthentication.accessToken);
    access_token = googleSignInAuthentication.accessToken;
    print("Id token 1 ==> $access_token");

    AuthResult authResult = await _auth.signInWithCredential(credential);
    user = authResult.user;
    Constant.email = user.email;
    Constant.token = googleSignInAuthentication.accessToken;

    presenter = new HomePresenter(this, token: googleSignInAuthentication.accessToken);
    presenter.attachView(this);
    presenter.getCalendar(googleSignInAuthentication.accessToken);
    initialLoad = presenter.getCalendarEvent(maxResult: 10,currentTime: DateTime.now().toUtc(),isPageToken: false);
    hasMoreItems = true;

    return googleSignInAuthentication.accessToken;
  }

  @override
  onCreateEvent(response) {
    print('onSucess:::$response');
    Navigator.pop(context);
    toast.overLay = false;
    toast.showOverLay("Appointment created successfully", Colors.white, Colors.black54, context);
    if(isShareAppointment = true){
      presenter.getCalendarEvent(maxResult: 10,isPageToken: false,currentTime: DateTime.now().toUtc());

    }
  }

  @override
  onUpdateEvent(response) {
    print('update:::;$response');
  }

  @override
  onDelete(delete) {
      eventItem.removeWhere((element) => element.id == delete);
  }
}

class PlaceholderItemCard extends StatelessWidget {
  const PlaceholderItemCard({Key key, @required this.index}) : super(key: key);

  final index;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10, top: 5, right: 10, bottom:5),
      child: Material(
        color: Colors.grey[100],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Shimmer.fromColors(child: Padding(
          padding: EdgeInsets.only(left: 0, top: 0, right: 0, bottom:0),
          child: GestureDetector(
           child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(top: 8, bottom: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      SizedBox(height: 5),
                      Container(
                        padding: EdgeInsets.only(left: 18, right: 18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              height: 5,
                              width: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  color: Colors.white
                              ),
                            ),
                            Container(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                 Container(
                                   height: 15,
                                   width: 15,
                                   decoration: BoxDecoration(
                                     borderRadius: BorderRadius.circular(2),
                                     color: Colors.white
                                   ),
                                 ),
                                  Container(
                                    margin: EdgeInsets.only(left: 5),
                                    height: 15,
                                    width: 15,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(2),
                                        color: Colors.white
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 3),
                      Divider(
                        color: Colors.white,
                        thickness: 0.3,
                        height: 0.3,
                      ),
                      SizedBox(height: 5),
                      Container(
                        padding: EdgeInsets.only(left: 18, right: 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 5,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  color: Colors.white
                              ),
                            ),
                            Container(
                              height: 5,
                              margin: EdgeInsets.only(top: 5),
                              width: MediaQuery.of(context).size.width * 0.80,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  color: Colors.white
                              ),
                            ),
                          ],
                        )
                      ),
                      SizedBox(height: 5),

                      Container(
                        margin: EdgeInsets.only(left: 18,bottom: 10),
                        child:Column(
                          children: [
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    child: Row(
                                      children: [
                                        Container(
                                          height:10,
                                          width: 10,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(60)
                                          ),
                                        ),
                                        Container(
                                          height: 5,
                                          margin: EdgeInsets.only(left: 7),
                                          width: MediaQuery.of(context).size.width * 0.50,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(2),
                                              color: Colors.white
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(left: 4.5),
                                        alignment: Alignment.centerLeft,
                                        height: 20,
                                        width: 1,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                  Container(
                                    child: Row(
                                      children: [
                                        Container(
                                          height:10,
                                          width: 10,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(60)
                                          ),
                                        ),
                                        Container(
                                          height: 5,
                                          margin: EdgeInsets.only(left: 7),
                                          width: MediaQuery.of(context).size.width * 0.50,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(2),
                                              color: Colors.white
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  )
              ),
          ),
        ),
          baseColor: Colors.grey[300],
          highlightColor: Colors.grey[100],
          enabled: true,
        ),
      ),
    );
  }
}