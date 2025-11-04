package com.example.ime.keys

import android.graphics.Color
import android.inputmethodservice.InputMethodService
import android.os.Handler
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.view.ViewConfiguration
import android.widget.Button
import android.widget.TextView

import android.widget.LinearLayout
import com.example.ime.R
import android.graphics.Canvas
import android.graphics.Paint


import android.view.inputmethod.InputConnection
import android.widget.FrameLayout

import android.os.Looper
import android.view.KeyEvent
import android.view.View.OnTouchListener
import android.content.Context
import android.util.AttributeSet

import android.graphics.Typeface
import android.content.res.TypedArray
import android.app.Activity
import android.content.ContextWrapper

class LetterKey  (service: InputMethodService,rootView: View,btnId: Int) :Key(service, rootView,btnId) {
    
    private var selectedIndex = 0
    public var altChars: List<String> = emptyList()
    private var isPopupVisible = false
    var popupContainer: LinearLayout
    private val buttons = mutableListOf<Button>()
    private var longPressTriggered = false
    private val swidth = rootView.context.resources.displayMetrics.widthPixels
    private val shieght = rootView.context.resources.displayMetrics.heightPixels.toFloat()
    val currentRow = btn.parent as FrameLayout
    val btnWidth = screenWidth / 10
    var popupWidth=btnWidth * altChars.size + 10
    
    
    
    
    init {

    //     longPressRunnable = Runnable {
    //     //super.longPressHandler()
    //     isPopupVisible = true
    //     showAltChars()
    //     selectedIndex = 0
    //     highlightButton(selectedIndex)
    //     longPressTriggered = true
    // }
    
        popupContainer = rootView.findViewById<LinearLayout>(R.id.altPopupContainer)
         parent.setOnClickListener {
            if (!isPopupVisible) {
                sendKeyPress(btn.text.toString())
            }
        }
        init()
    }
    public fun init(){
       
        val hint = hintView.text.toString().trim()
        altChars=if(hint.length != 0) hint.split(" ") else emptyList() //.toCharArray().toList()
        hintView.text= hint.replace(" ", "")
        popupWidth=btnWidth * altChars.size + 10

        // if(altChars.isEmpty()){
        //    btn.setOnClickListener {
        //     sendKeyPress(btn.text.toString())
        // }
       // }
    }
    override fun longPressListener(){
        super.longPressListener()
        isPopupVisible = true
        showAltChars()
        selectedIndex = 0
        highlightButton(selectedIndex)
        longPressTriggered = true
    }
    
    
 //btn.setOnTouchListener{_,e ->
     //touchListener(e)


