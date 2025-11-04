package com.example.ime.views

import android.content.Context
import android.util.AttributeSet
import android.view.KeyEvent
import android.view.MotionEvent
import android.widget.LinearLayout
import com.example.ime.FlutterIME


open class Space
@JvmOverloads
constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyle: Int = android.R.attr.buttonStyle
) : Normal(context, attrs, defStyle) {
    override var keyCode = KeyEvent.KEYCODE_SPACE
    override var clickFn = {sendKeyCode()}
    var touchStartX = 0f
    var offset = 0
    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        layoutParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.MATCH_PARENT, 3f)
        when(FlutterIME.ime.currentLang) {
            "ar" -> {
                text = "العربية"
                hint = "English"
            }
            "en" -> {
                text = "English"
                hint = "العربية"
            }
        }

    }
    override fun actionDown(e: MotionEvent): Boolean {
        super.actionDown(e)
        touchStartX = e.x
        offset = 0
        return true
    }
    override fun actionMove(e: MotionEvent): Boolean {
        super.actionMove(e)
        offset = Math.abs(e.x - touchStartX).toInt()
        return true
    }
    override fun actionUp(e: MotionEvent): Boolean {
        super.actionUp(e)
        if (offset > (btnWidth / 2)) post { 
            FlutterIME.ime.switchLang()
            Key.ctrl.notifyListeners()
            Key.alt.notifyListeners()
            Key.shift.notifyListeners()
            Key.capslock.notifyListeners()
         } 
        return true
    }
}
