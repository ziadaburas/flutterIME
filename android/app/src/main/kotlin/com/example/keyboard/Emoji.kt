package com.example.ime.views

import android.content.Context
import android.util.AttributeSet
import android.graphics.*
import android.widget.FrameLayout
import android.view.*
import android.widget.ImageView
import com.example.ime.FlutterIME
import com.example.ime.R
import android.graphics.drawable.*
open class Emoji
@JvmOverloads
constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyle: Int = R.attr.keyStyle
) : Key(context, attrs, defStyle) {
    override var backgroundImg = R.drawable.emoji_language
    init {
        val img = ImageView(context).apply {
            setImageResource(R.drawable.ic_clipboard)
            val params = FrameLayout.LayoutParams(LayoutParams.MATCH_PARENT, dpToPx(35f).toInt())
            params.gravity = android.view.Gravity.CENTER
            layoutParams = params
            setBackgroundColor(Color.TRANSPARENT)
        }
       // addView(img)
    text = "\u2661"
    val icon = context.getDrawable( R.drawable.emoji_language) 
            icon?.setBounds(0, 0, icon.intrinsicWidth, icon.intrinsicHeight)

            val layer = LayerDrawable(arrayOf(icon)).apply {
                setLayerGravity(0, Gravity.CENTER)
            }
            // setImageResource(R.drawable.ic_arrow_back)
            background =layer
        
    }
    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        val icon = context.getDrawable( R.drawable.emoji_language) 
            icon?.setBounds(0, 0, icon.intrinsicWidth, icon.intrinsicHeight)

            val layer = LayerDrawable(arrayOf(icon)).apply {
                setLayerGravity(0, Gravity.CENTER)
            }
            // setImageResource(R.drawable.ic_arrow_back)
            background =layer
    }
    override fun onClick() {
        super.onClick()
        val clip = FlutterIME.ime.rootView.findViewById<com.example.ime.views.EmojiView>(R.id.emoji)
        clip.refresh()
        clip.visibility = android.view.View.VISIBLE
    }
}
