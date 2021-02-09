import 'package:appointment/home/BottomSheet.dart';
import 'package:appointment/home/MyAppointment.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'event_calendar.dart';


class HomeViewModel {
  // HomeState state;

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

  openBottomSheetView(){
    return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: state.context,
        isScrollControlled: true,
        isDismissible: true,
        enableDrag: true,
        builder: (context) {
          return DraggableScrollableSheet(
              initialChildSize: 0.80,
              expand: true,
              builder: (context, scrollController) {
                return state.isEventEdit?
                MyBottomSheet(token: state.access_token, list: state.list, itemList: state.itemList, isEdit: true):
                 MyBottomSheet(token: state.access_token, list: state.list, itemList: state.itemList, isEdit: false);
              });
        }).whenComplete(() => {state.presenter.getCalendarEvent()});
  }

}