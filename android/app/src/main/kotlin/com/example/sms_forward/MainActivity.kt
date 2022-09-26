package com.example.sms_forward

import android.content.Intent
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger,"com.example.messages")
                .setMethodCallHandler{call,result->

                    if(call.method=="startService")
                    {
                        startServices()
                    }
                   else if(call.method=="stopService")
                    {
                        stopServices()
                    }
                }

    }
      lateinit var intent:Any
   fun startServices()
    {
        intent=Intent(this,AppService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent as Intent)
        }else
        {
            startService(intent as Intent)
        }
    }

    fun stopServices()
    {
        intent=Intent(this,AppService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            stopService(intent as Intent)
        }else
        {
            stopService(intent as Intent)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        //stopService(intent as Intent)
    }
}

