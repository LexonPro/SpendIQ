import 'package:flutter/material.dart';

class LimitProvider extends ChangeNotifier {
  double limit = 0;

  void setLimit(double value) {
    limit = value;
    notifyListeners();
  }
}
