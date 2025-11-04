package com.example.ime.views

import android.content.Context
import android.util.AttributeSet
import com.example.ime.FlutterIME
class Delete
@JvmOverloads
constructor(
        context: Context,
        attrs: AttributeSet? = null,
        defStyle: Int = android.R.attr.buttonStyle
) : LoopKey(context, attrs, defStyle) {
    init{text = "⌫"}
    override fun onClick() {
        FlutterIME.ime.delete() 
        super.onClick()
    }  
}
