package com.smstomail.background

import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat

class AppService: Service() {
    override fun onCreate() {
        super.onCreate()

        if(Build.VERSION.SDK_INT>=Build.VERSION_CODES.O)
        {

            val notificationBuilder=NotificationCompat.Builder(this,"msgs")
                    .setContentText("Notificaiton from background Service - Flutter")
                    .setContentTitle("Background Service")
                    .setSmallIcon(R.mipmap.ic_launcher)
                    .build()
            Log.v("OnService","OnService")
            //val manager=getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            //manager.notify((System.currentTimeMillis()%10000).toInt(),notificationBuilder)
            startForeground((System.currentTimeMillis()%10000).toInt(),notificationBuilder)
            Log.v("OnService","OnService")
        }


    }
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {

        startService()
        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null;
    }

    fun startService()
    {
        Thread(Runnable {
            var k=0;
            for( k in 0.. 50)
            {
                Log.v("OnCalling","" +k)
                Thread.sleep(1000)

            }
        }).start()

    }

    override fun onDestroy() {
        if(Build.VERSION.SDK_INT>=Build.VERSION_CODES.O)
        {
            stopForeground(true);
        }

            super.onDestroy()
    }
}