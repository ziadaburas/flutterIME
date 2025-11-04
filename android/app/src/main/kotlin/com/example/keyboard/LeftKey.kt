package com.example.ime.views

import android.content.Context
import android.graphics.*
import android.os.*
import android.util.*
import android.view.*
import android.widget.*
import com.example.ime.FlutterIME

class LeftKey
@JvmOverloads
constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyle: Int = android.R.attr.buttonStyle
) : LoopKey(context, attrs, defStyle) {
    
    override val textPaint =super.textPaint.apply {
        textSize = spToPx(25f) 
    }
    override fun onClick() {
        FlutterIME.ime.sendKeyPress(KeyEvent.KEYCODE_DPAD_LEFT)
        super.onClick()
    }

    
}

class RightKey
@JvmOverloads
constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyle: Int = android.R.attr.buttonStyle
) : LoopKey(context, attrs, defStyle) {
    override val textPaint =super.textPaint.apply {
        textSize = spToPx(25f) 
    }
    override fun onClick() {
        FlutterIME.ime.sendKeyPress(KeyEvent.KEYCODE_DPAD_RIGHT)
        super.onClick()
    }
}
