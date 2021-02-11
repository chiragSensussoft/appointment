import 'package:flutter/material.dart';


class ExpandableText extends StatefulWidget {
  ExpandableText({this.text});

  final String text;

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  String textToDisplay;

  @override
  void initState() {
    print(widget.text.length);
    textToDisplay = widget.text.length > 25 ? widget.text.substring(0,25)+"..." : widget.text;
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Text(textToDisplay),

      onTap: () {
        if (widget.text.length > 200 && textToDisplay.length <= 200) {
          setState(() {
            textToDisplay = widget.text;
          });
        }

        else if (widget.text.length > 100 && textToDisplay.length > 100) {
          setState(() {
            textToDisplay = widget.text.substring(0,100)+"...";
          });
        }
      },
    );

    return Container(
      child: RichText(
        text: TextSpan(
          children :[
            TextSpan(text: textToDisplay,style: TextStyle(color: Colors.black.withOpacity(0.5),fontSize: 13, fontFamily: "poppins_regular")),
            TextSpan(text: "", style: TextStyle(color: Colors.blue)),
          ]
        ),
      ),
    );
  }
}