import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sms_forward/loginPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sms_forward/provider/auth_provider.dart';
import 'package:sms_forward/provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  

  // Future<void> stopService() async {
  //   if (Platform.isAndroid) {
  //     var methodChannel = MethodChannel("com.example.messages");
  //     String data = await methodChannel.invokeMethod("stopService");
  //     debugPrint(data);
  //   }
  // }

  await Permission.sms.request();
  await Firebase.initializeApp();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider<Controller>(create: (_) => Controller()),
     ChangeNotifierProvider<AuthController>(create: (_) => AuthController()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.red),
      home: const LoginPage(),
    );
  }
}

// import 'dart:async';
// import 'dart:developer';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:sms_forward/loginPage.dart';
// import 'package:sms_forward/provider/provider.dart';

// void main() {
//   int START_SERVICE = 0;

 



//   runApp( MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => Controller()),
//       ],child: MyApp()));
// }

// class MyApp extends StatelessWidget {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Background Service',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: BackGroundService(),
//     );
//   }
// }

// class BackGroundService extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() {
//     return BackGroundServiceState();
//   }
// }

// class BackGroundServiceState extends State<BackGroundService> {
//   int START_SERVICE = 0;

//   Future<void> startService() async {
//     if (Platform.isAndroid) {
//       var methodChannel = MethodChannel("com.example.messages");
//       String data = await methodChannel.invokeMethod("startService");
//       debugPrint(data);
//     }
//   }

//   Future<void> stopService() async {
//     if (Platform.isAndroid) {
//       var methodChannel = MethodChannel("com.example.messages");
//       String data = await methodChannel.invokeMethod("stopService");
//       debugPrint(data);
//     }
//   }

//   @override
//   void initState() {
//     Controller controller = Provider.of(context, listen: false);
//     controller.background();
//     // TODO: implement initState
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     return Scaffold(
//       body: Center(
//         child: MaterialButton(
//           onPressed: () {
//             Timer.periodic(Duration(seconds: 1), (timer) {
//               setState(() {
//                 START_SERVICE++;
//                 print('aaaaa$START_SERVICE');
//               });
//             });
//             if (START_SERVICE == 0) {
//               startService();
//               setState(() {
//                 START_SERVICE = 1;
//               });
//             } else {
//               stopService();
//               setState(() {
//                 START_SERVICE = 0;
//               });
//             }
//           },
//           color: Colors.brown,
//           child: Text(
//             (START_SERVICE == 0) ? "Start Service" : "Stop Service",
//             style: TextStyle(color: Colors.white),
//           ),
//         ),
//       ),
//     );
//   }
// }
