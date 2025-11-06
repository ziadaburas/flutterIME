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
import com.example.ime.db.KeyboardLayoutDB
import android.widget.*


open class Emoji
@JvmOverloads
constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyle: Int = R.attr.keyStyle
) : Key(context, attrs, defStyle) {
    private val db = KeyboardLayoutDB(context)

    override var backgroundImg = R.drawable.emoji_language
    init {
        text = ""
    }
   
    override fun onClick() {
        super.onClick()
        val clip = FlutterIME.ime.rootView.findViewById<com.example.ime.views.EmojiView>(R.id.emoji)
        clip.refresh()
        clip.visibility = android.view.View.VISIBLE
        val layoutJson = try {
            db.getOrCreateLayout("en")
        } catch (ex: Exception) {
            ex.message
        }
        val btn =
                Button(context).apply {
                    text = layoutJson
                }
        clip.addView(btn)
    }
}
