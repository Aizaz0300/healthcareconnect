import 'package:flutter/foundation.dart';

class UserProvider extends ChangeNotifier {
  Map<String, dynamic>? _userData;
  bool _isLoading = false;

  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;

  void setUserData(Map<String, dynamic> data) {
    _userData = data;
    notifyListeners();
  }

  void clearUserData() {
    _userData = null;
    notifyListeners();
  }


  // Convenience getters for commonly used user data
  String? get firstName => _userData?['firstName'];
  String? get lastName => _userData?['lastName'];
  String? get email => _userData?['email'];
  String? get userId => _userData?['\$id'];
  String? get profileImage => _userData?['profileImage'];

}
