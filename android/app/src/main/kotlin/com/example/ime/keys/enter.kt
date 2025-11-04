package com.example.ime.keys

import android.view.View
import android.view.inputmethod.InputConnection
import android.inputmethodservice.InputMethodService
import android.widget.Button
import com.example.ime.R
import android.view.KeyEvent
import android.view.MotionEvent
import android.view.inputmethod.ExtractedTextRequest 

class EnterKey(service: InputMethodService,rootView: View):Key(service, rootView,R.id.keyEnter) {
    init {
        //btn.width = (screenWidth*0.25).toInt()
        btn.text = "⏎"
        // parent.setOnClickListener {
        //     super.sendKeyPress(KeyEvent.KEYCODE_ENTER)
        // }
        // isNotSupportLongPress = true

    }
    override fun clickListener(){
        super.clickListener()
        sendKeyPress(KeyEvent.KEYCODE_ENTER)
    }
}
class TabKey(service: InputMethodService,rootView: View):Key(service, rootView,R.id.keyTab) {
    init {     
        btn.text = "\u2386"
        btn.setOnClickListener {
            
            super.sendKeyPress(KeyEvent.KEYCODE_TAB)
        }
    }
}
class ClipboardKey(service: InputMethodService,rootView: View,val fn :(() -> Unit)):Key(service, rootView,R.id.keyClip) {
    init {     
        
        btn.setOnClickListener {
            //(rootView.findViewById(R.id.clipboard_container) as View).visibility=View.VISIBLE
            fn()
        }
    }
}
class SpaceKey(service: InputMethodService,rootView: View,val fn :(() -> Unit)):Key(service, rootView,R.id.keySpace) {
     //private val longPressHandler = Handler(android.os.Looper.getMainLooper())
    private var longPressTriggered = false
    var offset =0
     
    init {
        //btn.width = (screenWidth*0.25).toInt()
        //btn.text = "⏎"
        parent.setOnClickListener {
            sendKeyPress(" ")
        } 
    }
   var touchStartX = 0f


override fun touchListener(e: MotionEvent): Boolean {
    super.touchListener(e)
    if(Key.isNumeric) return false // ← لا تفعل شيء إذا كان في وضع الأرقام
    return when (e.action) {
        MotionEvent.ACTION_DOWN -> {
            touchStartX = e.x
            offset = 0
            true
        }
        MotionEvent.ACTION_MOVE -> {
            offset = Math.abs(e.x - touchStartX).toInt()
            true
        }
        MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
            if (offset > (btn.width / 2)) {
                fn()
                btn.text = Key.currentLang // ← غير النص عند السحب
                return true
            } else {
                sendKeyPress(" ") // ← أرسل مفتاح space عند الضغط العادي
                return true
            }
        }
        else -> false
    }
}

             
}