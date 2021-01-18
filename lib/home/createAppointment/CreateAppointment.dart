import 'package:appointment/utils/values/Palette.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CreateAppointment extends StatefulWidget {
  @override
  _CreateAppointmentState createState() => _CreateAppointmentState();
}

class _CreateAppointmentState extends State<CreateAppointment> {
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
    );
  }
}
