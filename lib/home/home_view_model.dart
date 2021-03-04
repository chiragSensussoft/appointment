import 'package:appointment/google_map/GeoFenceMap.dart';
import 'package:appointment/home/model/LatLong.dart';
import 'package:appointment/home/presenter/HomePresentor.dart';
import 'package:appointment/interface/IsCreatedOrUpdate.dart';
import 'package:appointment/utils/expand_text.dart';
import 'package:appointment/home/BottomSheet.dart';
import 'package:appointment/home/MyAppointment.dart';
import 'package:appointment/utils/values/Strings/Strings.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import '../utils/values/Constant.dart';
import 'Home.dart';
import 'event_calendar.dart';


abstract class SetMarker{
  void setmarker();
}


class HomeViewModel implements IsCreatedOrUpdate, DeleteEvent {
  bool isCreateUpdate = false;

  MyAppointmentState state;
  HomeState homestate;
  GeoFenceMapState geoFenceMapState;
  bool isVisible;
  SetMarker setMarker;
  DeleteEvent deleteEvent;

  HomeViewModel({this.state, this.homestate, this.geoFenceMapState, this.setMarker, this.deleteEvent});

  detailSheet(index){
    return showModalBottomSheet(
        context: state.context,
        backgroundColor: Colors.white,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topRight: Radius.circular(20),topLeft: Radius.circular(20))
        ),
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            margin: EdgeInsets.only(top: 20),
            child:  EventCalendar(eventItem: state.eventItem, dateTime: index),
          );
        }
    );
  }


  openBottomSheetView({String summary, String description, DateTime startDate,
    DateTime endDate, String timeZone, bool isEdit, String eventID, String calenderId,
    LatLng latlng, String openfrom, String address}){
    print("OPENFROM:::::$openfrom");

    return !isEdit?
    openfrom=="Home"?
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: homestate.context,
        isScrollControlled: true,
        isDismissible: true,

        builder: (context) {
          return DraggableScrollableSheet(
              initialChildSize: 0.80,
              expand: true,

              builder: (context, scrollController) {
                return MyBottomSheet(isEdit: false, isCreatedOrUpdate: this, isDelete: false);
              });
        }).whenComplete(() => {
      if(isCreateUpdate){
        print("HOME:::MADE:::::"),
        state.eventItem.clear(),
        state.presenter.getCalendarEvent(maxResult: 10, minTime: DateTime.now().toUtc(),
            isPageToken: false, pageToken: state.map['nextPageToken']),
        state.setState(() {
          state.hasMoreItems = true;
        }),
      }
    })

    : showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: geoFenceMapState.context,
        isScrollControlled: true,
        isDismissible: true,

        builder: (context) {
          return DraggableScrollableSheet(
              initialChildSize: 0.80,
              expand: true,
              builder: (context, scrollController) {
                //Map LatLng
                return MyBottomSheet(isEdit: false, isCreatedOrUpdate: this, latLng: latlng, isDelete: false);
              });
        }).whenComplete(() => {

      /*add condition*/
      if(isCreateUpdate){
        geoFenceMapState.locationEvent.clear(),
        geoFenceMapState.presenter.getCalendarEvent(maxResult: 10,minTime: DateTime.now().toUtc(),
            isPageToken: false, pageToken: state.map['nextPageToken']),
        geoFenceMapState.setState(() {
        geoFenceMapState.hasMoreItems = true;
        }),
      }
    })

    //Edit
        :
        /*Edit from home*/
    openfrom == "Home"?
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: state.context,
        isScrollControlled: true,
        isDismissible: true,

        builder: (context) {
          return DraggableScrollableSheet(
              initialChildSize: 0.80,
              expand: true,
              builder: (context, scrollController) {
                return MyBottomSheet(isEdit: true, address: address,
                    title: summary, description: description, getStartDate: startDate, getendDate: endDate,
                    timeZone: timeZone, eventID: eventID, isCreatedOrUpdate: this, calenderId: null, isDelete: false,
                    deleteEvent: this);
              });
        })

        .whenComplete(() => {
      /*add condition*/
      if(isCreateUpdate){
        print("Edit"),
        state.eventItem.clear(),
        state.presenter.getCalendarEvent(maxResult: 10,minTime: DateTime.now().toUtc(),isPageToken: false, pageToken: state.map['nextPageToken']),
        state.setState(() {
          state.hasMoreItems = true;
        }),
      }
    })
        :

        /*edit from Geo Fence*/
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: geoFenceMapState.context,
        isScrollControlled: true,
        isDismissible: true,

        builder: (context) {
          return DraggableScrollableSheet(
              initialChildSize: 0.80,
              expand: true,
              builder: (context, scrollController) {
                return MyBottomSheet(isEdit: true, address: address,
                    title: summary, description: description, getStartDate: startDate, getendDate: endDate,
                    timeZone: timeZone, eventID: eventID, isCreatedOrUpdate: this, calenderId: null,
                    isDelete: false, deleteEvent: this);
              });
        })

        .whenComplete(() => {
      /*add condition*/
      if(isCreateUpdate){
        print("Edit"),
        geoFenceMapState.locationEvent.clear(),
        geoFenceMapState.presenter.getCalendarEvent(maxResult: 10,minTime: DateTime.now().toUtc(),isPageToken: false, pageToken: state.map['nextPageToken']),
        geoFenceMapState.setState(() {
          geoFenceMapState.hasMoreItems = true;
        }),
      }
    });
  }

  /*swipe to delete*/
  slideMenu(index) {
    return Dismissible(
      direction: DismissDirection.endToStart,
      key: Key(state.eventItem[index].id),

      // ignore: missing_return
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          final bool res = await showDialog(
              context: state.context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: Text(Resources.from(context, Constant.languageCode).strings.conformDelete,
                      style: TextStyle(fontSize: 14, fontFamily: "poppins_regular")),
                  actions: <Widget>[
                    FlatButton(
                      child: Text(
                        Resources.from(context, Constant.languageCode).strings.no,
                        style: TextStyle(color: Colors.blue),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    FlatButton(
                      child: Text(
                        Resources.from(context, Constant.languageCode).strings.yes,
                        style: TextStyle(color: Colors.blue),
                      ),
                      onPressed: () {
                        state.setState(() {
                          state.presenter.deleteEvent(state.eventItem[index].id, state.eventItem[index].creator.email);
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              });
          return res;
        }
      },

      background: Container(
        margin: EdgeInsets.only(top: 5,bottom: 5,left: 10,right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.red,
        ),
        alignment: AlignmentDirectional.centerStart,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete,
              color: Colors.white,
            ),
            SizedBox(width: 10),
            Text('Delete', style: TextStyle(fontSize: 14, color: Colors.white)),
            // SizedBox(width: 30),
          ],
        ),
      ),

      child: Padding(
        padding: EdgeInsets.only(left: 10, top: 5, right: 10, bottom:5),
        child: GestureDetector(
          onTap: () async {
            detailSheet(state.eventItem[index].start.dateTime);

            // state.dynamicLink = await state.createDynamicLink(
            //     title: state.eventItem[index].summary,
            //     desc: state.eventItem[index].description,
            //     startDate: Constant.getFullDateFormat(state.eventItem[index].start.dateTime),
            //     endDate: Constant.getFullDateFormat(state.eventItem[index].end.dateTime),
            //     email: state.email,
            //     photoUrl: state.url,
            //     senderName: state.userName,
            //     timeZone: state.eventItem[index].start.timeZone);
            // print("Dynamic Link: $state.dynamicLink");
          },

          child: Material(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),

            child: Container(
                width: MediaQuery.of(state.context).size.width,
                padding: EdgeInsets.only(top: 8, bottom: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    SizedBox(height: 5),
                    Container(
                      padding: EdgeInsets.only(left: 15, right: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(child: Text(state.eventItem[index].summary.toString(),
                                style: TextStyle(color: Colors.black, fontSize: 14,
                                    fontFamily: "poppins_medium"))),
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

                                  onTap: (){
                                    openBottomSheetView(description: state.eventItem[index].description,
                                        summary: state.eventItem[index].summary, startDate: state.eventItem[index].start.dateTime,
                                        timeZone: state.eventItem[index].start.timeZone, endDate: state.eventItem[index].end.dateTime,
                                        isEdit: true, eventID: state.eventItem[index].id, calenderId: null,
                                        latlng: LatLng(21.170240, 72.831062), openfrom: "Edit", address: state.eventItem[index].location);
                                  },
                                ),
                                GestureDetector(
                                  child: Padding(
                                      padding:EdgeInsets.only(left:10),
                                      child: Icon(Icons.share_rounded,size: 20, color: Colors.black.withOpacity(0.5))
                                  ),

                                  onTap: ()async{
                                    state.dynamicLink = await state.createDynamicLink(
                                        title: state.eventItem[index].summary,
                                        desc: state.eventItem[index].description,
                                        startDate: Constant.getFullDateFormat(state.eventItem[index].start.dateTime.toLocal()),
                                        endDate: Constant.getFullDateFormat(state.eventItem[index].end.dateTime.toLocal()),
                                        email: state.email,
                                        photoUrl: state.url,
                                        senderName: state.userName,
                                        timeZone: state.eventItem[index].start.timeZone);

                                    print("Dynamic Link: ${state.dynamicLink}    "
                                        "startData:::${state.eventItem[index].start.dateTime.toLocal()}");

                                    if (state.dynamicLink != "") {
                                      Share.share(state.dynamicLink.toString());
                                    }
                                  },
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 3),

                    Divider(
                      color: Colors.grey,
                      thickness: 0.3,
                      height: 0.3,
                    ),

                    Visibility(
                      visible: state.eventItem[index].description!= null,
                      child: Container(
                        padding: EdgeInsets.only(left: 15, right: 15, top: 10),
                        child: ReadMoreText(
                          state.eventItem[index].description??" ",
                          trimLines: 3,
                          colorClickableText: Colors.pink,
                          trimMode: TrimMode.Line,
                          trimCollapsedText: Resources.from(state.context, Constant.languageCode).strings.showMore,
                          trimExpandedText: Resources.from(state.context, Constant.languageCode).strings.showLess,
                          style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.5)),
                        ),
                      ),
                    ),


                    Visibility(
                      visible: state.eventItem[index].location!= null,
                      child: Container(
                        // margin: EdgeInsets.only(),
                        padding: EdgeInsets.only(left: 10, top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
                            SizedBox(width: 3),
                            // Expanded(child: Text(state.add[index]??"",
                            //     style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.5))))
                            Expanded(child: Text(state.eventItem[index].location??"",
                                style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.5))))
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 10),

                    Container(
                      margin: EdgeInsets.only(left: 15,bottom: 10),
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
                                        decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(60)),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(left: 7,top: 1),
                                        child: Text(
                                            DateFormat('EE, d MMM, yyyy').format(state.eventItem[index].start.dateTime.toLocal()) + "  " +
                                                Constant.getTimeFormat(state.eventItem[index].start.dateTime.toLocal()),
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
                                            DateFormat('EE, d MMM, yyyy').format(state.eventItem[index].end.dateTime.toLocal()) + "  " +
                                                Constant.getTimeFormat(state.eventItem[index].end.dateTime.toLocal()),
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
                  ],
                )
            ),
          ),
        ),
      ),
    );
  }

  pageView(index){
    return Material(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),

      child: Container(
        height: 228,
          width: MediaQuery.of(geoFenceMapState.context).size.width,
          padding: EdgeInsets.only(top: 8, bottom: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              SizedBox(height: 5),
              Container(
                padding: EdgeInsets.only(left: 15, right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        child: Text(geoFenceMapState.locationEvent[index].summary.toString(),
                          style: TextStyle(color: Colors.black, fontSize: 12,
                              fontFamily: "poppins_medium"))
                      ),
                    ),
                    Container(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            child: Padding(
                                // padding: EdgeInsets.only(left: 30),
                              padding: EdgeInsets.all(10),
                                child: Icon(Icons.edit_outlined,size: 30, color: Colors.black.withOpacity(0.5))),

                            onTap: (){
                              print("isEdit:::");
                                  showModalBottomSheet(
                                      backgroundColor: Colors.transparent,
                                      context: geoFenceMapState.context,
                                      isScrollControlled: true,
                                      isDismissible: true,

                                      builder: (context) {
                                        return DraggableScrollableSheet(
                                            initialChildSize: 0.80,
                                            expand: true,
                                            builder: (context, scrollController) {
                                              return MyBottomSheet(isEdit: true, address: geoFenceMapState.locationEvent[index].location,
                                                  title: geoFenceMapState.locationEvent[index].summary,
                                                  description: geoFenceMapState.locationEvent[index].description,
                                                  getStartDate: geoFenceMapState.locationEvent[index].start.dateTime,
                                                  getendDate: geoFenceMapState.locationEvent[index].end.dateTime,
                                                  timeZone: geoFenceMapState.locationEvent[index].start.timeZone,
                                                  eventID: geoFenceMapState.locationEvent[index].id, isCreatedOrUpdate: this,
                                                  calenderId: geoFenceMapState.locationEvent[index].summary, isDelete: true, deleteEvent: this);
                                            });
                                      })

                                      .whenComplete(() => {
                                    /*add condition*/
                                    if(isCreateUpdate){
                                      print("OnBACK:::::::::"),
                                      geoFenceMapState.locationEvent.clear(),
                                      geoFenceMapState.presenter.getCalendarEvent(maxResult: 10,minTime: DateTime.now().toUtc(),isPageToken: false, pageToken: state.map['nextPageToken']),
                                      geoFenceMapState.setState(() {
                                        geoFenceMapState.hasMoreItems = true;
                                      }),
                                    }
                                  });
                            },
                          ),
                          GestureDetector(
                            child: Padding(
                                padding:EdgeInsets.only(left:10),
                                child: Icon(Icons.share_rounded, size: 20, color: Colors.black.withOpacity(0.5))
                            ),

                            onTap: ()async{
                              // state.dynamicLink = await state.createDynamicLink(
                              //     title: geoFenceMapState.locationEvent[index].summary,
                              //     desc: geoFenceMapState.locationEvent[index].description,
                              //     startDate: Constant.getFullDateFormat(geoFenceMapState.locationEvent[index].start.dateTime.toLocal()),
                              //     endDate: Constant.getFullDateFormat(geoFenceMapState.locationEvent[index].end.dateTime.toLocal()),
                              //     email: geoFenceMapState.email,
                              //     photoUrl: geoFenceMapState.url,
                              //     senderName: geoFenceMapState.userName,
                              //     timeZone: geoFenceMapState.eventItem[index].start.timeZone);

                              // print("Dynamic Link: ${state.dynamicLink}    "
                              //     "startData:::${state.eventItem[index].start.dateTime.toLocal()}");

                              // if (state.dynamicLink != "") {
                              //   Share.share(state.dynamicLink.toString());
                              // }
                            },
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),

              SizedBox(height: 3),

              Divider(
                color: Colors.grey,
                thickness: 0.3,
                height: 0.3,
              ),

              Visibility(
                visible: geoFenceMapState.locationEvent[index].description!= null,
                child: Container(
                  padding: EdgeInsets.only(left: 15, right: 15, top: 10),
                  child: ReadMoreText(
                    geoFenceMapState.locationEvent[index].description??" ",
                    trimLines: 3,
                    colorClickableText: Colors.pink,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: Resources.from(geoFenceMapState.context, Constant.languageCode).strings.showMore,
                    trimExpandedText: Resources.from(geoFenceMapState.context, Constant.languageCode).strings.showLess,
                    style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.5)),
                  ),
                ),
              ),
              
              Visibility(
                visible: geoFenceMapState.locationEvent[index].location!= null,
                child: Container(
                  padding: EdgeInsets.only(left: 10, top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
                      SizedBox(width: 3),
                      Expanded(child: Text(geoFenceMapState.full_address.length!=0?geoFenceMapState.full_address[index]:"",
                          style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.5))))
                    ],
                  ),
                ),
              ),

              SizedBox(height: 10),

              Container(
                margin: EdgeInsets.only(left: 15,bottom: 10),
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
                                  decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(60)),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 7,top: 1),
                                  child: Text(
                                      DateFormat('EE, d MMM, yyyy').format(geoFenceMapState.locationEvent[index].start.dateTime.toLocal()) + "  " +
                                          Constant.getTimeFormat(geoFenceMapState.locationEvent[index].start.dateTime.toLocal()),
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
                                      DateFormat('EE, d MMM, yyyy').format(geoFenceMapState.locationEvent[index].end.dateTime.toLocal()) + "  " +
                                          Constant.getTimeFormat(geoFenceMapState.locationEvent[index].end.dateTime.toLocal()),
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
            ],
          )
      ),
    );
  }

  var address;
  Future<String> getLocation(double latitude, double longitude) async {
    final coordinates = new Coordinates(latitude, longitude);
    var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    // geoFenceMapState.setState(() {
    //   address = first.addressLine;
    // });

    return first.addressLine;
  }


  @override
  onCreateUpdate(bool bool) {
    isCreateUpdate = bool;
    print('isCreateUpdtae::::$isCreateUpdate');
    if(bool){
      setMarker.setmarker();
    }
  }

  @override
  void delete_event(String eventId) {
    print("DELEELEELLEELLE:::::");
    deleteEvent.delete_event(eventId);
  }
}