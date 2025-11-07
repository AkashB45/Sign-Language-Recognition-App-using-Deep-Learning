package com.example.signapp

import android.content.Context
import android.util.Log
import android.view.View
import android.view.ViewGroup
import androidx.camera.core.AspectRatio
import androidx.camera.core.Camera
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageAnalysis.OUTPUT_IMAGE_FORMAT_RGBA_8888
import androidx.camera.core.ImageProxy
import android.widget.Toast
import androidx.camera.core.Preview
import androidx.camera.core.resolutionselector.AspectRatioStrategy
import androidx.camera.core.resolutionselector.ResolutionSelector
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.constraintlayout.widget.ConstraintSet
import androidx.core.content.ContextCompat
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.LifecycleOwner
import com.google.mediapipe.tasks.vision.core.RunningMode
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.platform.PlatformView
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit

class MyCameraView(
    private val context: Context,
    messenger: BinaryMessenger,
    id: Int,
    creationParams: Map<String?, Any?>?,
    private val activity: FlutterActivity
) : PlatformView,HandLandmarkerHelper.LandmarkerListener, LifecycleEventObserver {

    private var constraintLayout = ConstraintLayout(context)
    private var viewFinder = PreviewView(context)
    private var overlayView: OverlayView = OverlayView(context, null)

    private var backgroundExecutor: ExecutorService = Executors.newSingleThreadExecutor()
    private var cameraFacing = CameraSelector.LENS_FACING_BACK
    private var imageAnalyzer: ImageAnalysis? = null
    private var preview: Preview? = null
    private var camera: Camera? = null
    private var cameraProvider: ProcessCameraProvider? = null

    private var delegate: Int = HandLandmarkerHelper.DELEGATE_CPU
    private var minHandDetectionConfidence: Float =
        HandLandmarkerHelper.DEFAULT_HAND_DETECTION_CONFIDENCE
    private var minHandTrackingConfidence: Float = HandLandmarkerHelper
        .DEFAULT_HAND_TRACKING_CONFIDENCE
    private var minHandPresenceConfidence: Float = HandLandmarkerHelper
        .DEFAULT_HAND_PRESENCE_CONFIDENCE
    private var maxHands: Int = 2

    private lateinit var handLandmarkerHelper: HandLandmarkerHelper

    init {
        val layoutParams = ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        )
        constraintLayout.layoutParams = layoutParams

        val constraintSet = ConstraintSet()
        constraintSet.clone(constraintLayout)

        viewFinder.id = View.generateViewId()
        viewFinder.implementationMode = PreviewView.ImplementationMode.COMPATIBLE
        constraintLayout.addView(viewFinder)
        constraintSet.constrainWidth(viewFinder.id, ConstraintSet.MATCH_CONSTRAINT)
        constraintSet.constrainHeight(viewFinder.id, ConstraintSet.MATCH_CONSTRAINT)
        constraintSet.connect(
            viewFinder.id,
            ConstraintSet.LEFT,
            ConstraintSet.PARENT_ID,
            ConstraintSet.LEFT
        )
        constraintSet.connect(
            viewFinder.id,
            ConstraintSet.RIGHT,
            ConstraintSet.PARENT_ID,
            ConstraintSet.RIGHT
        )
        constraintSet.connect(
            viewFinder.id,
            ConstraintSet.TOP,
            ConstraintSet.PARENT_ID,
            ConstraintSet.TOP
        )
        constraintSet.connect(
            viewFinder.id,
            ConstraintSet.BOTTOM,
            ConstraintSet.PARENT_ID,
            ConstraintSet.BOTTOM
        )

        overlayView.id = View.generateViewId()
        constraintLayout.addView(overlayView)
        constraintSet.constrainWidth(overlayView.id, ConstraintSet.MATCH_CONSTRAINT)
        constraintSet.constrainHeight(overlayView.id, ConstraintSet.MATCH_CONSTRAINT)
        constraintSet.connect(
            overlayView.id,
            ConstraintSet.LEFT,
            ConstraintSet.PARENT_ID,
            ConstraintSet.LEFT
        )
        constraintSet.connect(
            overlayView.id,
            ConstraintSet.RIGHT,
            ConstraintSet.PARENT_ID,
            ConstraintSet.RIGHT
        )
        constraintSet.connect(
            overlayView.id,
            ConstraintSet.TOP,
            ConstraintSet.PARENT_ID,
            ConstraintSet.TOP
        )
        constraintSet.connect(
            overlayView.id,
            ConstraintSet.BOTTOM,
            ConstraintSet.PARENT_ID,
            ConstraintSet.BOTTOM
        )
        constraintLayout.bringChildToFront(overlayView)

        constraintSet.applyTo(constraintLayout)

        backgroundExecutor.execute {
            handLandmarkerHelper = HandLandmarkerHelper(
                context = context,
                runningMode = RunningMode.LIVE_STREAM,
                minHandDetectionConfidence = minHandDetectionConfidence,
                minHandTrackingConfidence = minHandTrackingConfidence,
                minHandPresenceConfidence = minHandPresenceConfidence,
                maxNumHands = maxHands,
                currentDelegate = delegate,
                handLandmarkerHelperListener = this
            )

            viewFinder.post {
                setUpCamera()
            }
        }

    }

    override fun dispose() {

    }

    private fun setUpCamera() {
        val cameraProviderFuture =
            ProcessCameraProvider.getInstance(context)
        cameraProviderFuture.addListener(
            {
                // CameraProvider
                cameraProvider = cameraProviderFuture.get()

                // Build and bind the camera use cases
                bindCameraUseCases()
            },
            ContextCompat.getMainExecutor(context)
        )
    }

    override fun getView(): View {
        return constraintLayout
    }


    private fun bindCameraUseCases() {

        val aspectRatioStrategy = AspectRatioStrategy(
            AspectRatio.RATIO_16_9, AspectRatioStrategy.FALLBACK_RULE_NONE
        )
        val resolutionSelector = ResolutionSelector.Builder()
            .setAspectRatioStrategy(aspectRatioStrategy)
            .build()

        // CameraProvider
        val cameraProvider =
            cameraProvider
                ?: throw IllegalStateException("Camera initialization failed.")

        // CameraSelector - makes assumption that we're only using the back camera
        val cameraSelector =
            CameraSelector.Builder()
                .requireLensFacing(cameraFacing).build()

        // Preview. Only using the 4:3 ratio because this is the closest to our models
        preview =
            Preview.Builder()
                .setResolutionSelector(resolutionSelector)
                .setTargetRotation(viewFinder.display.rotation)
                .build()

        // ImageAnalysis. Using RGBA 8888 to match how our models work
        imageAnalyzer =
            ImageAnalysis.Builder()
                .setResolutionSelector(resolutionSelector)
                .setTargetRotation(viewFinder.display.rotation)
                .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                .setOutputImageFormat(OUTPUT_IMAGE_FORMAT_RGBA_8888)
                .build()
                // The analyzer can then be assigned to the instance
                .also {
                     it.setAnalyzer(backgroundExecutor) { image ->
                        detectHand(image)
                    }
                }


        // Must unbind the use-cases before rebinding them
        cameraProvider.unbindAll()

        try {
            // A variable number of use-cases can be passed here -
            // camera provides access to CameraControl & CameraInfo
            camera = cameraProvider.bindToLifecycle(
                activity,
                cameraSelector,
                preview,
                imageAnalyzer
            )

            // Attach the viewfinder's surface provider to preview use case
            preview?.surfaceProvider = viewFinder.surfaceProvider
        } catch (exc: Exception) {
            Log.e("TAG", "Use case binding failed", exc)
        }
    }

    private fun detectHand(imageProxy: ImageProxy) {
        Log.i("here123","3")
        handLandmarkerHelper.detectLiveStream(
            imageProxy = imageProxy,
            isFrontCamera = cameraFacing == CameraSelector.LENS_FACING_FRONT
        )
    }

    override fun onError(error: String, errorCode: Int) {

            Toast.makeText(context, error, Toast.LENGTH_SHORT).show()

    }

    override fun onResults(resultBundle: HandLandmarkerHelper.ResultBundle) {

            // For overlay, show the first hand
            if (resultBundle.results.isNotEmpty()) {
                overlayView.setResults(
                    resultBundle.results.first(),
                    resultBundle.inputImageHeight,
                    resultBundle.inputImageWidth,
                    RunningMode.LIVE_STREAM
                )
                overlayView.invalidate()
            }

            // Send landmarks from the first hand to Flutter
            val allLandmarks = mutableListOf<Map<String, Any>>()
            for (result in resultBundle.results) {
                val handLandmarks = result.landmarks()
                if (handLandmarks.isNotEmpty()) {
                    for (landmark in handLandmarks.first()) {
                        allLandmarks.add(mapOf("x" to landmark.x().toDouble(), "y" to landmark.y().toDouble()))
                    }
                    break // only first hand
                }
            }
            if (allLandmarks.isNotEmpty()) {
                val data = mapOf(
                    "landmarks" to allLandmarks,
                    "width" to resultBundle.inputImageWidth,
                    "height" to resultBundle.inputImageHeight
                )
                activity.runOnUiThread {
                    MainActivity.eventSink?.success(data)
                }
            }

    }


    override fun onStateChanged(
        source: LifecycleOwner,
        event: Lifecycle.Event
    ) {
        when (event) {
            Lifecycle.Event.ON_RESUME -> {
               backgroundExecutor.execute {
            if (handLandmarkerHelper.isClose()) {
                handLandmarkerHelper.setupHandLandmarker()
            }
        }
            }

            Lifecycle.Event.ON_PAUSE -> {
                if(this::handLandmarkerHelper.isInitialized) {
            // Close the HandLandmarkerHelper and release resources
            backgroundExecutor.execute { handLandmarkerHelper.clearHandLandmarker() }
        }
            }

            Lifecycle.Event.ON_DESTROY -> {
               backgroundExecutor.shutdown()
        backgroundExecutor.awaitTermination(
            Long.MAX_VALUE, TimeUnit.NANOSECONDS
        )
            }

            else -> {}
        }


    }
}

//https://ai.google.dev/edge/mediapipe/solutions/vision/face_detector
//https://github.com/google-ai-edge/mediapipe
