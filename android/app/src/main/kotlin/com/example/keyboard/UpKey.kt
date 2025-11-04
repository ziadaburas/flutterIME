package com.example.ime.views

import android.content.Context
import android.util.AttributeSet
import android.view.KeyEvent
import com.example.ime.FlutterIME

class UpKey
@JvmOverloads
constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyle: Int = android.R.attr.buttonStyle
) : Normal(context, attrs, defStyle) {
    override val textPaint =super.textPaint.apply {
        textSize = spToPx(25f) 
    }
    override var clickFn = {FlutterIME.ime.sendKeyPress(KeyEvent.KEYCODE_DPAD_UP)}
    override var longPressFn = {FlutterIME.ime.sendKeyPress(KeyEvent.KEYCODE_MOVE_HOME)}
}

class DownKey
@JvmOverloads
constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyle: Int = android.R.attr.buttonStyle
) : Normal(context, attrs, defStyle) {
    override val textPaint =super.textPaint.apply {
        textSize = spToPx(25f) 
    }
    override var clickFn = {FlutterIME.ime.sendKeyPress(KeyEvent.KEYCODE_DPAD_DOWN)}
    override var longPressFn = {FlutterIME.ime.sendKeyPress(KeyEvent.KEYCODE_MOVE_END)}
   
}
