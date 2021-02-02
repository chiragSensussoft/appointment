import 'package:appointment/sampleModel.dart';
import 'package:flutter/material.dart';

abstract class SampleView extends StatefulWidget {
  final String token;
  const SampleView({Key key,this.token}) : super(key: key);
}

abstract class SampleViewState extends State<SampleView> {
  SampleModel model;

  bool isCardView;

  @override
  void initState() {
    model = SampleModel.instance;
    isCardView = model.isCardView && !model.isWeb;
    super.initState();
  }

  @override
  void dispose() {
    model.isCardView = true;
    super.dispose();
  }

}
