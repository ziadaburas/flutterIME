package com.example.ime.views

import android.content.Context
import android.util.AttributeSet
import android.view.KeyEvent
import android.widget.LinearLayout
import com.example.ime.FlutterIME

open class Tab
@JvmOverloads
constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyle: Int = android.R.attr.buttonStyle
) : Normal(context, attrs, defStyle) {
    override var keyCode = KeyEvent.KEYCODE_TAB
    override var clickFn = {sendKeyCode()}
    override val textPaint =super.textPaint.apply {
        textSize = spToPx(25f) 

    }
    init{
        text = "⇥"
        
    }
}
