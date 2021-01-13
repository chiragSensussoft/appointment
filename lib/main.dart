import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            // color: Color(0xff1B96DC),
            image: DecorationImage(
              image: AssetImage('images/ic_launcher_round.png'),
            )
          ),
        ),
      ),
    );
  }
}
