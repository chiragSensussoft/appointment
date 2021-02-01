import 'package:appointment/home/Home.dart';
import 'package:appointment/utils/values/Dimen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeViewModel {
  HomeState state;

  HomeViewModel(this.state);

  detailSheet(index){
    return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: state.context,
        isScrollControlled: true,
        isDismissible: true,
        enableDrag: true,
        // barrierColor: Colors.white,
        shape: RoundedRectangleBorder(
        ),
        builder: (context) {
      return DraggableScrollableSheet(
          initialChildSize: 0.80,
          expand: true,
          builder: (context, scrollController) {
            return Container(
              padding: EdgeInsets.all(Dimen().dp_20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20)),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 Row(
                   children: [
                     Container(
                       child: Text('Event Title :',style: TextStyle(fontSize: 15,fontFamily: "poppins_medium"),),
                     ),
                     Container(
                       margin: EdgeInsets.only(left: 10),
                       child: Text(state.eventItem[index].summary,style: TextStyle(fontSize: 15,fontFamily: "poppins_regular")),
                     )
                   ],
                 ),
                  Row(
                    children: [
                      Container(
                        child: Text('Event Starting Time :',style: TextStyle(fontSize: 15,fontFamily: "poppins_medium"),),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Text(state.eventItem[index].start.dateTime.hour.toString()+":"+state.eventItem[index].start.dateTime.minute.toString(),style: TextStyle(fontSize: 15,fontFamily: "poppins_regular")),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        child: Text('Event Ending Time :',style: TextStyle(fontSize: 15,fontFamily: "poppins_medium"),),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Text(state.eventItem[index].end.dateTime.hour.toString()+":"+state.eventItem[index].end.dateTime.minute.toString(),style: TextStyle(fontSize: 15,fontFamily: "poppins_regular")),
                      )
                    ],
                  )
                ],
              ),
            );
          }
      );
    }
    );
  }

}