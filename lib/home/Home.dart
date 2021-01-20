import 'package:appointment/home/presenter/HomePresentor.dart';
import 'package:appointment/utils/DBProvider.dart';
import 'package:appointment/utils/Toast.dart';
import 'package:appointment/utils/values/Dimen.dart';
import 'package:appointment/utils/values/Palette.dart';
import 'package:appointment/home/BottomSheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'OnHomeView.dart';
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
  final String accessToken;


  Home({this.name,this.accessToken});

  @override
  _HomeState createState() => _HomeState();
}

DateTime _dateTime = DateTime.now();
DateTime _currentTime = DateTime.now();

class _HomeState extends State<Home> implements OnHomeView{
  final dbHelper = DatabaseHelper.instance;
  var data;
  String url;
  String userName;
  String email;

  List<Item> _list = new List();
  HomePresenter _presenter;
  bool isVisible;
  @override
  void initState() {
    super.initState();
    _query();
    _presenter = new HomePresenter(this,token: widget.accessToken);
    _presenter.attachView(this);
    _presenter.getCalendar();
    
  }

  _query() async {
    // get a reference to the database
    Database db = await DatabaseHelper.instance.database;
    // get single row
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

    // print the results
    url = result[0]['photoUrl'];
    userName = result[0]['fName'];
    email = result[0]['email'];
    result.forEach((row) => print(row));
    // {_id: 1, name: Bob, age: 23}
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
                        // padding: const EdgeInsets.all(8.0),
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
      body: isVisible == false ?Container(
        color: Colors.grey[200],
        child: ListView.builder(
          itemCount: 10,
          itemBuilder: (_,index){
            return Container(
              padding: EdgeInsets.only(left: Dimen().dp_20,right: Dimen().dp_20),
              height: 40,
              child: Card(
                color: Colors.white,
                child: Text("Item $index",textAlign: TextAlign.center,),
              ),
            );
          },
        ),
      ):Center(
        child: CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Palette.colorPrimary,
        onPressed: (){

        _modalBottomSheetMenu(context,widget.name);
      }
      )
    );
  }
  _modalBottomSheetMenu(BuildContext context,String name){
    showModalBottomSheet<void>(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        builder: (context) {
          return DraggableScrollableSheet(
              initialChildSize: 0.90,
              expand: true,
              builder: (context, scrollController) {
                return MyBottomSheet(name: name,list: _list,);
              }
          );
        }
    );
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
      // print("OnHide");
      isVisible = false;
    });
  }

  @override
  onErrorHandler(String message) {
    setState(() {
      isVisible = false;
    });
    Toast toast = Toast();
    toast.overLay = false;
    toast.showOverLay(message, Colors.white, Colors.black54, context);
    // print('onError:::$message');
  }

  @override
  onSuccessRes(response) {
    // print('onSucess:::$response');
    setState(() {
      List<dynamic> data = response;
      setState(() {
        _list.addAll(data.map((i) => Item.fromJson(i)).toList());
        // print('LENGTH::::${_list.length}');
      });
    });
  }

}

