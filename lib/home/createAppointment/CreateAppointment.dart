import 'package:appointment/home/presenter/HomePresentor.dart';
import 'package:appointment/utils/Toast.dart';
import 'package:appointment/utils/values/Palette.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../OnHomeView.dart';

class CreateAppointment extends StatefulWidget {
  @override
  _CreateAppointmentState createState() => _CreateAppointmentState();
}

class _CreateAppointmentState extends State<CreateAppointment> implements OnHomeView{
  HomePresenter _presenter;
  bool isVisible;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Appointment'),
        backgroundColor: Palette.colorPrimary,
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(

          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Palette.colorPrimary,
        onPressed: (){
          _presenter = new HomePresenter(this,endDate: "2021-01-19T15:34:00",startDate:  "2021-01-19T14:34:00",timeZone: "IST",summary: "hair & Beauty");
          _presenter.attachView(this);
          _presenter.getText();
        },
      ),
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
    print('onError:::$message');
  }

  @override
  onSuccessRes(response) {
    throw UnimplementedError();
  }
}
