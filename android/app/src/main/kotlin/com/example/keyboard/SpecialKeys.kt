package com.example.ime.views

import android.content.Context
import android.util.AttributeSet
import android.view.KeyEvent

open class Ctrl
@JvmOverloads
constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyle: Int = android.R.attr.buttonStyle
) : Special(context, attrs, defStyle) {
    override var keyCode = KeyEvent.KEYCODE_CTRL_LEFT
    override val listener = Key.ctrl
    init{init()}
}

open class Alt
@JvmOverloads
constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyle: Int = android.R.attr.buttonStyle
) : Special(context, attrs, defStyle) {
    override var keyCode = KeyEvent.KEYCODE_ALT_LEFT
    override val listener = Key.alt
    init{init()}
    
}

open class Shift
@JvmOverloads
constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyle: Int = android.R.attr.buttonStyle
) : Special(context, attrs, defStyle) {
    override var keyCode = KeyEvent.KEYCODE_SHIFT_LEFT
    override val listener = Key.shift
    init{init()}
}

open class Capslock
@JvmOverloads
constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyle: Int = android.R.attr.buttonStyle
) : Special(context, attrs, defStyle) {
    override val listener = Key.capslock
    override val textPaint =super.textPaint.apply {
        textSize = spToPx(25f) 
    }
    init{init()}
}
