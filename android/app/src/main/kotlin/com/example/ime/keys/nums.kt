package com.example.ime.keys

import android.view.View
import android.view.inputmethod.InputConnection
import android.inputmethodservice.InputMethodService
import android.widget.Button
import com.example.ime.R
import android.view.KeyEvent
import android.view.MotionEvent

class NumsKey(service: InputMethodService,rootView: View,val fn :((String)-> Unit)):Key(service, rootView,R.id.keyNums) {
    init {
        // //btn.width = (screenWidth*0.25).toInt()
        // btn.text = "⏎"
        btn.setOnClickListener {
            if(Key.isNumsEnabled){
                Key.isNumsEnabled = false
                btn.text = "123"
                fn(Key.currentLang)
               
               
            } else {
                Key.isNumsEnabled = true
                btn.text = "ABC"
                fn("nums")
            }
        }
    }
}