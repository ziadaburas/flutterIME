package com.example.ime.keys

import android.view.View
import android.view.inputmethod.InputConnection
import android.inputmethodservice.InputMethodService
import android.widget.Button
import com.example.ime.R
import android.os.Handler
import android.os.Looper
import android.view.KeyEvent
import android.view.MotionEvent

class DownKey(service: InputMethodService, rootView: View) : Key(service, rootView,R.id.keyDown) {

    init {
        
        btn.setOnClickListener {
            sendKeyPress(KeyEvent.KEYCODE_DPAD_DOWN)
        }
        btn.setOnLongClickListener {
             sendKeyPress(KeyEvent.KEYCODE_MOVE_END)
             return@setOnLongClickListener true
        }
    }
}
class UpKey(service: InputMethodService, rootView: View) : Key(service, rootView,R.id.keyUp) {

    init {
        
        btn.setOnClickListener {
            sendKeyPress(KeyEvent.KEYCODE_DPAD_UP)
        }
        btn.setOnLongClickListener {
             sendKeyPress(KeyEvent.KEYCODE_MOVE_HOME)
             return@setOnLongClickListener true
        }
    }
}
class RightKey(service: InputMethodService, rootView: View,) : Key(service, rootView, R.id.keyRight) {

    private val handler = Handler(Looper.getMainLooper())
    private var isHolding = false

    val deleteRunnable = object : Runnable {
        override fun run() {
            if (isHolding) {
               sendKeyPress(KeyEvent.KEYCODE_DPAD_RIGHT)
                handler.postDelayed(this, 50)
            }
        }
    }
    
    public override fun touchListener(e: MotionEvent): Boolean {
        super.touchListener(e) // استدعاء الدالة الأساسية للتعامل مع اللمس
        return when (e.action) {
            MotionEvent.ACTION_DOWN -> {
                isHolding = true
                sendKeyPress(KeyEvent.KEYCODE_DPAD_RIGHT)
                handler.postDelayed(deleteRunnable, 300) // يبدأ التكرار بعد 300ms
                true
            }
            MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                isHolding = false
                handler.removeCallbacks(deleteRunnable)
                true
            }
            else -> false
        }
    }
}
class LeftKey(service: InputMethodService, rootView: View,) : Key(service, rootView, R.id.keyLeft) {

 
    override fun longPressListener(){
         super.longPressListener()
        if (isHoldKey) {
            sendKeyPress(KeyEvent.KEYCODE_DPAD_LEFT)
            longPressHandler.postDelayed(longPressRunnable, 50)
        }
    
    }
     override fun clickListener(){
        super.clickListener()
        sendKeyPress(KeyEvent.KEYCODE_DPAD_LEFT)
    }
}