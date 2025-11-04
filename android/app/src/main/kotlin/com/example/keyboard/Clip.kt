package com.example.ime.views

import android.content.Context
import android.util.AttributeSet
import android.graphics.Color
import android.widget.FrameLayout
import android.widget.ImageView
import com.example.ime.FlutterIME
import com.example.ime.R

open class Clip
@JvmOverloads
constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyle: Int = android.R.attr.buttonStyle
) : Key(context, attrs, defStyle) {
    init {
        val img = ImageView(context).apply {
            setImageResource(R.drawable.ic_clipboard)
            val params = FrameLayout.LayoutParams(LayoutParams.MATCH_PARENT, dpToPx(35f).toInt())
            params.gravity = android.view.Gravity.CENTER
            layoutParams = params
            setBackgroundColor(Color.TRANSPARENT)
        }
        addView(img)
    }
    override fun onClick() {
        super.onClick()
        val clip = FlutterIME.ime.rootView.findViewById<com.example.ime.views.ClipboardView>(R.id.clipboard)
        clip.refresh()
        clip.visibility = android.view.View.VISIBLE
    }
}
