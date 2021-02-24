import 'dart:async';
import 'dart:math';
import 'package:appointment/home/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofence/geofence.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class GeoFenceMap extends StatefulWidget {
  @override
  GeoFenceMapState createState() => GeoFenceMapState();
}

class GeoFenceMapState extends State<GeoFenceMap> {
  LatLng _lng;
  Position _currentPosition;
  Completer _controller = Completer();
  Set<Marker> _markers = {};
  HomeViewModel model;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();

    initPlatformState();

    var initializationSettingsAndroid =
    new AndroidInitializationSettings('@mipmap/ic_launcher');
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var android = AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = IOSInitializationSettings();
    // var initializationSettingsIOS =
    //     IOSInitializationSettings(onDidReceiveLocalNotification: null);
    var initSettings = InitializationSettings(android:android,iOS: iOS);
    flutterLocalNotificationsPlugin.initialize(initSettings,
        onSelectNotification: null);

  }

  Future<void> initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
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
      Geolocator geolocator = Geolocator()..forceAndroidLocationManager = true;
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


  @override
  Widget build(BuildContext context) {
    model = HomeViewModel(geoFenceMapState: this);

    return Scaffold(
        body:  GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(21.2050,72.8408), zoom: 3),
          markers: _markers,
          mapType: MapType.normal,
          myLocationEnabled: true,

          onLongPress: (LatLng latLng){
            _markers.add(Marker(markerId: MarkerId('mark'), position: latLng));
            setState(() {
              // _getLocation(LatLng(latLng.latitude, latLng.longitude));

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
          onMapCreated: (GoogleMapController controller) async {
            _controller.complete(controller);
            setState(() {
              _markers.add(Marker(markerId: MarkerId("location"),
                position: _lng, infoWindow: InfoWindow(title: "home"),
              ));
            });
          },
        )
            // : Center(child: CircularProgressIndicator())
    );
  }

}
