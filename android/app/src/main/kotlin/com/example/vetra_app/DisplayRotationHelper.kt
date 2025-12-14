package com.example.vetra_app

import android.content.Context
import android.hardware.display.DisplayManager
import android.view.Display
import android.view.WindowManager
import com.google.ar.core.Session

class DisplayRotationHelper(context: Context) : DisplayManager.DisplayListener {
    private val displayManager: DisplayManager = context.getSystemService(Context.DISPLAY_SERVICE) as DisplayManager
    private val windowManager: WindowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
    private var viewportWidth = 0
    private var viewportHeight = 0
    private var viewportChanged = false

    init {
        displayManager.registerDisplayListener(this, null)
    }

    fun onSurfaceChanged(width: Int, height: Int) {
        viewportWidth = width
        viewportHeight = height
        viewportChanged = true
    }

    fun updateSessionIfNeeded(session: Session) {
        if (viewportChanged) {
            val display = windowManager.defaultDisplay
            val rotation = display.rotation
            session.setDisplayGeometry(rotation, viewportWidth, viewportHeight)
            viewportChanged = false
        }
    }

    override fun onDisplayAdded(displayId: Int) {}
    override fun onDisplayRemoved(displayId: Int) {}
    override fun onDisplayChanged(displayId: Int) {
        viewportChanged = true
    }
}
