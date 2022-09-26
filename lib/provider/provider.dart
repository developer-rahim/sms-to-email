import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Controller extends ChangeNotifier {
  int START_SERVICE = 0;
  Future<void> startService() async {
    if (Platform.isAndroid) {
      var methodChannel = MethodChannel("com.example.messages");
      String data = await methodChannel.invokeMethod("startService");
     // debugPrint(data);
    }
    notifyListeners();
  }

  // Future<void> stopService() async {
  //   if (Platform.isAndroid) {
  //     var methodChannel = MethodChannel("com.example.messages");
  //     String data = await methodChannel.invokeMethod("stopService");
  //     debugPrint(data);
  //   }
  // }

  background() {
    // if (START_SERVICE == 0) {
    startService();

    // START_SERVICE = 1;
    // } else {
    // stopService();

    // START_SERVICE = 0;
    // }
    //notifyListeners();
  }
}