     override fun clickListener(){
        super.clickListener()
        sendKeyPress(btn.text.toString())
     }
     public override fun touchListener(e: MotionEvent): Boolean {

    super.touchListener(e)
    //if(altChars.isEmpty()) return false
    return when (e.action) {
       // MotionEvent.ACTION_DOWN -> {
            // longPressTriggered = false
            // longPressHandler.postDelayed(longPressRunnable, longPressTimeout)
            // true
      //  }
        MotionEvent.ACTION_MOVE -> {
            if (isPopupVisible) {
                val x = e.rawX.toInt()
                // val y = e.rawY.toInt()-btn.height
                val y = buttons.getOrNull(0)?.let {
                    val loc = IntArray(2)
                    it.getLocationOnScreen(loc)
                    loc[1] + it.height / 2
                } ?: 0
                
                val btnUnder = findButtonUnderRaw(popupContainer, buttons, x,y)
                if (btnUnder != null) {
                    val newIndex = buttons.indexOf(btnUnder)
                    if (newIndex != selectedIndex) {
                        selectedIndex = newIndex
                        highlightButton(selectedIndex)
                    }
                } else {
                    if (selectedIndex != -1) {
                        selectedIndex = -1
                        clearHighlight()
                    }
                }
            }
            true
        }
        MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
            if (isPopupVisible) {
                if (altChars.isNotEmpty() && selectedIndex in altChars.indices) {
                    sendKeyPress(altChars[selectedIndex].toString())
                }
                popupContainer.visibility = View.GONE
                isPopupVisible = false
                buttons.clear()
                selectedIndex = 0
                isLongPressed = false
                return@touchListener true
            } 
            else return@touchListener false
        }
        else -> false
    }
}
        // public override fun touchListener(e: MotionEvent): Boolean {
            
        //     super.touchListener(e)
           
        //     return when (e.action) {
        //             MotionEvent.ACTION_DOWN -> {
        //                 //parent.setBackgroundColor( Color.CYAN.toInt())
                        
        //                 longPressTriggered = false
        //                 longPressHandler.postDelayed(longPressRunnable, longPressTimeout)
        //                 true
        //             }
        //             MotionEvent.ACTION_MOVE -> {
          
        //                 if (isPopupVisible) {
        //                     val x = e.rawX.toInt()
        //                     val fixedY = buttons.getOrNull(0)?.let {
        //                         val loc = IntArray(2)
        //                         it.getLocationOnScreen(loc)
        //                         loc[1] + it.height / 2
        //                     } ?: 0
                            
        //                     val btnUnder = findButtonUnderRaw(popupContainer, buttons, x, fixedY)
        //                     if (btnUnder != null) {
        //                         val newIndex = buttons.indexOf(btnUnder)
        //                         if (newIndex != selectedIndex) {
        //                             selectedIndex = newIndex
        //                             highlightButton(selectedIndex)
        //                         }
        //                     } else {
        //                         if (selectedIndex != -1) {
        //                             selectedIndex = -1
        //                             clearHighlight()
        //                         }
        //                     }
        //                 }
        //                 true
        //             }
        //             MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
        //                 longPressHandler.removeCallbacks(longPressRunnable)
        //                 //parent.setBackgroundColor( 0xFF2D2D2D.toInt())
        //                 if (isPopupVisible) {
        //                     if (selectedIndex in altChars.indices) {
        //                         sendKeyPress(altChars[selectedIndex].toString())
        //                     }
        //                     popupContainer.visibility = View.GONE
        //                     isPopupVisible = false
        //                     buttons.clear()
        //                     selectedIndex = 0
        //                     longPressTriggered = false
        //                     return@touchListener true
        //                 } else {
        //                     if (!longPressTriggered) {
        //                         sendKeyPress(btn.text.toString())
        //                     }
        //                     return@touchListener true
        //                 }
        //             }
        //             else -> false
        //         }
        
        // }


    private fun showAltChars() {
        popupContainer.removeAllViews()
        popupContainer.setBackgroundColor(Color.WHITE)
        popupContainer.visibility = View.VISIBLE
        
  
popupContainer.requestLayout()
popupContainer.bringToFront()
// popupContainer.elevation = 100f

// مثلا تضع popupContainer بنفس X لكن فوق btn بمقدار ارتفاع btn
 val rootViewLoc = IntArray(2)
 val btnLoc = IntArray(2)
btn.getLocationOnScreen(btnLoc)
rootView.getLocationOnScreen(rootViewLoc)

val y = btnLoc[1]- rootViewLoc[1]-dpToPx(48f) //.toInt()
popupContainer.x =if(currentRow.x+ btnWidth*altChars.size +10< screenWidth) currentRow.x else currentRow.x-popupWidth +btnWidth //- altChars.size*16
popupContainer.y = y.toFloat() //(currentRow.parent as View).y-btn.height-16 hhنUنD
popupContainer.requestLayout()
popupContainer.invalidate()

        buttons.clear()
        altChars.forEach { altChar ->
            val altBtn = Button(rootView.context).apply {
                text =altChar.toString().lowercase()
                //text = currentRow.x.toString()
                //textSize =15fh1
                setPadding(0,5,0,5)
                setBackgroundColor(Color.LTGRAY)
                setTextColor(Color.BLACK)
                setTypeface(null, Typeface.BOLD)
                layoutParams = LinearLayout.LayoutParams(btnWidth, LinearLayout.LayoutParams.MATCH_PARENT)
                //setPadding(10, 5, 10, 5)
                isClickable = false
            }
            buttons.add(altBtn)
            popupContainer.addView(altBtn)
        }
    }

    private fun highlightButton(index: Int) {
        buttons.forEachIndexed { i, btn ->
            btn.setBackgroundColor(if (i == index) Color.CYAN else Color.LTGRAY)
        }
    }

    private fun clearHighlight() {
        buttons.forEach { btn ->
            btn.setBackgroundColor(Color.LTGRAY)
        }
    }

    private fun findButtonUnderRaw(container: LinearLayout, buttons: List<Button>, rawX: Int, rawY: Int): Button? {
        val loc = IntArray(2)
        container.getLocationOnScreen(loc)

        buttons.forEach { btn ->
            btn.getLocationOnScreen(loc)
            val left = loc[0]
            val top = loc[1]
            val right = left + btn.width
            val bottom = top + btn.height
            if (rawX in left..right && rawY in top..bottom) {
                return btn
            }
        }
        return null
    }
}

