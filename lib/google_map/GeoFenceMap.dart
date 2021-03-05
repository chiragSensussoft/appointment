import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:appointment/home/BottomSheet.dart';
import 'package:appointment/home/LoadMore.dart';
import 'package:appointment/home/MyAppointment.dart';
import 'package:appointment/home/OnHomeView.dart';
import 'package:appointment/home/home_view_model.dart';
import 'package:appointment/home/model/CalendarEvent.dart';
import 'package:appointment/home/model/LatLong.dart';
import 'package:appointment/home/presenter/HomePresentor.dart';
import 'package:appointment/utils/values/Constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_geofence/geofence.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;


class GeoFenceMap extends StatefulWidget {
  @override
  GeoFenceMapState createState() => GeoFenceMapState();
}

class GeoFenceMapState extends State<GeoFenceMap> with WidgetsBindingObserver implements OnHomeView, SetMarker, DeleteEvent {
  LatLng _lng;
  Position _currentPosition;
  Completer _controller = Completer();
  GoogleMapController gController;
  List<Marker> _markers = [];
  HomeViewModel model;
  bool isVisible;
  List<LatLong> addressList = List.empty(growable: true);
  List<String> add = List.empty(growable: true);
  List<EventItem> locationEvent =  List.empty(growable: true);
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  HomePresenter presenter;
  FirebaseUser user;
  BitmapDescriptor redPinLocationIcon;
  BitmapDescriptor bluePinLocationIcon;
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
  SharedPreferences _sharedPreferences;
  String accessToken = '';
  PageController _pageViewController;
  List<String> full_address = List.empty(growable: true);

  AppLifecycleState state;


  @override
  void initState() {
    super.initState();
    print("initState:::::::");
    WidgetsBinding.instance.addObserver(this);
    _pageViewController = PageController(initialPage: 0,viewportFraction: 0.8,keepPage: true);
    setCustomMapRedPin();
    setCustomMapBluePin();
    refreshToken();

    initPlatformState();

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var android = AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = IOSInitializationSettings();
    var initSettings = InitializationSettings(android:android,iOS: iOS);
    flutterLocalNotificationsPlugin.initialize(initSettings, onSelectNotification: null);

  }

  @override
  void dispose() {
    print("dispose:::::::");
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /* get state --> onResume */
  void didChangeAppLifecycleState(AppLifecycleState appLifecycleState) {
    state = appLifecycleState;
    print(appLifecycleState);
    print("AppLifecycleState:::::::$state");
  }


  Future<void> initPlatformState() async {
    if (!mounted) return;
    Geofence.initialize();
    Geofence.startListening(GeolocationEvent.entry, (entry) {
      print("Enter");
      scheduleNotification("Entry of a georegion", "Welcome to: ${entry.id}");
    });

    Geofence.startListening(GeolocationEvent.exit, (entry) {
      print("Exit");
      scheduleNotification("Exit of a georegion", "Byebye to: ${entry.id}");
    });

    setState(() {});
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
    _sharedPreferences = await SharedPreferences.getInstance();
    _sharedPreferences.setString(Constant.ACCESS_TOKEN, googleSignInAuthentication.accessToken);
    accessToken = googleSignInAuthentication.accessToken;
    print("Id token 1 ==> $accessToken");

    AuthResult authResult = await _auth.signInWithCredential(credential);
    user = authResult.user;
    Constant.email = user.email;
    Constant.token = googleSignInAuthentication.accessToken;
    presenter = new HomePresenter(this, token: googleSignInAuthentication.accessToken);
    presenter.attachView(this);
    initialLoad = presenter.getCalendarEvent(maxResult: 10,minTime: DateTime.now().toUtc(),isPageToken: false);
    hasMoreItems = true;
    return googleSignInAuthentication.accessToken;
  }

  void scheduleNotification(String title, String subtitle) {
    print("scheduling one with $title and $subtitle");
    Future.delayed(Duration(seconds: 5)).then((result) async {
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
          'your channel id', 'your channel name', 'your channel description',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker');
      var iOSPlatformChannelSpecifics = IOSNotificationDetails(badgeNumber: 1,presentAlert: true,);
      var platformChannelSpecifics = NotificationDetails(
          android:androidPlatformChannelSpecifics,iOS: iOSPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
          0, title, subtitle, platformChannelSpecifics,
          payload: 'item x');
    });
  }


  Future<void> getCurrentLocation() async {
    try {
      // Geolocator geolocator = Geolocator()..forceAndroidLocationManager = true;
      Position position = await Geolocator().getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);

      setState(() async {
        _currentPosition = position;
        _lng = LatLng(_currentPosition.latitude, _currentPosition.longitude);
        _getLocation(_lng);
      });
      return position;

    } catch (err) {
      print(err.message);
    }
  }


