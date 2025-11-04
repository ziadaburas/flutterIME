package com.example.ime.views

import android.content.Context
import android.util.AttributeSet
import android.view.HapticFeedbackConstants
import com.example.ime.FlutterIME

open class Normal
@JvmOverloads
constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyle: Int = android.R.attr.buttonStyle
) : Key(context, attrs, defStyle) {
    open var clickFn = {}
    open var longPressFn  = {}
    override fun onLongPress() {
        if(!isLongPressed) {
            performHapticFeedback(HapticFeedbackConstants.LONG_PRESS)
        }
        super.onLongPress()
        longPressFn()
    }
    override fun onClick() {
        clickFn()
        super.onClick()
    }
}