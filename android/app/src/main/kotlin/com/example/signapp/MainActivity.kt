package com.example.signapp

import io.flutter.embedding.android.FlutterActivity
import android.Manifest
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import com.example.signapp.MyCameraViewFactory

class MainActivity : FlutterActivity() {
    companion object {
        var eventSink: EventChannel.EventSink? = null
    }

    private val REQUEST_CODE_PERMISSIONS = 10

    // Add microphone permission here
    private val REQUIRED_PERMISSIONS = mutableListOf(
        Manifest.permission.CAMERA,
        Manifest.permission.RECORD_AUDIO
    ).toTypedArray()

    private lateinit var methodResult: MethodChannel.Result

    override fun onRequestPermissionsResult(
        requestCode: Int, permissions: Array<String>, grantResults: IntArray
    ) {
        if (requestCode == REQUEST_CODE_PERMISSIONS) {
            if (allPermissionsGranted()) {
                methodResult.success(true)
            } else {
                methodResult.success(false)
            }
        }
    }

    private fun allPermissionsGranted() = REQUIRED_PERMISSIONS.all {
        ContextCompat.checkSelfPermission(baseContext, it) == PackageManager.PERMISSION_GRANTED
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory(
                "cameraView",
                MyCameraViewFactory(this, messenger = flutterEngine.dartExecutor.binaryMessenger)
            )

        // Register the EventChannel for landmarks
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "landmarks").setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            }
        )

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "camera_permission"
        ).setMethodCallHandler { call, result ->
            methodResult = result
            when (call.method) {
                "getCameraPermission" -> {
                    ActivityCompat.requestPermissions(
                        this, // ✅ replaced 'context as FlutterActivity' with 'this'
                        REQUIRED_PERMISSIONS,
                        REQUEST_CODE_PERMISSIONS
                    )
                }
                "getMicrophonePermission" -> {
                    ActivityCompat.requestPermissions(
                        this,
                        arrayOf(Manifest.permission.RECORD_AUDIO),
                        REQUEST_CODE_PERMISSIONS
                    )
                }
                else -> result.notImplemented()
            }
        }
    }
}
