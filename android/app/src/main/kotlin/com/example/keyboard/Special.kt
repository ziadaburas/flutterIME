package com.example.ime.views

import android.content.Context
import android.util.AttributeSet
import android.view.HapticFeedbackConstants
import android.view.KeyEvent
import com.example.ime.FlutterIME
import android.graphics.*

abstract class Special
@JvmOverloads
constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyle: Int = android.R.attr.buttonStyle
) : Key(context, attrs, defStyle) {
    
    abstract val listener: ValueListener<Int>
    
    open fun disable() {
        FlutterIME.ime.sendKeyUp(keyCode)
        listener.value = 0
        setBackgroundColor(0xFF2D2D2D.toInt())
    }
    open fun enable(hold: Int = 0) {
        listener.value = hold + 1
        FlutterIME.ime.sendKeyDown(keyCode)
    }
    override fun onLongPress() {
        performHapticFeedback(HapticFeedbackConstants.LONG_PRESS)
        super.onLongPress()
        enable(1)
    }
    override fun onClick() {
        if ((listener.value ?: 1) != 0) disable() else enable()
    }
    init {
        isSpecialKey = true
    }
    open fun init(){
        listener.addListener {
            val value = it ?: 0
            if (value == 0) {
                setBackgroundColor(0xFF2D2D2D.toInt())
                disable()
            }else {
                setBackgroundColor(Color.CYAN)
            }
        }
    }
    
}

class ValueListener<T : Any?> private constructor(private var _value: T?) {
    private val listeners = mutableListOf<(T?) -> Unit>()
    var value: T?
        get() = _value
        set(newValue) {
            if (_value != newValue) {
                _value = newValue
                notifyListeners(newValue)
            }
        }
    fun addListener(listener: (T?) -> Unit) {
        listeners.add(listener)
    }
    fun removeListener(listener: (T?) -> Unit) {
        listeners.remove(listener)
    }
    fun clearListeners() {
        listeners.clear()
    }
    fun notifyListeners() {
        notifyListeners(_value)
    }
    private fun notifyListeners(value: T?) {
        listeners.forEach { it.invoke(value) }
    }
    companion object {
        operator fun invoke(): ValueListener<Any?> = ValueListener(null)
        operator fun <T : Any?> invoke(initialValue: T?): ValueListener<T> = ValueListener(initialValue)
    }
}
