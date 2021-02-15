import 'dart:async';

import 'package:appointment/utils/values/Constant.dart';
import 'package:appointment/utils/values/Strings/Strings.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../interface/IsAcceptAppointment.dart';


class ProgressButton extends StatefulWidget {
  IsAcceptAppointment isAccept;
  String text;
  Function onTap;
  var formKey = GlobalKey<FormState>();
  bool isVisible;

  ProgressButton({this.isAccept, this.text, this.formKey , this.isVisible});

  @override
  _ProgressButtonState createState() => _ProgressButtonState();
}

class _ProgressButtonState extends State<ProgressButton>
    with TickerProviderStateMixin {
  int _state = 0;
  Animation _animation;
  AnimationController _controller;
  GlobalKey _globalKey = GlobalKey();
  double _width = double.maxFinite;
  

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: PhysicalModel(
        shadowColor: Colors.blue,
        color: Colors.blue,
        borderRadius: BorderRadius.circular(25),
        child: Container(
          key: _globalKey,
          height: 40,
          width: _width,
          child: RaisedButton(
            animationDuration: Duration(milliseconds: 1000),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: EdgeInsets.all(0),
            child: setUpButtonChild(),
            onPressed: () {
              setState(() {
                if (_state == 0) {
                  if(widget.formKey!=null && widget.formKey.currentState.validate()) {
                      if (widget.isVisible) {
                          animateButton();
                      } else {
                        Constant.showToast(Resources.from(context, Constant.languageCode).strings.selectCalendar, Toast.LENGTH_SHORT);
                      }
                  }else{
                    animateButton();
                  }
                }
              });
            },
            elevation: 4,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }

  setUpButtonChild() {
    if (_state == 0) {
      return Text(
        widget.text,
        style: TextStyle(fontSize: 16, fontFamily: 'poppins_medium', color: Colors.white),
      );
    } else if (_state == 1) {
      return SizedBox(
        height: 30,
        width: 30,
        child: CircularProgressIndicator(
          value: null,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else {
      return Icon(Icons.check, color: Colors.white);
    }
  }

  void animateButton() {
    double initialWidth = _globalKey.currentContext.size.width;

    _controller = AnimationController(duration: Duration(milliseconds: 300), vsync: this);

    _animation = Tween(begin: 0.0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {
          _width = initialWidth - ((initialWidth - 48) * _animation.value);
        });
      });
    _controller.forward();

    setState(() {
      _state = 1;
    });

    Timer(Duration(milliseconds: 3300), () {
      setState(() {
        _state = 2;
        widget.isAccept.isAccept();
      });
    });
  }
}
