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
    return new Container(

      child: secondHalf.isEmpty
          ? new Text(firstHalf,style: TextStyle(color: Colors.black.withOpacity(0.5),fontSize: 13, fontFamily: "poppins_regular"))
          : Container(
        transform: Matrix4.translationValues(0.0, 0.0, 0.0),
            child: new Column(
        children: <Widget>[
            new Text(flag ? (firstHalf + "...") : (firstHalf + secondHalf), style: TextStyle(color: Colors.black.withOpacity(0.5),fontSize: 13, fontFamily: "poppins_regular")),
            new InkWell(
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                    child: new Text(
                      flag ? "show more" : "show less",
                      style: new TextStyle(color: Colors.blue, fontSize: 10, fontFamily: 'poppins_regular', decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),

              onTap: () {
                setState(() {
                  flag = !flag;
                });
              },
            ),
        ],
      ),
          ),
    );
  }
}