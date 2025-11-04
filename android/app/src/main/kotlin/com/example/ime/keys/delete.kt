package com.example.ime.keys

import android.os.Handler
import android.os.Looper
import android.view.KeyEvent
import android.view.MotionEvent
import android.view.View
import android.widget.Button
import android.inputmethodservice.InputMethodService
import com.example.ime.R

class DeleteKey(service: InputMethodService,rootView: View):Key(service,rootView,R.id.keyDel) {

    private val handler = Handler(Looper.getMainLooper())
    private var isHolding = false

    val deleteRunnable = object : Runnable {
        override fun run() {
            if (isHolding) {
                delete()
                handler.postDelayed(this, 50) // يستمر الحذف كل 100ms
            }
        }
    }
    init {
        btn.text = "⌫"
         btn.width = (screenWidth*0.25).toInt()

    }
     override fun longPressListener(){
         super.longPressListener()
        if (isHoldKey) {
            delete()
            handler.postDelayed(longPressRunnable, 50) // يستمر الحذف كل 100ms
        }
    
    }
     override fun clickListener(){
        super.clickListener()
        delete()
    }
    //  public override fun touchListener(e: MotionEvent): Boolean {
    //     super.touchListener(e)
    //     when (e.action) {
    //         MotionEvent.ACTION_DOWN -> {
    //             isHolding = true
    //             delete()
    //             handler.postDelayed(deleteRunnable, 300) // يبدأ التكرار بعد 300ms
    //             return true
    //         }
    //         MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
    //             isHolding = false
    //             handler.removeCallbacks(deleteRunnable)
    //             return true
    //         }
    //         else -> return false
    //     }
    // }
    

        fun delete(){
        val ic = service.currentInputConnection
        val selected =getSelectedText()
        if(selected != "")ic.commitText("", 1)
        else ic.deleteSurroundingText(1, 0)
    }
}
