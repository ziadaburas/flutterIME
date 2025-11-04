package com.example.ime.views

import android.content.Context
import android.util.AttributeSet
import com.example.ime.FlutterIME

class Symbols
@JvmOverloads
constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyle: Int = android.R.attr.buttonStyle
) : Normal(context, attrs, defStyle) {
    companion object {
        var isSymbols = false
    }
    override var clickFn = {
        Key.isSymbols.value = !(Key.isSymbols.value ?: true)
        FlutterIME.ime.switchSymbols(Key.isSymbols.value == true)
    }
    init {
        text = if (Key.isSymbols.value == true) "abc" else "123"
        Key.isSymbols.addListener { newVal -> text = if (newVal == true) "abc" else "123" }
    }
}
