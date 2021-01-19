import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RoundShapeButton extends StatelessWidget {

  final Function onPressed;
  final String text;
  final String fontFamily;
  final double fontSize;
  final double radius;
  final Image icon;
  final Color color;
  final double width;

  RoundShapeButton({this.onPressed, this.text,this.fontFamily,this.fontSize,this.radius,this.icon,this.color,this.width});

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      elevation: 5,
      onPressed: onPressed,
      color: color,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(width: width,color: Colors.black)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          icon,
          Expanded(
              child: Text(text,
                style: TextStyle(fontFamily: fontFamily,fontSize: fontSize,)
                ,textAlign: TextAlign.center,)
          ),
        ],
      )
    );
  }
}