import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class SampleModel extends Listenable {
  static SampleModel instance = SampleModel();

  bool isWeb = false;

  bool isCardView = true;

  final Set<VoidCallback> _listeners = Set<VoidCallback>();
  @override

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  @protected
  void notifyListeners() {
    _listeners.toList().forEach((VoidCallback listener) => listener());
  }
}