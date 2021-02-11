import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class DescriptionTextWidget extends StatefulWidget {
  final String text;

  DescriptionTextWidget({@required this.text});

  @override
  _DescriptionTextWidgetState createState() => new _DescriptionTextWidgetState();
}

class _DescriptionTextWidgetState extends State<DescriptionTextWidget> {
  String firstHalf;
  String secondHalf;

  bool flag = true;

  @override
  void initState() {
    super.initState();

    if (widget.text.length > 150) {
      firstHalf = widget.text.substring(0, 150);
      secondHalf = widget.text.substring(150, widget.text.length);
    } else {
      firstHalf = widget.text;
      secondHalf = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: secondHalf.isEmpty
          ? Text(firstHalf, style: TextStyle(color: Colors.black.withOpacity(0.5),fontSize: 12, fontFamily: "poppins_regular"))
          :
      Container(
        child: RichText(
          text: TextSpan(
              children :[
                TextSpan(text: flag ? (firstHalf + "...") :(firstHalf + secondHalf),
                    style: TextStyle(color: Colors.black.withOpacity(0.5),fontSize: 13, fontFamily: "poppins_regular")),
                TextSpan(text: flag ? "  show more" : "  show less", style: TextStyle(color: Colors.blue, fontSize: 12),
                  recognizer: TapGestureRecognizer()..onTap = (){
                   setState(() {
                     flag = !flag;
                   });
                  }),
              ]
          ),
        ),

      ),
    );
  }
}