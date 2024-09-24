import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';

class InternetProvider extends ChangeNotifier {
  bool _hasInternet = false;
  bool get hasInternet => _hasInternet;

  InternetProvider() {
    checkInternetConnection();
  }

  Future checkInternetConnection() async {
    var result = await Connectivity().checkConnectivity();
    _hasInternet = !(result == ConnectivityResult.none);
    notifyListeners();
  }
}
