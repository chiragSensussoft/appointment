import 'dart:async';

import 'package:appointment/login/Login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>  with SingleTickerProviderStateMixin{
  AnimationController _animationController;
  Animation _animation;
  int _duration = 4500;

  @override
  void initState() {
    super.initState();
    if (_duration < 1000) _duration = 2000;
    _animationController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 1200));
    _animation = Tween(begin: 1.0, end: 0.5).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeInCirc));
    _animationController.forward();
    Future.delayed(Duration(milliseconds: _duration)).then((value) {
      Navigator.of(context).pushReplacement(CupertinoPageRoute(
          builder: (BuildContext context) => Login()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
                Center(
                    child: Container(
                      alignment: Alignment.center,
                      // width: MediaQuery.of(context).size.width,
                      child:
                      // SvgPicture.asset('images/appointment.svg',height: 200,width: 200,)

                      ScaleTransition(
                          scale: _animation,
                          child: Center(
                              child:
                              SizedBox(height: 200, child:SvgPicture.asset('images/appointment.svg'))))
                    ),
                ),
                Container(padding: const EdgeInsets.only(bottom: 10),
                  alignment: Alignment.bottomCenter,
                  child: Text('BE A DIGITAL APPOINTMENT',style: TextStyle(fontFamily: 'poppins_medium.ttf'),),
                )
              ],
        )
      )
    );
  }
}
