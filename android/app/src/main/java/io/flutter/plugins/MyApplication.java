package com.example.myflutterapp;

import com.clevertap.android.sdk.ActivityLifecycleCallback;
import com.clevertap.android.sdk.CleverTapAPI;
import io.flutter.app.FlutterApplication;

public class MyApplication extends FlutterApplication {
        @java.lang.Override
        public void onCreate() {
            ActivityLifecycleCallback.register(this); //<--- Must call this before super.onCreate()
            super.onCreate();
        }
}