import 'package:flutter/material.dart';

class TokenProvider extends ChangeNotifier {
  String _accessToken = '';

  String get accessToken => _accessToken;

  set accessToken(String token) {
    _accessToken = token;
    notifyListeners();
  }
}
