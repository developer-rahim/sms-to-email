package com.sms.mail.background

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Notifications.createNotificationChannels(this)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val binaryMessenger = flutterEngine.dartExecutor.binaryMessenger

        MethodChannel(binaryMessenger, "com.app/background_service").apply {
            setMethodCallHandler { method, result ->
                if (method.method == "startService") {
                    val callbackRawHandle = method.arguments as Long
                    BackgroundService.startService(this@MainActivity, callbackRawHandle)
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
        }

        MethodChannel(binaryMessenger, "com.app/app_retain").apply {
            setMethodCallHandler { method, result ->
                if (method.method == "sendToBackground") {
                    moveTaskToBack(true)
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
        }
    }
}


///...................Alternative way to keep background app........................

// class MainActivity: FlutterActivity() {

//     override fun onCreate(savedInstanceState: Bundle?) {
//         super.onCreate(savedInstanceState)

//         MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger,"com.example.messages")
//                 .setMethodCallHandler{call,result->

//                     if(call.method=="startService")
//                     {
//                         startServices()
//                     }
//                    else if(call.method=="stopService")
//                     {
//                         stopServices()
//                     }
//                 }

//     }
//       lateinit var intent:Any
//    fun startServices()
//     {
//         intent=Intent(this,AppService::class.java)
//         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//             startForegroundService(intent as Intent)
//         }else
//         {
//             startService(intent as Intent)
//         }
//     }

//     fun stopServices()
//     {
//         intent=Intent(this,AppService::class.java)
//         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//             stopService(intent as Intent)
//         }else
//         {
//             stopService(intent as Intent)
//         }
//     }

//     override fun onDestroy() {
//         super.onDestroy()
//         //stopService(intent as Intent)
//     }
// }

