import 'package:appointment/home/MyAppointment.dart';
import 'package:appointment/home/OtherAppointment.dart';
import 'package:appointment/home/home_view_model.dart';
import 'package:appointment/utils/DBProvider.dart';
import 'package:appointment/utils/values/Palette.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';


class LifecycleEventHandler extends WidgetsBindingObserver {
  final AsyncCallback resumeCallBack;
  final AsyncCallback suspendingCallBack;

  LifecycleEventHandler({
    this.resumeCallBack,
    this.suspendingCallBack,
  });

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        if (resumeCallBack != null) {
          await resumeCallBack();
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        if (suspendingCallBack != null) {
          await suspendingCallBack();
        }
        break;
    }
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home>{
  HomeViewModel model;
  final dbHelper = DatabaseHelper.instance;
  var data;
  String url;
  String userName;
  String email;
  bool visibility = true;

  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(
        LifecycleEventHandler(resumeCallBack: () async => setState(() {
          print('CALLED::::');
        }))
    );
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.resumed){
      _query();
    }
  }

  _query() async {
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

    url = result[0]['photoUrl'];
    userName = result[0]['fName'];
    email = result[0]['email'];

    print('get_name:::::$userName   email::$email');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Palette.colorPrimary,
            automaticallyImplyLeading: false,
            title: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    url != null ?CircleAvatar(
                      backgroundImage: NetworkImage(url,),
                    ):Image.asset('images/ic_defult.png',fit: BoxFit.contain,height: 32),

                    Container(
                      margin: EdgeInsets.only(left: 10,right: 10),
                      child:Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              child: Text(userName??"Default User",style: TextStyle(fontSize: 17))
                          ),
                          Container(
                              child: Text(email??"",style: TextStyle(fontSize: 12))
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Container(
                  child: Icon(Icons.settings,size: 30,),
                )
              ],
            )
        ),

        body: DefaultTabController(
          length: 2,
          child: Container(

            // child: RefreshIndicator(
            //     child: Container(
            //   color: Colors.grey[200],
            //   child: isVisible == false ?eventItem.length != 0?
            //
            //   ListView.builder(
            //     itemCount: eventItem.length,
            //     itemBuilder: (_,index){
            //       return Padding(
            //         padding: EdgeInsets.all(5),
            //         child: GestureDetector(
            //           onTap: (){
            //             model.detailSheet(index);
            //           },
            //           child: Dismissible(
            //             key: Key(eventItem[index].description),
            //             direction: DismissDirection.endToStart,
            //             // onDismissed: (direction){
            //             // },
            //             confirmDismiss: (DismissDirection dismissDirection) async {
            //               switch(dismissDirection) {
            //                 case DismissDirection.endToStart:
            //                 // whatHappened = 'ARCHIVED';
            //                   return await _showConfirmationDialog(context, 'Archive',index) == true;
            //                 case DismissDirection.startToEnd:
            //                 // whatHappened = 'DELETED';
            //                   return await _showConfirmationDialog(context, 'Delete',index) == true;
            //                 case DismissDirection.horizontal:
            //                 case DismissDirection.vertical:
            //                 case DismissDirection.up:
            //                 case DismissDirection.down:
            //                   assert(false);
            //               }
            //               return false;
            //             },
            //             child: Material(
            //               elevation: 1,
            //               shape: RoundedRectangleBorder(
            //                   borderRadius: BorderRadius.circular(10)
            //               ),
            //               child: Container(
            //                   // height: 120,
            //                   padding: EdgeInsets.only(top: 8,bottom: 8,left: 18,right: 18),
            //                   child: Row(
            //                     mainAxisSize: MainAxisSize.min,
            //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                     crossAxisAlignment: CrossAxisAlignment.center,
            //                     children: [
            //                       Expanded(
            //                         child: Column(
            //                           mainAxisSize: MainAxisSize.min,
            //                           crossAxisAlignment: CrossAxisAlignment.start,
            //                           mainAxisAlignment: MainAxisAlignment.center,
            //                           children: [
            //                             Row(
            //                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                                 children:[
            //                                   Expanded(
            //                                     child: Column(
            //                                       children: [
            //                                         Container(
            //                                           margin: EdgeInsets.only(top: 5),
            //                                           child: Text("Summary",style: TextStyle(fontSize: 14,fontFamily: "poppins_medium"),),
            //                                         ),
            //                                         Container(child: Text(eventItem[index].summary.toString(),style: TextStyle(fontSize: 14,fontFamily: "poppins_regular")),),
            //                                         Container(
            //                                           margin: EdgeInsets.only(top: 5),
            //                                           child: Text('Description',style: TextStyle(fontSize: 14,fontFamily: "poppins_medium")),
            //                                         ),
            //                                         Container(
            //                                           child: Text(eventItem[index].description!=null?eventItem[index].description:"",style: TextStyle(fontSize: 14,fontFamily: "poppins_regular")),
            //                                         ),
            //                                       ],
            //                                       crossAxisAlignment: CrossAxisAlignment.start,
            //                                     ),
            //                                     flex: 8,
            //                                   ),
            //
            //                                   Expanded(
            //                                     flex: 3,
            //                                     child: Column(
            //                                       crossAxisAlignment: CrossAxisAlignment.start,
            //                                       children: [
            //                                         Container(
            //                                           margin: EdgeInsets.only(top: 5),
            //                                           child:Text('From',style: TextStyle(fontSize: 14,fontFamily: "poppins_medium"),),
            //                                         ),
            //                                         Container(
            //                                           child: Text(DateFormat('EE, d MMM, yyyy').format(eventItem[index].start.dateTime.toLocal())
            //                                               +"  "+eventItem[index].start.dateTime.toLocal().hour.toString()+":"+eventItem[index].start.dateTime.toLocal().minute.toString()
            //                                               ,style: TextStyle(fontSize: 14,fontFamily: "poppins_regular")),),
            //                                         Container(
            //                                           margin: EdgeInsets.only(top: 5),
            //                                           child:Text('To',style: TextStyle(fontSize: 14,fontFamily: "poppins_medium"),),
            //                                         ),
            //                                         Container(
            //                                           child: Text(DateFormat('EE, d MMM, yyyy').format(eventItem[index].end.dateTime.toLocal())
            //                                               +"  "+eventItem[index].end.dateTime.toLocal().hour.toString()+":"+eventItem[index].end.dateTime.toLocal().minute.toString()
            //                                               ,style: TextStyle(fontSize: 14,fontFamily: "poppins_regular")),),
            //                                       ],
            //                                     ),
            //                                   )
            //                                 ]
            //                             ),
            //
            //                           ],
            //                         ),
            //                       ),
            //                     ],
            //                   )
            //               ),
            //
            //             ),
            //           ),
            //         ),
            //       );
            //     },
            //   ):Center(child: Text("No Event Created"),):
            //   Center(
            //     child: CircularProgressIndicator(),),
            //   ),
            //     onRefresh:(){
            //   print('onrefresh::::$access_token');
            //   return _presenter.getCalendarEvent(access_token);
            // }
            // ),

            child: Column(
              children: [
                Container(
                  color: Colors.grey.withOpacity(0.1),
                  child: TabBar(
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(color: Palette.colorPrimary, width: 2.0),
                      insets: EdgeInsets.fromLTRB(45.0, 0.0, 45.0, 0.0),
                    ),

                    tabs: [
                      Padding(
                          padding: EdgeInsets.all(12),
                          child: Text("My Appointment", style: TextStyle(fontSize: 14, fontFamily: 'poppins_medium', color: Palette.colorPrimary))
                      ),

                      Padding(
                          padding: EdgeInsets.all(12),
                          child: Text("Other Appointment", style: TextStyle(fontSize: 14, fontFamily: 'poppins_medium', color: Palette.colorPrimary))
                      ),
                    ],
                  ),
                ),

                Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30), topRight: Radius.circular(30)), color: Colors.white
                      ),

                      child: TabBarView(
                        children: [
                          MyAppointment(),
                          OtherAppointment(),
                        ],
                      ),
                    )
                )
              ],
            ),
          ),
        ),
    );
  }
}
