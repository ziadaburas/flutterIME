package com.example.ime.views

import android.content.Context
import android.util.AttributeSet
import android.view.KeyEvent
import android.view.MotionEvent
import android.widget.LinearLayout
import com.example.ime.FlutterIME

open class Enter
@JvmOverloads
constructor(
        context: Context,
        attrs: AttributeSet? = null,
        defStyle: Int = android.R.attr.buttonStyle
) : Normal(context, attrs, defStyle) {
    override var keyCode = KeyEvent.KEYCODE_ENTER
    override var clickFn = {sendKeyCode()}
    override val textPaint =super.textPaint.apply {
        textSize = spToPx(25f) 
    }
    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        text = "⏎"
        layoutParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.MATCH_PARENT, 1.5f)
    }
}