  _getLocation(LatLng latLng) async {
    final coordinates = new Coordinates(latLng.latitude, latLng.longitude);
    var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);

    var first = addresses.first;
    print("CALLED::::${first.addressLine}");
  }

  Set<Circle> circle;


  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png)).buffer.asUint8List();
  }

  Future<BitmapDescriptor> getBitmapDescriptorFromAssetBytes(String path, int width) async {
    final Uint8List imageData = await getBytesFromAsset(path, width);
    return BitmapDescriptor.fromBytes(imageData);
  }

  void setCustomMapBluePin() async {
    bluePinLocationIcon = await getBitmapDescriptorFromAssetBytes('images/locationbluePng.png', 60);
  }
  void setCustomMapRedPin() async {
    redPinLocationIcon = await getBitmapDescriptorFromAssetBytes('images/locationRedPng.png', 60);
  }

  bool loadingMore;
  bool hasMoreItems;
  Future initialLoad;
  int lastIndex;

  Future _loadMoreItems() async {
    if(_pageViewController.position.pixels == _pageViewController.position.maxScrollExtent || hasMoreItems == true){
      await presenter.getCalendarEvent(maxResult: 10,minTime: DateTime.now().toUtc(),
          isPageToken: true,pageToken: map['nextPageToken']);
    }
    else{
      hasMoreItems = false;
    }
    hasMoreItems = map['nextPageToken'] != null;
  }

  bool isScroll = false;
  LatLng setLatLng;


  @override
  Widget build(BuildContext context) {
    model = HomeViewModel(geoFenceMapState: this, setMarker: this, deleteEvent: this);

    return Scaffold(
        body: isVisible == false ?  Stack(
          children:[
            GoogleMap(
            initialCameraPosition: CameraPosition(target: LatLng(21.1702,72.8311), zoom: 7),
            markers: Set.of(_markers),
            mapType: MapType.normal,
            myLocationEnabled: true,
              zoomControlsEnabled: false,

            onTap: (p){
            },

            onLongPress: (LatLng latLng){
              // _markers.add(Marker(markerId: MarkerId(Random.secure().nextInt(100).toString()), position: latLng, icon: redPinLocationIcon));

              setState(() {
                setLatLng = latLng;

                Geolocation location = Geolocation(
                    latitude: 21.2050,
                    longitude: 72.8408,
                    radius: 50.0,
                    id: "Surat Railway Station");

                Geofence.addGeolocation(location, GeolocationEvent.entry).then((onValue) {
                  scheduleNotification("Georegion added", "Your geofence has been added!");
                }).catchError((onError) {
                  print("great failure");
                });

                model.openBottomSheetView(isEdit: false, openfrom: "Map", latlng: LatLng(latLng.latitude, latLng.longitude));
              });
            },
            onCameraMove: (p){
              position = p;
            },
            onMapCreated: (GoogleMapController controller) async {
              _controller.complete(controller);
              gController = controller;
              gController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(addressList[0].latitude, addressList[0].longitude),zoom: 7)));
            },
          ),

            Align(
              alignment: Alignment.bottomCenter,
              child:

              // FutureBuilder(
              //       future: initialLoad,
              //       builder: (context, snapshot) {
              //         switch (snapshot.connectionState) {
              //           case ConnectionState.waiting:
              //             return Center(child: CircularProgressIndicator());
              //
              //           case ConnectionState.done:
              //             return Container(
              //               height: 228,
              //               margin: EdgeInsets.only(top: 35, bottom: 20),
              //               decoration: BoxDecoration(
              //                 color: Colors.transparent,
              //                   borderRadius: BorderRadius.only(
              //                       topLeft: Radius.circular(20),
              //                       topRight: Radius.circular(20))),
              //
              //               child: IncrementallyLoadingListView(
              //                 hasMore: () => hasMoreItems,
              //                 itemCount: () => locationEvent.length,
              //                 loadMore: () async {
              //                   await _loadMoreItems();
              //                 },
              //                 onLoadMore: () {
              //                   setState(() {
              //                     loadingMore = true;
              //                   });
              //                 },
              //                 onLoadMoreFinished: () {
              //                   setState(() {
              //                     loadingMore = false;
              //                   });
              //                 },
              //                 controller: _pageViewController,
              //                 loadMoreOffsetFromBottom: 2,
              //                 shrinkWrap: false,
              //                 physics: CustomScrollPhysics(),
              //                 scrollDirection: Axis.horizontal,
              //                 itemBuilder: (context, index) {
              //                   currentIndex = index;
              //                   _pageViewController.addListener(() {
              //                     // print("SCROLL:::::$index");
              //
              //                     setState(() {
              //                       // gController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
              //                       //     target: LatLng(addressList[index].latitude,addressList[index].longitude,),zoom: 10)));
              //                     });
              //
              //
              //                     for(int i=0;i<locationEvent.length??1;i++){
              //                      setState(() {
              //                        _markers[i] = Marker(markerId: MarkerId(locationEvent[i].id), icon: redPinLocationIcon,
              //                            position: LatLng(addressList[i].latitude,addressList[i].longitude));
              //                      });
              //                     }
              //                    setState(() {
              //                      _markers[currentIndex] = Marker(markerId: MarkerId(locationEvent[currentIndex].id), icon: bluePinLocationIcon,
              //                          position: LatLng(addressList[currentIndex].latitude, addressList[currentIndex].longitude));
              //                    });
              //                   });
              //
              //                   /*load more set shimmer view*/
              //                   if ((loadingMore ?? false) && index == locationEvent.length - 1) {
              //                     return Transform.scale(
              //                       scale: 0.9,
              //                       child: Stack(
              //                         children: [
              //                           Row(
              //                             children: <Widget>[
              //                               model.pageView(index),
              //                               PlaceholderItemCard(index: index, height: 228, full_address: full_address)
              //                             ],
              //                           )
              //                         ],
              //                       ),
              //                     );
              //                   }
              //
              //                   /*load more set*/
              //                   return Transform.scale(
              //                       scale: 0.9,
              //                       child: Stack(
              //                         children: [
              //                           Container(
              //                             height:228,
              //                             child: model.pageView(index),
              //                           ),
              //                         ],
              //                       ),
              //                     );
              //                 },
              //               ),
              //             );
              //           default:
              //             return Text('Something went wrong');
              //         }
              //       },
              //     ),


              Visibility(
                visible: addressList.length != 0,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin : EdgeInsets.only(bottom: 25),
                    height: 228,
                    child: PageView.builder(
                      itemCount: locationEvent.length,

                      onPageChanged: (int index){
                        setState(() => currentIndex = index);
                        print("CENTER_POS:::::$index");
                        gController.animateCamera(CameraUpdate.newCameraPosition(
                            CameraPosition(target: LatLng(addressList[index].latitude,addressList[index].longitude),
                                zoom: 7)));

                        setState(() {
                          for(int i=0;i<locationEvent.length;i++){
                            _markers[i] = Marker(markerId: MarkerId(locationEvent[i].id),
                                icon: redPinLocationIcon,
                                position: LatLng(addressList[i].latitude,addressList[i].longitude));
                          }

                          _markers[index] = Marker(markerId: MarkerId(locationEvent[index].id), icon: bluePinLocationIcon,
                              position: LatLng(addressList[index].latitude,addressList[index].longitude));
                        });

                        /*load more*/
                        if ((loadingMore ?? false) && index == locationEvent.length - 1) {
                          model.pageView(index);
                          PlaceholderItemCard(index: index, height: 228, full_address: full_address);
                        }
                      },

                      controller: _pageViewController,
                      itemBuilder: (BuildContext context, int index) {
                        return Transform.scale(
                          scale: index == currentIndex ? 1.03 : 0.9,
                          child: Stack(
                            children: [
                              /*set horizontal card*/
                              Container(
                                child: model.pageView(index),
                              ),
                            ],
                          ),
                        );
                      },

                    ),
                  ),
                ),
              ),
            )
          ]
        )
            : Center(child: CircularProgressIndicator())
    );
  }

  CameraPosition position;

  int currentIndex = null;

  @override
  onCreateEvent(response) {

  }

  @override
  onDelete(delete) {
    print("DELETE::::::::");
  }

  @override
  onErrorHandler(String error) {

  }

  Map<String, dynamic> map;

  @override
  onEventSuccess(response, calendarResponse) {
    print("success ${response.runtimeType}");

    setState(() {
      map = calendarResponse;
      List<dynamic> data = response;
      for(int i=0;i<data.length;i++){
        if(data[i]['location'] != null){
          locationEvent.add(EventItem.fromJson(data[i]));
          print("------- Enter ------${locationEvent.length}");
          var lat;
          var lng;
          var latlobg = data[i]['location'].toString().split(",");
          lat = latlobg[0];
          lng = latlobg[1];
          addressList.add(LatLong(latitude: double.parse(lat),longitude: double.parse(lng)));

          /*load more change condition*/
          // setState(() {
          //   if(i==0){
          //     _markers[0] = Marker(markerId: MarkerId(locationEvent[0].id), icon: bluePinLocationIcon,
          //         position: LatLng(addressList[0].latitude, addressList[0].longitude));
          //
          //   }else{
          //     _markers.add(Marker(markerId: MarkerId(data[i]['id']),position: LatLng(double.parse(lat),double.parse(lng)),
          //         icon: redPinLocationIcon, onTap: (){}));
          //   }
          // });

          setState(() {
            _markers.add(Marker(markerId: MarkerId(data[i]['id']), position: LatLng(double.parse(lat),double.parse(lng)),
                icon: i==0?bluePinLocationIcon:redPinLocationIcon,
                onTap: (){

                }));
          });
        }
      }

      full_address.clear();
      for(int i=0; i<addressList.length; i++){
        getLocation(LatLng(addressList[i].latitude, addressList[i].longitude)).then((value){
          full_address.add(value);
        });
      }
    });

    if(locationEvent.length>=3 || locationEvent.length>=9){
      setState(() {
        hasMoreItems = false;
      });
    }
    print("Length${locationEvent.length}");
  }

  Future getLocation(LatLng latLng) async {
    final coordinates = new Coordinates(latLng.latitude, latLng.longitude);
    var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    setState(() {
      add.add(first.addressLine);
    });

    print("CALLED::::${first.addressLine}");
    return first.addressLine;
  }


  @override
  onHideLoader() {
   setState(() {
     isVisible = false;
   });
  }

  @override
  onShowLoader() {
    setState(() {
      isVisible = true;
    });
  }

  @override
  onSuccessRes(response) {

  }

  @override
  onUpdateEvent(response) {

  }

  @override
  void setmarker() {
    print("SET_MARKERS:::::");
   _markers.add(Marker(markerId: MarkerId(Random.secure().nextInt(100).toString()), position: setLatLng, icon: bluePinLocationIcon));

   locationEvent.clear();
   initialLoad = presenter.getCalendarEvent(maxResult: 10,minTime: DateTime.now().toUtc(),isPageToken: false);
   hasMoreItems = true;
  }

  @override
  void delete_event(String eventID) {
    locationEvent.removeWhere((element) => element.id == eventID);
    setState(() {
      _markers.remove(_markers.firstWhere((Marker marker) => marker.markerId.value == eventID));
    });

    locationEvent.clear();
    _markers.clear();
    presenter = new HomePresenter(this, token: accessToken);
    presenter.attachView(this);
    initialLoad = presenter.getCalendarEvent(maxResult: 10,minTime: DateTime.now().toUtc(),isPageToken: false);
    hasMoreItems = true;
  }

}
