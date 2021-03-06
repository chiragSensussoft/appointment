import 'dart:async';
import 'dart:convert';
import 'package:appointment/home/home_view_model.dart';
import 'package:appointment/home/model/CalendarEvent.dart';
import 'package:appointment/home/model/CalendarList.dart';
import 'package:appointment/home/model/LatLong.dart';
import 'package:appointment/home/model/Menu.dart';
import 'package:appointment/home/presenter/HomePresentor.dart';
import 'package:appointment/interface/IsAcceptAppointment.dart';
import 'package:appointment/utils/CustomDialogBox.dart';
import 'package:appointment/utils/progressbar.dart';
import 'package:appointment/utils/DBProvider.dart';
import 'package:appointment/utils/expand_text.dart';
import 'package:appointment/utils/values/Constant.dart';
import 'package:appointment/utils/values/Strings/Strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sqflite/sqflite.dart';
import 'LoadMore.dart';
import 'OnHomeView.dart';


class MyAppointment extends StatefulWidget {
  ScrollController controller;
  List<EventItem> eventItem;
  List<Item> itemList = List.empty(growable: true);
  List<EventItem> searchEventList;
  Function(bool) onCreate;

  MyAppointment({this.controller,this.onCreate});

  @override
  MyAppointmentState createState() => MyAppointmentState();
}

