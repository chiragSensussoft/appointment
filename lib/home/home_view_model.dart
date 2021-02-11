import 'package:appointment/home/BottomSheet.dart';
import 'package:appointment/home/MyAppointment.dart';
import 'package:appointment/utils/expandable_text.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/DescriptionTextWidget.dart';
import '../utils/slide_menu.dart';
import '../utils/values/Constant.dart';
import 'event_calendar.dart';


class HomeViewModel implements IsCreatedOrUpdate {
  bool isCreateUpdate = false;

  MyAppointmentState state;

  HomeViewModel(this.state);

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
            child:  EventCalendar(eventItem: state.eventItem,dateTime: index,),
      );
    }
    );
  }


  openBottomSheetView({String summary, String description, DateTime startDate,
    DateTime endDate, String timeZone, bool isEdit, String eventID}){

    return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: state.context,
        isScrollControlled: true,
        isDismissible: true,

        builder: (context) {
          return DraggableScrollableSheet(
              initialChildSize: 0.80,
              expand: true,

              builder: (context, scrollController) {
                return isEdit?
                MyBottomSheet(token: state.access_token, list: state.list, itemList: state.itemList, isEdit: true,
                title: summary, description: description, getStartDate: startDate, getendDate: endDate,
                  timeZone: timeZone, eventID: eventID, isCreatedOrUpdate: this):

                 MyBottomSheet(token: state.access_token, list: state.list, itemList: state.itemList, isEdit: false,
                 isCreatedOrUpdate: this);
              });
        })
        .whenComplete(() => {
       /*add condition*/
       if(isCreateUpdate){
         state.eventItem.clear(),
         state.presenter.getCalendarEvent(maxResult: 10,currentTime: DateTime.now().toUtc(),isPageToken: false),
         state.setState(() {
           state.hasMoreItems = true;
         }),
       }
    });
  }

  slideMenu(index) {
    return SlideMenu(
      child: Padding(
        padding: EdgeInsets.only(left: 10, top: 5, right: 10, bottom:5),
        child: GestureDetector(
          onTap: () async {
            detailSheet(state.eventItem[index].start.dateTime);

            print('getStart:::::${Constant.getFullDateFormat(state.eventItem[index].start.dateTime)}');

            state.dynamicLink = await state.createDynamicLink(
                title: state.eventItem[index].summary,
                desc: state.eventItem[index].description,
                startDate: Constant.getFullDateFormat(state.eventItem[index].start.dateTime),
                endDate: Constant.getFullDateFormat(state.eventItem[index].end.dateTime),
                email: state.email,
                photoUrl: state.url,
                senderName: state.userName,
                timeZone: state.eventItem[index].start.timeZone);
            print("Dynamic Link: $state.dynamicLink");
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
                          Container(child: Text(state.eventItem[index].summary.toString(), style: TextStyle(color: Colors.black,fontSize: 14, fontFamily: "poppins_medium")),),
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
                                        isEdit: true, eventID: state.eventItem[index].id);
                                  },
                                ),
                                GestureDetector(
                                  child: Padding(
                                      padding:EdgeInsets.only(left:10),
                                      child: Icon(Icons.share_rounded,size: 20, color: Colors.black.withOpacity(0.5))
                                  ),
                                  onTap: ()async{
                                      // state.showShareDialog(state.context, "Share", index);
                                    state.dynamicLink = await state.createDynamicLink(
                                        title: state.eventItem[index].summary,
                                        desc: state.eventItem[index].description,
                                        startDate: Constant.getFullDateFormat(state.eventItem[index].start.dateTime),
                                        endDate: Constant.getFullDateFormat(state.eventItem[index].end.dateTime),
                                        email: state.email,
                                        photoUrl: state.url,
                                        senderName: state.userName,
                                        timeZone: state.eventItem[index].start.timeZone);

                                    print("Dynamic Link: $state.dynamicLink");

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
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.only(left: 15, right: 15),
                      child: state.eventItem[index].description != null ?  DescriptionTextWidget(text: state.eventItem[index].description) :Text("", style: TextStyle(fontSize: 13, fontFamily: "poppins_regular", color: Colors.black.withOpacity(0.5))),
                      // child: ExpandableText(text: "You should make an appointment by calling or by email. Do not try to make appointments by text, unless you are simply asking a good friend if they would like to have lunch. When making an appointment you should give the person your name and the reason for wanting an appointment.",),
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
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius: BorderRadius.circular(60)
                                        ),
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

      menuItems: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 5, bottom: 5),
          child: GestureDetector(
            onTap: (){
              state.showConfirmationDialog(state.context, 'Delete', index);
            },
            
            child: Container(
              alignment: Alignment.center,
              height: MediaQuery.of(state.context).size.height,
              width: 10,
              color: Colors.red,

              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  IconButton(
                    icon: Icon(Icons.delete_forever_sharp,color: Colors.white),
                    onPressed: () {},
                  ),
                  Flexible(child: Text("Delete", style: TextStyle(fontSize: 12, fontFamily: 'poppins_regular', color: Colors.white)))
                ],
              ),
            ),
          ),
        ),
        // ),
      ],
    );
  }

  @override
  onCreatUpdate(bool bool) {
    isCreateUpdate = bool;
    print('isCreateUpdtae::::$bool   $isCreateUpdate');
  }
}

class PlaceholderItemCard extends StatelessWidget {
  const PlaceholderItemCard({Key key, @required this.item}) : super(key: key);

  final ItemList item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300],
          highlightColor: Colors.grey[100],
          child: Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 60.0,
                    height: 60.0,
                    color: Colors.white,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 0.0),
                    child: Container(
                      color: Colors.white,
                      child: Text(
                        item.name,
                        style: TextStyle(color: Colors.transparent),
                      ),
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
                child: Container(
                  color: Colors.white,
                  child: Text(
                    item.message,
                    style: TextStyle(color: Colors.transparent),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}


class ItemList {
  final String name;
  final String avatarUrl = 'http://via.placeholder.com/60x60';
  final String message =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';

  ItemList(this.name);
}
