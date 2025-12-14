package com.example.vetra_app

import android.content.Context
import android.graphics.Bitmap
import android.opengl.GLES20
import android.opengl.GLSurfaceView
import android.util.Log
import android.view.View
import android.widget.Toast
import com.google.ar.core.Config
import com.google.ar.core.Frame
import com.google.ar.core.Session
import com.google.ar.core.TrackingState
import com.google.ar.core.exceptions.NotYetAvailableException
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import java.io.File
import java.io.FileOutputStream
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.FloatBuffer
import android.media.Image
import android.os.Handler
import android.os.Looper
import javax.microedition.khronos.egl.EGLConfig
import javax.microedition.khronos.opengles.GL10

class ArPlatformView(
    private val context: Context,
    private val viewId: Int,
    private val args: Map<String, Any>?,
    messenger: BinaryMessenger
) : PlatformView, MethodChannel.MethodCallHandler, GLSurfaceView.Renderer, EventChannel.StreamHandler {

    private val methodChannel: MethodChannel = MethodChannel(messenger, "com.example.vetra/ar_view_$viewId")
    private val eventChannel: EventChannel = EventChannel(messenger, "com.example.vetra/ar_depth_stream_$viewId")
    private var eventSink: EventChannel.EventSink? = null

    private val surfaceView: GLSurfaceView = GLSurfaceView(context)
    private var session: Session? = null

    // Rendering
    private var backgroundRenderer: BackgroundRenderer? = null
    private var displayRotationHelper: DisplayRotationHelper? = null

    private var captureRequested = false
    private var lastDepthTimestamp = 0L

    init {
        methodChannel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(this)

        surfaceView.preserveEGLContextOnPause = true
        surfaceView.setEGLContextClientVersion(2)
        surfaceView.setEGLConfigChooser(8, 8, 8, 8, 16, 0)
        surfaceView.setRenderer(this)
        surfaceView.renderMode = GLSurfaceView.RENDERMODE_CONTINUOUSLY
        
        displayRotationHelper = DisplayRotationHelper(context)
    }

    override fun getView(): View = surfaceView

    override fun dispose() {
        session?.close()
        session = null
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "captureDepth" -> {
                captureRequested = true
                result.success(null) // We will return the actual result via a separate method or just wait? 
                // Actually capture is async in the render loop. 
                // Ideally we should keep the result and complete it later.
                // For simplicity, we'll send a success here and assume the file creation works, 
                // OR we can use a "captureResult" event or similar.
                // Let's stick to: we trigger it, and we'll send a message back when done via MethodChannel.
            }
            "dispose" -> dispose()
            else -> result.notImplemented()
        }
    }

    override fun onSurfaceCreated(gl: GL10?, config: EGLConfig?) {
        GLES20.glClearColor(0.1f, 0.1f, 0.1f, 1.0f)
        backgroundRenderer = BackgroundRenderer()
        backgroundRenderer?.createOnGlThread(context)

        try {
            session = Session(context)
            val config = session!!.config
            if (session!!.isDepthModeSupported(Config.DepthMode.AUTOMATIC)) {
                config.depthMode = Config.DepthMode.AUTOMATIC
            }
            config.focusMode = Config.FocusMode.AUTO
            session!!.configure(config)
            
            // Resume session immediately (simplest fix first)
            session!!.resume()
        } catch (e: Exception) {
            Log.e("ArPlatformView", "Failed to create AR session", e)
        }
    }

    override fun onSurfaceChanged(gl: GL10?, width: Int, height: Int) {
        displayRotationHelper?.onSurfaceChanged(width, height)
        GLES20.glViewport(0, 0, width, height)
    }

    override fun onDrawFrame(gl: GL10?) {
        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT or GLES20.GL_DEPTH_BUFFER_BIT)

        if (session == null) return

        displayRotationHelper?.updateSessionIfNeeded(session!!)

        try {
            session!!.setCameraTextureName(backgroundRenderer!!.textureId)
            val frame = session!!.update()
            
            backgroundRenderer!!.draw(frame)

            // Depth Logic
            if (frame.camera.trackingState == TrackingState.TRACKING) {
                handleDepth(frame)
            }

        } catch (t: Throwable) {
            Log.e("ArPlatformView", "Exception on draw frame", t)
        }
    }

    private fun handleDepth(frame: Frame) {
        try {
            val depthImage = frame.acquireDepthImage16Bits() // might throw NotYetAvailableException
            
            // 1. Center Stream
            if (System.currentTimeMillis() - lastDepthTimestamp > 200) { // 5Hz
                 val depth = getCenterDepth(depthImage)
                 Handler(Looper.getMainLooper()).post {
                     eventSink?.success(depth)
                 }
                 lastDepthTimestamp = System.currentTimeMillis()
            }

            // 2. Capture
            if (captureRequested) {
                captureRequested = false
                val depthPath = saveDepth(depthImage)
                
                // Capture Color (Screenshot of Surface)
                captureBitmap { bitmap ->
                    val imageFile = File(context.filesDir, "capture_${System.currentTimeMillis()}.jpg")
                    FileOutputStream(imageFile).use { out ->
                        bitmap.compress(Bitmap.CompressFormat.JPEG, 90, out)
                    }
                    val imagePath = imageFile.absolutePath
                    
                    Handler(Looper.getMainLooper()).post {
                        val args = mapOf(
                            "success" to true, 
                            "depthFilePath" to depthPath,
                            "imageFilePath" to imagePath // Pass image path
                        )
                        methodChannel.invokeMethod("onCaptureComplete", args)
                    }
                }
            }

            depthImage.close()
        } catch (e: NotYetAvailableException) {
            // Ignore
        }
    }

    private fun getCenterDepth(image: Image): Float {
        val planes = image.planes
        if (planes.isEmpty()) return 0f
        val buffer = planes[0].buffer
        val width = image.width
        val height = image.height
        val rowStride = planes[0].rowStride
        val pixelStride = planes[0].pixelStride
        
        val x = width / 2
        val y = height / 2
        
        val index = (y * rowStride) + (x * pixelStride)
        
        // Little endian uint16
        val b1 = buffer.get(index).toInt() and 0xFF
        val b2 = buffer.get(index + 1).toInt() and 0xFF
        val depthMm = (b2 shl 8) or b1
        
        return depthMm / 1000f // meters
    }
    
    private fun saveDepth(image: Image): String {
        // Implement stride-aware copy to dense buffer
        val planes = image.planes
        val buffer = planes[0].buffer
        val width = image.width
        val height = image.height
        val rowStride = planes[0].rowStride
        val pixelStride = planes[0].pixelStride // usually 2 for DEPTH16

        val outBuffer = ByteArray(width * height * 2)
        var outIndex = 0

        for (y in 0 until height) {
            for (x in 0 until width) {
                val index = (y * rowStride) + (x * pixelStride)
                outBuffer[outIndex++] = buffer.get(index)
                outBuffer[outIndex++] = buffer.get(index + 1)
            }
        }
        
        val file = File(context.filesDir, "depth_${System.currentTimeMillis()}.bin")
        FileOutputStream(file).use { it.write(outBuffer) }
        return file.absolutePath
    }
    
    private fun captureBitmap(callback: (Bitmap) -> Unit) {
        val bitmap = Bitmap.createBitmap(surfaceView.width, surfaceView.height, Bitmap.Config.ARGB_8888)
        android.view.PixelCopy.request(surfaceView, bitmap, { result ->
            if (result == android.view.PixelCopy.SUCCESS) {
                callback(bitmap)
            } else {
                Log.e("ArPlatformView", "PixelCopy failed: $result")
                // Fallback or error handling? For now just ignore or callback with empty?
                // Realistically if this fails, we just don't get an image.
            }
        }, Handler(Looper.getMainLooper()))
    }
}
