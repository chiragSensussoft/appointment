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
  Color color;
  String id;
  String email;

  ProgressButton(
      {this.isAccept,
      this.text,
      this.formKey,
      this.isVisible,
      this.color,
      this.id,
      this.email});

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

  // @override
  // void dispose() {
  //   super.dispose();
  //   _controller.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: PhysicalModel(
        shadowColor: widget.color,
        color: widget.color,
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
                print("GET::::$_state   formkey::::${widget.formKey}");
                if (_state == 0) {
                  if (widget.formKey != null) {
                    if (widget.formKey.currentState.validate()) {
                      if (widget.isVisible) {
                        animateButton();
                      }
                      // else {
                      //   Constant.showToast(Resources.from(context, Constant.languageCode).strings.selectCalendar, Toast.LENGTH_SHORT);
                      // }
                    }
                  } else {
                    // animateButton();
                    showConfirmationDialog(context);
                  }
                }
              });
            },
            elevation: 4,
            color: widget.color,
          ),
        ),
      ),
    );
  }

  setUpButtonChild() {
    if (_state == 0) {
      return Text(
        widget.text,
        style: TextStyle(
            fontSize: 16, fontFamily: 'poppins_medium', color: Colors.white),
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

    _controller =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);

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
        if(widget.text=="Delete"){
          widget.isAccept.isAccept(widget.text, widget.id, widget.email);
        }else{
          widget.isAccept.isAccept(widget.text, widget.id," ");
        }
      });
    });
  }


  Future<bool> showConfirmationDialog(BuildContext context) {
      return showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(Resources.from(context, Constant.languageCode).strings.conformDelete, style: TextStyle(fontSize: 14, fontFamily: "poppins_regular")),
            actions: <Widget>[
              FlatButton(
                child: Text(Resources.from(context, Constant.languageCode).strings.no),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text(Resources.from(context, Constant.languageCode).strings.yes),
                onPressed: () {
                  animateButton();
                  Navigator.pop(context, true);
                },
              ),
            ],
          );
        },
      );
    }

}
