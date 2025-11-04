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
class CtrlKey(private val rootView: View,val service: InputMethodService) {
    var isPressCtrl=false
    var isHoldCtrl = false
    public fun disableCtrl(){
        if(!isHoldCtrl && isPressCtrl){
            isHoldCtrl=false
            sendKeyUp(service, KeyEvent.KEYCODE_CTRL_LEFT)
        }

    }
      init {
        val btn = rootView.findViewById<Button>(R.id.keyCtrl)
        //btn.text = "⏎"
        //btn.text = "⏎"
        //btn.text = "⏎"
        btn.setOnClickListener {
            if(isPressCtrl){
                sendKeyUp(service, KeyEvent.KEYCODE_CTRL_LEFT)
                isPressCtrl=false
            }else{
                sendKeyDown(service, KeyEvent.KEYCODE_CTRL_LEFT)
                isPressCtrl=true
            }
            
        }
         btn.setOnLongClickListener {
                sendKeyDown(service, KeyEvent.KEYCODE_CTRL_LEFT)
                isHoldCtrl=true
                isPressCtrl=true
            return@setOnLongClickListener true
        }


    }
}