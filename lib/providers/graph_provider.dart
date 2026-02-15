import 'package:flutter/material.dart';

class GraphProvider extends ChangeNotifier {
  String graphType = 'pie';

  void setGraph(String type) {
    graphType = type;
    notifyListeners();
  }
}
