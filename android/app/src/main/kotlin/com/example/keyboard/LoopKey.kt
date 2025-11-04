package com.example.ime.views

import android.content.Context
import android.util.AttributeSet
import android.view.HapticFeedbackConstants
import com.example.ime.FlutterIME

open class LoopKey
@JvmOverloads
constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyle: Int = android.R.attr.buttonStyle
) : Normal(context, attrs, defStyle) {
    override var longPressFn = {
        
        if (isHoldKey) {
            onClick()
            clickFn()
            longPressHandler.postDelayed(longPressRunnable, 50)

        }
    }
    override fun onLongPress() {
        super.onLongPress()
        
    }
}