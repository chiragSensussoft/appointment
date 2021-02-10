import 'dart:async';

import 'package:appointment/home/home_view_model.dart';
import 'package:appointment/home/model/CalendarEvent.dart';
import 'package:appointment/home/model/CalendarList.dart';
import 'package:appointment/home/presenter/HomePresentor.dart';
import 'package:appointment/utils/DBProvider.dart';
import 'package:appointment/utils/Toast.dart';
import 'package:appointment/utils/slide_menu.dart';
import 'package:appointment/utils/values/Constant.dart';
import 'package:appointment/utils/values/Palette.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:sqflite/sqflite.dart';
import 'LoadMore.dart';
import 'OnHomeView.dart';

class MyAppointment extends StatefulWidget {
  @override
  MyAppointmentState createState() => MyAppointmentState();
}

class MyAppointmentState extends State<MyAppointment> implements OnHomeView {
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
  // bool isEventEdit = false;
  ScrollController controller = ScrollController(keepScrollOffset: false);

  @override
  void initState() {
    super.initState();
    fetchLinkData();
    init();
    refreshToken();
    _query();
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
  Future _loadMoreItems() async {
    if(controller.position.pixels == controller.position.maxScrollExtent){
      await presenter.getCalendarEvent(maxResult: 10,currentTime: DateTime.now().toUtc(),isPageToken: true,pageToken: map['nextPageToken']);

    }
    hasMoreItems = map['nextPageToken'] != null;
  }

  @override
  Widget build(BuildContext context) {
    model = HomeViewModel(this);

    return Scaffold(
        key: _scaffoldKey,
        body: Container(
          child: RefreshIndicator(
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
                              controller: controller,
                              loadMoreOffsetFromBottom: 2,
                              itemBuilder: (context, index) {
                                if ((loadingMore ?? false) && index == eventItem.length -1) {
                                  return Column(
                                    children: <Widget>[
                                      model.slideMenu(index),
                                      // Container(
                                      //   width: double.infinity,
                                      //   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                                      //   child: Column(
                                      //     mainAxisSize: MainAxisSize.max,
                                      //     children: <Widget>[
                                      //       Expanded(
                                      //         child: Shimmer.fromColors(
                                      //           baseColor: Colors.grey[300],
                                      //           highlightColor: Colors.grey[100],
                                      //           enabled: true,
                                      //           child: ListView.builder(
                                      //             itemBuilder: (_, __) => Padding(
                                      //               padding: const EdgeInsets.only(bottom: 8.0),
                                      //               child: Row(
                                      //                 crossAxisAlignment: CrossAxisAlignment.start,
                                      //                 children: [
                                      //                   Container(
                                      //                     width: 48.0,
                                      //                     height: 48.0,
                                      //                     color: Colors.white,
                                      //                   ),
                                      //                   const Padding(
                                      //                     padding: EdgeInsets.symmetric(horizontal: 8.0),
                                      //                   ),
                                      //                   Expanded(
                                      //                     child: Column(
                                      //                       crossAxisAlignment: CrossAxisAlignment.start,
                                      //                       children: <Widget>[
                                      //                         Container(
                                      //                           width: double.infinity,
                                      //                           height: 8.0,
                                      //                           color: Colors.white,
                                      //                         ),
                                      //                         const Padding(
                                      //                           padding: EdgeInsets.symmetric(vertical: 2.0),
                                      //                         ),
                                      //                         Container(
                                      //                           width: double.infinity,
                                      //                           height: 8.0,
                                      //                           color: Colors.white,
                                      //                         ),
                                      //                         const Padding(
                                      //                           padding: EdgeInsets.symmetric(vertical: 2.0),
                                      //                         ),
                                      //                         Container(
                                      //                           width: 40.0,
                                      //                           height: 8.0,
                                      //                           color: Colors.white,
                                      //                         ),
                                      //                       ],
                                      //                     ),
                                      //                   )
                                      //                 ],
                                      //               ),
                                      //             ),
                                      //             itemCount: 1,
                                      //           ),
                                      //         ),
                                      //       ),
                                      //     ],
                                      //   ),
                                      // )
                                      CircularProgressIndicator()
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
                        :  Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Expanded(
                            child: Shimmer.fromColors(
                              baseColor: Colors.grey[300],
                              highlightColor: Colors.grey[100],
                              enabled: true,
                              child: ListView.builder(
                                itemBuilder: (_, __) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: SlideMenu(
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 10, top: 5, right: 10, bottom:5),
                                      child: GestureDetector(
                                        child: Material(
                                          elevation: 1,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          child: Container(
                                              width: MediaQuery.of(context).size.width,
                                              padding: EdgeInsets.only(top: 8, bottom: 8, left: 18, right: 18),

                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,

                                                children: [
                                                  SizedBox(height: 5),

                                                  Container(
                                                    child: SizedBox(),
                                                  ),

                                                  SizedBox(height: 5),

                                                  Container(
                                                    margin: EdgeInsets.only(bottom: 5),
                                                    // child: state.eventItem[index].description != null ?  DescriptionTextWidget(text: state.eventItem[index].description) :Text("", style: TextStyle(fontSize: 13, fontFamily: "poppins_regular", color: Colors.black.withOpacity(0.5))),
                                                  ),

                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                                                    children: [
                                                      Expanded(
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Container(
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Container(child: Text('From', style: TextStyle(fontSize: 12, fontFamily: "poppins_regular", color: Colors.black.withOpacity(0.5)))),

                                                                  Container(
                                                                    child: Text(""
                                                                      // DateFormat('EE, d MMM, yyyy').format(state.eventItem[index].start.dateTime.toLocal()) + "  " +
                                                                      //     state.eventItem[index].start.dateTime.toLocal().hour.toString() + ":" +
                                                                      //     state.eventItem[index].start.dateTime.toLocal().minute.toString(),
                                                                      // style: TextStyle(fontSize: 12, fontFamily: "poppins_regular", color: Colors.black.withOpacity(0.5))
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),

                                                            Container(
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Container(
                                                                    child: Text('   ', style: TextStyle(fontSize: 12, fontFamily: "poppins_regular",color: Colors.black.withOpacity(0.5))),
                                                                  ),

                                                                  Container(
                                                                      child: Text("  "
                                                                        // DateFormat('EE, d MMM, yyyy').format(state.eventItem[index].end.dateTime.toLocal()) + "  " +
                                                                        //     state.eventItem[index].end.dateTime.toLocal().hour.toString() + ":" + state.eventItem[index].end.dateTime.toLocal().minute.toString(),
                                                                        // style: TextStyle(fontSize: 12, fontFamily: "poppins_regular",color: Colors.black.withOpacity(0.5)),
                                                                      )
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),

                                                      Container(
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                          children: [
                                                            GestureDetector(
                                                              child: Padding(
                                                                  padding: EdgeInsets.only(left: 30),
                                                                  child: Icon(Icons.edit_outlined,size: 20, color: Colors.black.withOpacity(0.5))),
                                                            ),

                                                            GestureDetector(
                                                              child: Padding(
                                                                  padding:EdgeInsets.only(left:10),
                                                                  child: Icon(Icons.share_rounded,size: 20, color: Colors.black.withOpacity(0.5))),
                                                              onTap: (){

                                                              },
                                                            )
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  )

                                                ],
                                              )
                                          ),
                                        ),
                                        // ),
                                      ),
                                    ),

                                    menuItems: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(top: 5, bottom: 5),
                                        child: Container(
                                          height: MediaQuery.of(context).size.height,
                                          width: 10,
                                          color: Colors.red,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              IconButton(
                                                icon: Icon(Icons.delete_forever_sharp,color: Colors.white),
                                              ),
                                              Text("Delete", style: TextStyle(fontSize: 14, fontFamily: 'poppins_regular', color: Colors.white))
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                itemCount: 6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              onRefresh: () {
                print('onrefresh::::${access_token}');
                eventItem.clear();
                return presenter.getCalendarEvent(pageToken: map['nextPageToken'],maxResult: 10,currentTime: DateTime.now().toUtc(),isPageToken: false);
              }),
        ),

        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            backgroundColor: Palette.colorPrimary,
            onPressed: () async {
              print(dynamicLink);

              model.openBottomSheetView(isEdit: false);
            }));
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
                presenter.deleteEvent(eventItem[index].id, eventItem[index].creator.email);
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _showShareDialog(
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
          refreshToken();
          Future.delayed(Duration(seconds: 1)).whenComplete(() => {
            showAsBottomSheet(senderName, senderPhoto, senderEmail,
                startDate, endDate, summary, description, timeZone)
          });
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
          snap: false,
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
    presenter.getCalendarEvent();
  }

  @override
  onUpdateEvent(response) {
    print('update:::;$response');
  }
}
