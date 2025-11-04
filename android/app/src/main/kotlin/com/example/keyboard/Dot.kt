package com.example.ime.views

import android.content.Context
import android.util.AttributeSet
import com.example.ime.FlutterIME
class Dot
@JvmOverloads
constructor(
        context: Context,
        attrs: AttributeSet? = null,
        defStyle: Int = android.R.attr.buttonStyle
) : Normal(context, attrs, defStyle) {
    override var clickFn = {sendText()}
    override var longPressFn = {FlutterIME.ime.sendKeyPress(",")}
    // init{
    //     clickFn =  
    // }
    // override fun onClick() {
        
    //     super.onClick()
    // }  
}
