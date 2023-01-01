import 'package:flutter/material.dart';

class likeprovider extends ChangeNotifier {
  late bool _isliked;

  bool get isliked => _isliked;

  void setliked(bool newisliked) {
    _isliked = newisliked;
    notifyListeners();
  }

}