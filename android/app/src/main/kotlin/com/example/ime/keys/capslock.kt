package com.example.ime.keys

import android.view.View
import android.view.inputmethod.InputConnection
import android.inputmethodservice.InputMethodService
import android.widget.Button
import com.example.ime.R
import com.example.ime.keys.CtrlKey
import android.os.Handler
import android.os.Looper
import android.view.KeyEvent
import android.view.MotionEvent


class CapsLockKey(service: InputMethodService, rootView: View): SpecialKey(service, rootView, R.id.keyCaps, 0) {
   
   override public fun disable(){
        super.disable()
        Key.changeCapsLetters(rootView,isPressed)
    }
    override public fun disableHold(){
        super.disableHold()
        Key.changeCapsLetters(rootView,isPressed)
    }
    override public fun enable(){
        super.enable()
        Key.changeCapsLetters(rootView,isPressed)
    }
}