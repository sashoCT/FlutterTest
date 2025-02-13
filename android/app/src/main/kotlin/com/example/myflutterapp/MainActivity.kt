package com.example.myflutterapp

import com.clevertap.android.geofence.CTGeofenceAPI
import com.clevertap.android.geofence.CTGeofenceSettings
import com.clevertap.android.geofence.Logger
import com.clevertap.android.sdk.CleverTapAPI
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
     private val CHANNEL = "geochannel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            val ctGeofenceAPI = CTGeofenceAPI.getInstance(applicationContext)
            if (call.method == "initGeofenceSDK") {
                val ctGeofenceSettings = CTGeofenceSettings.Builder()
                    .enableBackgroundLocationUpdates(true) // boolean to enable background location updates
                    .setGeofenceMonitoringCount(100)
                    .setLogLevel(Logger.VERBOSE)
                    .build()

                ctGeofenceAPI.init(ctGeofenceSettings, CleverTapAPI.getDefaultInstance(this)!!)
                ctGeofenceAPI.triggerLocation()
                result.success(null)
            } else if (call.method == "deactivateGeofenceSDK") {
                ctGeofenceAPI.deactivate()
                result.success(null)
            }  else if (call.method == "triggerLocation") {
                ctGeofenceAPI.triggerLocation()

            } else {
                result.notImplemented()
            }
        }
    }
}
