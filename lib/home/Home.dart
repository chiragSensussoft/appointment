import 'dart:io';

import 'package:appointment/home/model/CalendarEvent.dart';
import 'package:appointment/home/presenter/HomePresentor.dart';
import 'package:appointment/utils/DBProvider.dart';
import 'package:appointment/utils/RoundShapeButton.dart';
import 'package:appointment/utils/Toast.dart';
import 'package:appointment/utils/values/Constant.dart';
import 'package:appointment/utils/values/Dimen.dart';
import 'package:appointment/utils/values/Palette.dart';
import 'package:appointment/home/BottomSheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:sqflite/sqflite.dart';

import 'OnHomeView.dart';
import 'detail_screen/DetailScreen.dart';
import 'model/CalendarList.dart';

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
  final String name;
  String accessToken;


  Home({this.name,this.accessToken});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> implements OnHomeView{
  final dbHelper = DatabaseHelper.instance;
  var data;
  String url;
  String userName;
  String email;
  bool visibility = true;

  List<Item> _list = List.empty(growable: true);
  List<Item> itemList = List.empty(growable: true);
  List<EventItem> eventItem = List.empty(growable: true);

  HomePresenter _presenter;
  bool isVisible;
  @override
  void initState() {
    super.initState();
    _query();
    _presenter = new HomePresenter(this,token: widget.accessToken,);
    _presenter.attachView(this);
    _presenter.getCalendar();
    _presenter.getCalendarEvent();
    
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Palette.colorPrimary,
        automaticallyImplyLeading: false,
          title: new Row
            (
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:
            [
             Row(
               children: [
                 url != null ?CircleAvatar(
                   backgroundImage: NetworkImage(url,),
                 ):Image.asset('images/ic_defult.png',fit: BoxFit.contain,height: 32,),

                Container(
                  margin: EdgeInsets.only(left: 10,right: 10),
                  child:Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          child: Text(userName??"Default User",style: TextStyle(fontSize: 17),)
                      ),
                      Container(
                          child: Text(email??"",style: TextStyle(fontSize: 12),)
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
      body: RefreshIndicator(child: Container(
        color: Colors.grey[200],
        child: isVisible == false ?ListView.builder(
          itemCount: eventItem.length,
          itemBuilder: (_,index){
            return Padding(
              padding: EdgeInsets.all(5),
              child: Material(
                elevation: 2,
                shadowColor: Colors.white.withOpacity(0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),

                child: GestureDetector(
                  onTap: (){
                    showModalBottomSheet(
                        backgroundColor: Colors.transparent,
                        context: context,
                        isScrollControlled: true,
                        isDismissible: true,
                        enableDrag: true,
                        builder: (context) {
                          return DraggableScrollableSheet(
                              initialChildSize: 0.80,
                              expand: true,
                              builder: (context, scrollController) {
                                return MyBottomSheet(
                                    token: widget.accessToken,
                                    list: _list,
                                    itemList: itemList);
                              });
                        });
                  },

                  child: Container(
                      height: 80,
                      padding: EdgeInsets.all(6),

                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,

                        children: [
                          Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              Container(
                                child: Text('Creator'),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 5),
                                child: Text(
                                    eventItem[index].creator.email),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 5),
                                child: Text(eventItem[index].summary.toString() ?? ""),
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(right: 10),
                            alignment: Alignment.bottomCenter,
                            child: Row(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(right: 10),
                                  child: GestureDetector(
                                    child: Icon(
                                      Icons.edit_outlined,
                                      color: Colors.green,
                                      size: 22,
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  DetailScreen()));
                                    },
                                  ),
                                ),
                                GestureDetector(
                                  child: Icon(
                                    Icons.delete_forever_rounded,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  onTap: () {
                                    _presenter.deleteEvent(
                                        eventItem[index].id,
                                        eventItem[index].creator.email);
                                  },
                                ),
                              ],
                            ),
                          )
                        ],
                      )),
                ),
              ),
            );
          },
        ):Center(
          child: CircularProgressIndicator(),
        ),
      ), onRefresh: _presenter.getCalendarEvent),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Palette.colorPrimary,
        onPressed: (){

          showModalBottomSheet(
              backgroundColor: Colors.transparent,
              context: context,
              isScrollControlled: true,
              isDismissible: true,
              enableDrag: true,
              builder: (context) {
                return DraggableScrollableSheet(
                    initialChildSize: 0.80,
                    expand: true,
                    builder: (context, scrollController) {
                      return MyBottomSheet(token: widget.accessToken,list: _list,itemList: itemList);
                    }
                );
              }
          );

      }
      )
    );
  }

  void showAsBottomSheet() async {
    final result = await
    showSlidingBottomSheet(
        context,
        builder: (context) {
          return SlidingSheetDialog(
            elevation: 8,
            cornerRadius: 16,
            snapSpec: const SnapSpec(
              snap: true,
              snappings: [0.4, 0.7, 1.0],
              positioning: SnapPositioning.relativeToAvailableSpace,
            ),
            builder: (context, state) {
              return Container(
                height: 400,
                child: Center(
                  child: Material(
                    child: InkWell(
                      onTap: () => Navigator.pop(context, 'This is the result.'),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'This is the content of the sheet',
                          style: Theme.of(context).textTheme.body1,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }
    );

    print(result);
  }

  void internet() async{
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
      }
    } on SocketException catch (_) {
      Toast toast = Toast();
      toast.overLay = false;
      toast.showOverLay("inter not connected", Colors.white, Colors.black54, context);
    }
  }

  @override
  onShowLoader() {
    setState(() {
      isVisible = true;
    });
  }

  @override
  onHideLoader() {
    setState(() {
      isVisible = false;
    });
  }

  @override
  onErrorHandler(String message){
    Toast toast = Toast();
    toast.overLay = false;
    toast.showOverLay(message, Colors.white, Colors.black54, context);
    setState(() {
      isVisible = false;
    });

  }

  @override
  onSuccessRes(response) {
    setState(() {
      List<dynamic> data = response;
        _list.addAll(data.map((i) => Item.fromJson(i)).toList());

        for(int i=0;i<data.length;i++){
          if(data[i]['accessRole']=="owner"){
            itemList.add(Item.fromJson(data[i]));
          }
        }
    });
  }

  @override
  onEventSuccess(response) {
    print("success $response");
    setState(() {
      eventItem.clear();
      List<dynamic> data = response;
      eventItem.addAll(data.map((e) => EventItem.fromJson(e)).toList());
    });
  }

}

