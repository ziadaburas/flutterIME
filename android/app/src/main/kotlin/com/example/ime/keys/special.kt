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

open class SpecialKey(service: InputMethodService, rootView: View,btnId : Int,val keyCode : Int): Key(service, rootView, btnId) {
    var isPressed=false
   
   open public fun disable(){
        if( !isHoldPressed){
            isHoldPressed=false
            isPressed=false
            sendKeyUp(keyCode)
        }
    }
    
    
    open public fun disableHold(){
            isHoldPressed=false
            isPressed=false
            sendKeyUp(keyCode)
        
    }
    open public fun enable(){
            isPressed=true
            sendKeyDown(keyCode)
            if(!isHoldPressed)
            Key.addTasks(::disable)
    }
   override fun longPressListener(){
         super.longPressListener()
        isHoldPressed=true
        vibrate()
            enable()
    
    }
     override fun clickListener(){
        super.clickListener()
        if(isPressed && !isHoldPressed){
                Key.runAndClearTasks()
                disable()
            } 
            else if(isHoldPressed) disableHold()
            else if(!isPressed) enable()
            
    }



    //   init {
    //      btn.setOnTouchListener { _,_ ->false }
    //     btn.setOnClickListener {  
    //         if(isPressed && !isHoldPressed){
    //             Key.runAndClearTasks()
    //             disable()
    //         } 
    //         else if(isHoldPressed) disableHold()
    //         else if(!isPressed) enable()
            
    //     }

    //      btn.setOnLongClickListener {
    //         isHoldPressed=true
    //         enable()
    //         return@setOnLongClickListener true
    //     }
    // }
}