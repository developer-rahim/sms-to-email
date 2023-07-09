package com.sms.mail.background

import android.app.Activity
import android.app.Application
import android.os.Bundle

object LifecycleDetector {

    val activityLifecycleCallbacks: Application.ActivityLifecycleCallbacks =
        ActivityLifecycleCallbacks()

    var listener: Listener? = null

    var isActivityRunning = false
        private set

    interface Listener {

        fun onFlutterActivityCreated()

        fun onFlutterActivityDestroyed()

    }

 private class ActivityLifecycleCallbacks : Application.ActivityLifecycleCallbacks {
    override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
        // Empty implementation
    }

    override fun onActivityStarted(activity: Activity) {
        // Empty implementation
    }

    override fun onActivityResumed(activity: Activity) {
        // Empty implementation
    }

    override fun onActivityPaused(activity: Activity) {
        // Empty implementation
    }

    override fun onActivityStopped(activity: Activity) {
        // Empty implementation
    }

    override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {
        // if (activity is MainActivity) {
        //     activity.onSaveInstanceState(outState)
        // }
    }

    override fun onActivityDestroyed(activity: Activity) {
        // Empty implementation
    }
}

//     private class ActivityLifecycleCallbacks : Application.ActivityLifecycleCallbacks {
//         override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
//             if (activity is MainActivity) {
//                 isActivityRunning = true
//                 listener?.onFlutterActivityCreated()
//             }
//         }

//         override fun onActivityDestroyed(activity: Activity) {
//             if (activity is MainActivity) {
//                 isActivityRunning = false
//                 listener?.onFlutterActivityDestroyed()
//             }
//         }

//         override fun onActivityStarted(activity: Activity) {}

//         override fun onActivityStopped(activity: Activity) {}

//         override fun onActivityResumed(activity: Activity) {}

//         override fun onActivityPaused(activity: Activity) {}

//         override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle?) {}
//     }

 }