class MyAppointmentState extends State<MyAppointment>with TickerProviderStateMixin
    implements OnHomeView, IsAcceptAppointment {
  bool isVisible;
  List<Item> itemList = List.empty(growable: true);
  List<EventItem> eventItem = List.empty(growable: true);
  List<EventItem> searchEventList = List.empty(growable: true);
  List<SortMenu> menu = List<SortMenu>.empty(growable: true);

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
  // bool _isVisible = true;
  var dynamicLink;

  int _state = 0;
  Animation _animation;
  AnimationController _controller;
  GlobalKey _globalKey = GlobalKey();
  double _width = double.maxFinite;
  String _searchText = "";
  TextEditingController search = TextEditingController();


  // @override
  // void dispose() {
  //   super.dispose();
  //   _controller.dispose();
  // }

  @override
  void initState() {
    super.initState();
    fetchLinkData();
    init();
    refreshToken();
    _query();

    // _isVisible = true;
    menu.add(SortMenu(title: "Asc",isVisible: true));
    menu.add(SortMenu(title: "Desc",isVisible: false));
    menu.add(SortMenu(isVisible: false,title: "Between"));
    menu.add(SortMenu(isVisible: false,title: "Clear"));

    // widget.controller.addListener(() {
    //   if (widget.controller.position.userScrollDirection == ScrollDirection.reverse) {
    //     setState(() {
    //         _isVisible = false;
    //     });
    //   }
    //   if (widget.controller.position.userScrollDirection == ScrollDirection.forward) {
    //     setState(() {
    //       _isVisible = true;
    //     });
    //   }
    // });
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
    if(widget.controller.position.pixels == widget.controller.position.maxScrollExtent || hasMoreItems == true){
      await presenter.getCalendarEvent(maxResult: 10,minTime: DateTime.now().toUtc(),
          isPageToken: true,pageToken: map['nextPageToken']);
    }
    else{
      hasMoreItems = false;
    }
    hasMoreItems = map['nextPageToken'] != null;
  }

  @override
  Widget build(BuildContext context) {
    model = HomeViewModel(state: this);

    return Scaffold(
      key: _scaffoldKey,
      body: RefreshIndicator(
          child: Stack(
            children: [
              Container(
                  color: Colors.grey[200],
                  child: isVisible == false ? eventItem.length != 0
                      ? FutureBuilder(
                    future: initialLoad,
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return Center(child: CircularProgressIndicator());
                        case ConnectionState.done:
                          return Container(
                            margin: EdgeInsets.only(top: 35),
                            padding: EdgeInsets.only(top: 20),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))
                            ),
                            child: IncrementallyLoadingListView(
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
                                      PlaceholderItemCard(index: index,height: 128,)
                                    ],
                                  );
                                }
                                return model.slideMenu(index);
                              },
                            ),
                          );
                        default:
                          return Text('Something went wrong');
                      }
                    },

                  )
                      : Center(child: Text("No Event Created"))
                      :  Container(
                    margin: EdgeInsets.only(top: 55),
                    child: ListView.builder(
                      itemCount: 40,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (_,index){
                        return PlaceholderItemCard(index: index,height: 128,);
                      },
                    ),
                  )
              ),
              Container(
                margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                height: 40,
                child: Row(
                  children: [
                    Container(
                      child: Expanded(
                        child:Material(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(left: 15, top: 5),
                                    child: Icon(Icons.search)),
                                Expanded(
                                  child: TextFormField(
                                    cursorColor: Colors.blue,
                                    controller: search,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.only(left: 5,right: 20,bottom: 5),
                                      border: InputBorder.none,
                                      hintText: "Search event here...",
                                      hintStyle:TextStyle(color: Color(0xff707070),
                                        fontSize: 12,
                                        fontFamily: "poppins_medium",),),
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                        fontFamily: "poppins_regular"),
                                    onChanged: (val){
                                      setState(() {
                                        eventItem = eventItem.where((element) => element.summary.contains(_searchText) || element.description.contains(_searchText)).toList();
                                      });
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Material(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.all(7),
                            child: SvgPicture.asset("images/filter.svg",height: 30,width: 20,),
                          ),
                        ),
                      ),
                      onTap: (){
                        _showPopupMenu(context);
                      },
                    )
                  ],
                ),
              ),
            ],
          ),

          onRefresh: () {
            print('onRefresh --> ${access_token}');
            searchEventList.clear();
            itemList.clear();
            isVisible = true;
            return refreshToken();
          }),

      // floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      // floatingActionButton: _isVisible ? FloatingActionButton(
      //   backgroundColor: Colors.grey[100],
      //   child: Icon(Icons.add,color: Colors.black,),
      //   elevation: 12,
      //   onPressed: () {
      //     model.openBottomSheetView(isEdit: false);
      //   },
      // ) : null,
    );
  }
  int selectedIndex;

  MyAppointmentState() {
    search.addListener(() {
      if (search.text.isEmpty) {
        setState(() {
          // _isSearch = true;
          _searchText = "";
          eventItem = searchEventList;
        });
      } else {
        setState(() {
          // _isSearch = false;
          _searchText = search.text;
          print("Text $_searchText");
        });
      }
    });
  }

  _showPopupMenu(BuildContext context) async {
    await showMenu(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
      ),
      position: RelativeRect.fromLTRB(MediaQuery.of(context).size.width, 118, 0, 00),
      items: menu.map((e) {
        return PopupMenuItem<String>(
          height: 30,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                  alignment: Alignment.center,
                  child: e.isVisible ? Text(e.title,style: TextStyle(color:Colors.blue)):
                  Text(e.title,)
              )
            ],
          ),
          value: e.title,
        );
      }).toList(),
      elevation: 8.0,
    ).then((value){
      setState(() {
        selected = value;
      });
      if(value!=null){
        selected = value;
        if(menu[0].title==value){
          setState(() {
            eventItem.sort((a,b)=> a.start.dateTime.compareTo(b.start.dateTime));
            menu.where((element) => element.isVisible != element.isVisible);
            menu.forEach((element) => element.isVisible = false);
            menu[0].isVisible = true;
          });
        }
        else if(menu[1].title==value){
          setState(() {
            eventItem.sort((a,b)=> b.start.dateTime.compareTo(a.start.dateTime));
            menu.where((element) => element.isVisible != element.isVisible);
            menu.forEach((element) => element.isVisible = false);
            menu[1].isVisible = true;
          });
        }
        else if (menu[2].title==value){
          menu.forEach((element) => element.isVisible = false);
          menu[2].isVisible = true;
          showDialog(context: context, builder: (BuildContext context){
            return CustomDialogBox(onTap: (fromDate, toDate){
              print('form:::::${fromDate.isUtc}');
              print('to:::::${toDate.isUtc}');
              eventItem.clear();
              searchEventList.clear();
              hasMoreItems = true;
              return presenter.getCalendarEvent(pageToken: map['nextPageToken'],
                  maxResult: 10, minTime: fromDate, maxTime: toDate, isPageToken: false);
            },);
          }
          );
        }
        else{
          setState(() {
            eventItem.clear();
            itemList.clear();
            searchEventList.clear();
            isVisible = true;
            refreshToken();
            menu.forEach((element) {
              setState(() {
                element.isVisible = false;
              });
            });
          });
        }
      }
    });
  }


  String selected = "Start Date";
  final List<String> sortList = <String>["Asc","Desc","Between"];


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
      DynamicLinkParametersOptions(shortDynamicLinkPathLength: ShortDynamicLinkPathLength.unguessable),
    );
    return shortenedLink.shortUrl;
  }

  Future<bool> showConfirmationDialog(BuildContext context, String action, int index) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Resources.from(context, Constant.languageCode).strings.conformDelete, style: TextStyle(fontSize: 14, fontFamily: "poppins_regular"),),
          actions: <Widget>[
            FlatButton(
              child: Text(Resources.from(context, Constant.languageCode).strings.no),
              onPressed: () {
                // setState(() {
                //     eventItem.insert(index, eventItem[index]);
                // });
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(Resources.from(context, Constant.languageCode).strings.yes),
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

  void fetchLinkData() async {
    var link = await FirebaseDynamicLinks.instance.getInitialLink();
    handleLinkData(link);
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
          handleLinkData(dynamicLink);
        });
  }

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

        print('startDate::::$startDate');

        if (summary.isEmpty || description.isEmpty || startDate.isEmpty || endDate.isEmpty || senderName.isEmpty || senderPhoto.isEmpty
            || senderEmail.isEmpty) {
          Constant.showToast(Resources.from(context, Constant.languageCode).strings.invalidData, Toast.LENGTH_LONG);

        } else {
          // refreshToken();
          if(senderEmail != email){
            String sDate = startDate.replaceAll("T"," ");

            print("Enter in Else  $sDate   ${DateTime.now()}");

            DateTime.parse(sDate).isAfter(DateTime.now()) ?
            showSharedAppointment(senderName, senderPhoto, senderEmail, startDate, endDate,
                summary, description, timeZone):
            showAlertDialog(Resources.from(context, Constant.languageCode).strings.dialogPastEvent);
          }
          else{
            showAlertDialog(Resources.from(context, Constant.languageCode).strings.dialogCreateOwnEvent);
          }
        }
      }
    }
  }

  // ignore: non_constant_identifier_names
  var str_senderName, str_senderPhoto, str_senderEmail, str_startDate, str_EndDate, str_summary, str_description,  str_timeZone;

  showSharedAppointment(String senderName, senderPhoto, senderEmail, startDate, endDate, summary, description, timeZone){
    str_senderName = senderName;
    str_senderPhoto = senderPhoto;
    str_senderEmail = senderEmail;
    str_startDate = startDate;
    str_EndDate = endDate;
    str_summary = summary;
    str_description = description;
    str_timeZone = timeZone;

    String sDate = startDate.replaceAll("T"," ");
    String eDate = endDate.replaceAll("T"," ");

    return showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(20),topLeft: Radius.circular(20))),
        builder: (_){
          return Material(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(20),topLeft: Radius.circular(20))),
            child: Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: Text(Resources.from(context, Constant.languageCode).strings.createNewEvent,
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
                    Visibility(
                      visible: description!=null,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: ReadMoreText(
                          description,
                          trimLines: 3,
                          colorClickableText: Colors.pink,
                          trimMode: TrimMode.Line,
                          trimCollapsedText: Resources.from(context, Constant.languageCode).strings.showMore,
                          trimExpandedText: Resources.from(context, Constant.languageCode).strings.showLess,
                          style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.5)),
                        ),

                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                      margin: EdgeInsets.only(bottom: 10),
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
                                            color: Colors.blue,
                                            borderRadius: BorderRadius.circular(60)
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(left: 7,top: 1),
                                        child: Text(
                                            DateFormat('EE, d MMM, yyyy').format(DateTime.parse(sDate)),
                                            style: TextStyle(fontSize: 12, fontFamily: "poppins_regular", color: Colors.black)),
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
                                      color: Colors.grey,
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
                                            color: Colors.grey,
                                            borderRadius: BorderRadius.circular(60)
                                        ),
                                      ),

                                      Container(
                                          margin: EdgeInsets.only(left: 7,top: 1),
                                          child: Text(
                                            DateFormat('EE, d MMM, yyyy').format(DateTime.parse(eDate)),
                                            style: TextStyle(fontSize: 12, fontFamily: "poppins_regular",color: Colors.black.withOpacity(0.7)),
                                          )
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

                    SizedBox(height: 20),

                    ProgressButton(isAccept: this, text: Resources.from(context,
                        Constant.languageCode).strings.accept, formKey:  null, isVisible: true),

                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          );
        }
    );
  }

  setUpButtonChild() {
    if (_state == 0) {
      return Text(
        "Click Here",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      );
    } else if (_state == 1) {
      return SizedBox(
        height: 36,
        width: 36,
        child: CircularProgressIndicator(
          value: null,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else {
      return Icon(Icons.check, color: Colors.white);
    }
  }

  void animateButton() {
    double initialWidth = _globalKey.currentContext.size.width;

    _controller = AnimationController(duration: Duration(milliseconds: 300), vsync: this);

    _animation = Tween(begin: 0.0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {
          _width = initialWidth - ((initialWidth - 48) * _animation.value);
        });
      });
    _controller.forward();

    setState(() {
      _state = 1;
    });

    Timer(Duration(milliseconds: 3300), () {
      setState(() {
        _state = 2;
      });
    });
  }

  showAlertDialog(summary){
    return showDialog(
        context: context,
        builder: (_){
          return AlertDialog(
            title: Text(summary,style: TextStyle(color: Colors.black,fontFamily: "poppins_medium",fontSize: 14),),
            actions: [
              TextButton(
                child: Text(Resources.from(context, Constant.languageCode).strings.okay),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
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
    // Toast toast = Toast();
    // toast.overLay = false;
    // loader = true;
    // toast.showOverLay(message, Colors.white, Colors.black54, context,
    //     seconds: 3);
    Constant.showToast(message, Toast.LENGTH_LONG);
    setState(() {
      isVisible = false;
    });
  }

  @override
  onSuccessRes(response) {
    print("CALENDER_LIST_SUCESS:::::$response");

    setState(() {
      List<dynamic> data = response;
      for (int i = 0; i < data.length; i++) {
        if (data[i]['accessRole'] == "owner") {
          itemList.add(Item.fromJson(data[i]));
          _sharedPreferences.setString(Constant.ITEM_LIST, json.encode(itemList));
        }
      }
    });

    initialLoad = presenter.getCalendarEvent(maxResult: 10,minTime: DateTime.now().toUtc(),isPageToken: false);
    hasMoreItems = true;
  }

  String address;

  Future getLocation(LatLng latLng) async {
    final coordinates = new Coordinates(latLng.latitude, latLng.longitude);
    var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    setState(() {
      address = first.addressLine;
      add.add(first.addressLine);
    });

    print("CALLED::::${first.addressLine}");
    return first.addressLine;
  }

  List<String> add = List.empty(growable: true);

  Map<String, dynamic> map;
  // List<LatLong> addressList = List.empty(growable: true);
  // List<String> full_address = List.empty(growable: true);

  @override
  onEventSuccess(response, calendarResponse) {
    print("success ${response.runtimeType}");


    setState(() {
      map = calendarResponse;
      List<dynamic> data = response;
      print("KFJJFGJDFJFJJ:::::::${data.length}     datatat::::'${data[0]["id"]}    response::::$response");

      ///Add Event Data
      // eventItem.addAll(data.map((e) => EventItem.fromJson(e)).toList());
      // searchEventList.addAll(data.map((e) => EventItem.fromJson(e)).toList());

      ///Only latLong Event
      for(int i=0;i<data.length;i++){
        print("LOCATION:::::${data[i]['location']}");

        if(data[i]['location'] == null){
          print("list_data_get::::::${EventItem.fromJson(data[i])}");
          eventItem.add(EventItem.fromJson(data[i]));
          searchEventList.add(EventItem.fromJson(data[i]));
        }else{
          print("ELSE::::::");
        }
      }
      // print('leghth:::::${eventItem.length}');
      // addressList.clear();
      // for(int i=0;i<data.length;i++){
      //   if(data[i]['location'] != null){
      //     print("------- Enter ------");
      //     var lat;
      //     var lng;
      //     var latlng = data[i]['location'].toString().split(",");
      //     lat = latlng[0];
      //     lng = latlng[1];
      //     addressList.add(LatLong(latitude: double.parse(lat),longitude: double.parse(lng)));
      //     // getLocation(LatLng(double.parse(lat),double.parse(lng)));
      //   }
      // }
    });

    // if(eventItem.length>=3 || eventItem.length>=9){
    //   setState(() {
    //     hasMoreItems = false;
    //   });
    // }

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
    presenter = new HomePresenter(this, token: googleSignInAuthentication.accessToken);
    presenter.attachView(this);
    presenter.getCalendar(googleSignInAuthentication.accessToken);
    eventItem.clear();
    print("get_calenderAPI::::::::::");
    // initialLoad = presenter.getCalendarEvent(maxResult: 10,minTime: DateTime.now().toUtc(),isPageToken: false);
    // hasMoreItems = true;

    return googleSignInAuthentication.accessToken;
  }

  @override
  onCreateEvent(response) {
    print('onSucess:::$response');
    Navigator.pop(context);
    Constant.showToast(Resources.from(context, Constant.languageCode).strings.eventCreateMsg, Toast.LENGTH_SHORT);

    if(isShareAppointment = true){
      presenter.getCalendarEvent(maxResult: 10, isPageToken: false, minTime: DateTime.now().toUtc());
    }
  }

  @override
  onUpdateEvent(response) {
    print('update:::;$response');
    Constant.showToast(Resources.from(context, Constant.languageCode).strings.eventUpdateMsg, Toast.LENGTH_SHORT);
  }

  @override
  onDelete(delete) {
    eventItem.removeWhere((element) => element.id == delete);
    // _isVisible = true;
  }

  @override
  void isAccept(String str, String id, String email) {
    print("Update --->");
    eventItem.clear();
    presenter.setAppointment(summary: str_summary, endDate: str_EndDate, startDate: str_startDate,
        description: str_description, timeZone: str_timeZone);

    setState(() {
      isShareAppointment = true;
    });
  }

}

class PlaceholderItemCard extends StatelessWidget {
  double height;
  final index;
  List<String> full_address = List.empty(growable: true);

  PlaceholderItemCard({Key key, @required this.index, this.height, this.full_address}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: EdgeInsets.only(left: 10, top: 5, right: 10, bottom:5),
      child: Material(
        color: Colors.grey[100],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Shimmer.fromColors(
          child: Padding(
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