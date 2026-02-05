package com.example.ime.views

import android.content.Context
import android.util.AttributeSet
import android.graphics.Color
import android.widget.FrameLayout
import android.widget.ImageView
import com.example.ime.FlutterIME
import com.example.ime.R
import android.graphics.drawable.*
import android.view.*
import android.graphics.*

open class Clip
@JvmOverloads
constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyle: Int = android.R.attr.buttonStyle
) : Key(context, attrs, defStyle) {
    // override var backgroundImg = R.drawable.ic_clipboard

    init {
        
        text = "" 
        backgroundImg = R.drawable.ic_clipboard
        
    }
    
    override fun onClick() {
        super.onClick()
        val clip = FlutterIME.ime.rootView.findViewById<com.example.ime.views.ClipboardView>(R.id.clipboard)
        clip.refresh()
        clip.visibility = android.view.View.VISIBLE
    }
}
