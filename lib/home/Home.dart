import 'package:appointment/home/createAppointment/CreateAppointment.dart';
import 'package:appointment/utils/DBProvider.dart';
import 'package:appointment/utils/values/Constant.dart';
import 'package:appointment/utils/values/Dimen.dart';
import 'package:appointment/utils/values/Palette.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  Home({this.name});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final dbHelper = DatabaseHelper.instance;
  var data;
  @override
  void initState() {
    super.initState();
    _query();
  }

  void _query() async {
    final allRows = await dbHelper.queryAllRows();
    allRows.forEach((row) {
      print(row);
    });
  }


  DateTime _dateTime = DateTime.now();
  DateTime _currentTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: AppBar(
          backgroundColor: Palette.colorPrimary,
        ),
      ),
      body: Container(
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
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Palette.colorPrimary,
        onPressed: (){
        // _modalBottomSheetMenu();
        // Navigator.push(context, CupertinoPageRoute(
        //     builder: (_) => CreateAppointment(),
        // )
        // );
        MyStatelessWidget();
      }
      )
    );
  }
  _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _currentTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(_currentTime.year + 25),
    );
    if (picked != null && picked != _dateTime)
      setState(() {
        _dateTime = picked;
      });
    print(_dateTime);
  }
  void _modalBottomSheetMenu(){
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        // isDismissible: true,
        builder: (BuildContext context) {
          return DraggableScrollableSheet(
              initialChildSize: 0.90,
              expand: true,
              builder: (context, scrollController) {
                return Container(
                  padding: EdgeInsets.only(left: Dimen().dp_20,right: Dimen().dp_20),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(20.0),
                            topRight: const Radius.circular(20.0))),
                    child: Column(
                        children: [
                          Container(
                            child: Icon(Icons.remove,size: 40,color: Palette.colorPrimary,),
                          ),
                          Container(
                            child: Text('Hii ${widget.name} create a appointment',style: TextStyle(
                              fontSize: 15,fontFamily: 'poppins_medium'
                            ),),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: Dimen().dp_20),
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(width: 1,color: Colors.black54)
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                               GestureDetector(
                                 child:  Container(
                                   padding: EdgeInsets.only(left: Dimen().dp_20),
                                   child: Text('Start Time :'),
                                 ),
                                 onTap: (){
                                   setState(() {
                                     _selectDate(context);
                                   });
                                 },
                               ),
                                Container(
                                  padding: EdgeInsets.only(left: Dimen().dp_20),
                                  margin: EdgeInsets.only(top: 5,bottom: Dimen().dp_10),
                                  child: Text(_dateTime.toString()),
                                ),
                                Divider(
                                  height: 1,
                                  color: Colors.black54,
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: Dimen().dp_10),
                                  padding: EdgeInsets.only(left: Dimen().dp_20),
                                  child: Text('Start Time :'),
                                ),
                                Container(
                                  padding: EdgeInsets.only(left: Dimen().dp_20),
                                  margin: EdgeInsets.only(top: 5),
                                  child: Text('Time'),
                                ),
                              ],
                            ),
                          ),
                        ],
                    ));
              }
          );
        }
    );
  }

}
class MyStatelessWidget extends StatelessWidget {
  MyStatelessWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        child: const Text('showBottomSheet'),
        onPressed: () {
          Scaffold.of(context).showBottomSheet<void>(
                (BuildContext context) {
              return Container(
                height: 200,
                color: Colors.amber,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text('BottomSheet'),
                      ElevatedButton(
                        child: const Text('Close BottomSheet'),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
