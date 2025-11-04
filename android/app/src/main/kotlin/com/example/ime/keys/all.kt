package com.example.ime.keys

import android.view.View
import android.view.inputmethod.InputConnection
import android.inputmethodservice.InputMethodService
import android.widget.Button
import android.widget.TextView
import android.widget.FrameLayout
import com.example.ime.R
import android.os.Handler
import android.os.Looper
import android.view.KeyEvent
import android.graphics.Color
import  android.view.MotionEvent
import android.view.View.OnTouchListener
import android.view.LayoutInflater
import android.view.ViewGroup
import android.content.Context
import android.util.AttributeSet

import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Typeface
import android.content.res.TypedArray

import android.view.HapticFeedbackConstants




// import android.view.MotionEventopen 
open class Key(val service: InputMethodService,val rootView: View,val btnId :Int) {
    val ic = service.currentInputConnection
    val screenWidth =rootView.context.resources.displayMetrics.widthPixels
    val screenHeight = rootView.context.resources.displayMetrics.heightPixels
    val longPressTimeout = 200L
    var isHoldKey = false
    var isHoldPressed = false
    val longPressHandler = Handler(android.os.Looper.getMainLooper())
    var isLongPressed = false 
    var isNotSupportLongPress = false
    var longPressRunnable = Runnable {longPressListener()}
    val btn = rootView.findViewById<Button>(btnId)
    lateinit var hintView :TextView
    val parent = btn.parent as FrameLayout
    fun keyDownAction()=btn.setBackgroundColor( Color.CYAN.toInt())
    fun keyUpAction()=btn.setBackgroundColor( 0xFF2D2D2D.toInt())
    init {
        for (i in 0 until parent.getChildCount()) {
        val child = parent.getChildAt(i)
        if (child is TextView)
        hintView = child
        }
        parent.setOnTouchListener { _, e ->
            touchListener(e)
        //false
        }
        parent.setOnClickListener {
            clickListener()
        //false
        }
        btn.isClickable=false
    }
    open fun longPressListener(){
        isLongPressed = true 
        
    }
    open fun clickListener(){}
    fun sendKeyPress(keyCode : Int) {
        val ic = service.currentInputConnection
        ic.sendKeyEvent(KeyEvent(KeyEvent.ACTION_DOWN, keyCode))
        ic.sendKeyEvent(KeyEvent(KeyEvent.ACTION_UP, keyCode))
    
        Key.runAndClearTasks()
    }
    
fun vibrate() {
    rootView.performHapticFeedback(HapticFeedbackConstants.LONG_PRESS)
}

    fun sendKeyPress(keyCode : String) {
    val ic = service.currentInputConnection

    ic.commitText(keyCode, 1)
    Key.runAndClearTasks()

    }
    
    fun sendKeyDown(keyCode : Int) {
        if(keyCode != 0){
    val ic = service.currentInputConnection
    ic.sendKeyEvent(KeyEvent(KeyEvent.ACTION_DOWN, keyCode))
        }
    keyDownAction()
    }

    fun sendKeyUp(keyCode : Int) {
    val ic = service.currentInputConnection
    ic.sendKeyEvent(KeyEvent(KeyEvent.ACTION_UP, keyCode))
    keyUpAction()
    }
    fun getSelectedText():String{
        val ic = service.currentInputConnection
        val selectedText = ic.getSelectedText(InputConnection.GET_TEXT_WITH_STYLES)
        if (selectedText != null && selectedText.isNotEmpty()) return selectedText.toString()
        return ""
    }
    open public fun touchListener(e: MotionEvent):Boolean{
        when (e.action) {
                MotionEvent.ACTION_DOWN -> {
                    isLongPressed = false
                    longPressHandler.postDelayed(longPressRunnable, longPressTimeout)
                    btn.setBackgroundColor( Color.CYAN.toInt()) 
                    isHoldKey = true
                   // return@touchListener true

                }
                MotionEvent.ACTION_UP,MotionEvent.ACTION_CANCEL -> {
                    isHoldKey = false
                    longPressHandler.removeCallbacks(longPressRunnable)
                    if(!isHoldPressed)
                    btn.setBackgroundColor(0xFF2D2D2D.toInt()) 
                    if (isLongPressed) return@touchListener true
                    
                } 
            }
        return false
    }

    public fun changeLang(current:String){
        when(current){
            "en"->{
                changeLang(R.layout.en,Key.enIds)
                currentLang="en"
                CapsLockKey(service,rootView)
            }
            "ar"->{
                changeLang(R.layout.ar,Key.arIds)
                currentLang="ar"
            }
            "nums"->{
                changeLang(R.layout.symbols,Key.numsEnIds)
                
            }
            "numeric"->{
                changeLang(R.layout.numeric,Key.numericIds,false)
                
            }
            else->{
                changeLang(R.layout.en,Key.enIds)
                currentLang="en"
                CapsLockKey(service,rootView)
            }
        
        }
        if(current != "nums"){
            Key.isNumsEnabled = false
            rootView.findViewById<Button>(R.id.keyNums).text="123"
        }
    }
   public fun changeLang(){
        val i = (Key.langs.indexOf(Key.currentLang)+1)%Key.langs.size
        changeLang( Key.langs[i])
    }
    public fun changeLang(xmlId:Int,ids :List<Int>,nums:Boolean=true){
       
        val newView =  LayoutInflater.from(rootView.context).inflate(xmlId, null)
        val partToReplace = rootView.findViewById<View>(R.id.symbols)

        val parent = partToReplace.parent as ViewGroup
        val index = parent.indexOfChild(partToReplace)
        parent.removeViewAt(index)
        parent.addView(newView, index)
        for (id in ids) {
           LetterKey(service, rootView, id)
        }
        if(nums){
            for (id in numsIds) {
           LetterKey(service, rootView, id)
        }
        }
        DeleteKey(service, rootView)
        //
    }

    fun dpToPx(dp: Float): Float {
    return  dp * rootView.context.resources.displayMetrics.density
    }

    companion object {
        var currentLang="en"
        val langs =listOf("en","ar")
        var isNumsEnabled= false
        var isNumeric = false
        public val special=listOf(0,0,0)
        val numsIds = listOf(
            R.id.key1, R.id.key2, R.id.key3, R.id.key4, R.id.key5,
            R.id.key6, R.id.key7, R.id.key8, R.id.key9, R.id.key0,
             R.id.keySim,R.id.keyDot
        )
        val btnsids = listOf(
            R.id.keyA, R.id.keyB, R.id.keyC, R.id.keyD, R.id.keyE, R.id.keyF,
            R.id.keyG, R.id.keyH, R.id.keyI, R.id.keyJ, R.id.keyK, R.id.keyL,
            R.id.keyM, R.id.keyN, R.id.keyO, R.id.keyP, R.id.keyQ, R.id.keyR,
            R.id.keyS, R.id.keyT, R.id.keyU, R.id.keyV, R.id.keyW, R.id.keyX,
            R.id.keyY, R.id.keyZ
        )
        val arIds = listOf(
            R.id.arkey0 ,R.id.arkey1, R.id.arkey2, R.id.arkey3, R.id.arkey4, R.id.arkey5,R.id.arkey6, R.id.arkey7, R.id.arkey8, R.id.arkey9,
            R.id.arkey10 ,R.id.arkey11, R.id.arkey12, R.id.arkey13, R.id.arkey14, R.id.arkey15,R.id.arkey16, R.id.arkey17, R.id.arkey18, R.id.arkey19,
            R.id.arkey20 ,R.id.arkey21, R.id.arkey22, R.id.arkey23, R.id.arkey24, R.id.arkey25,R.id.arkey26, R.id.arkey27, R.id.arkey28,
        )

        val numsEnIds = listOf(
            R.id.nkey0 ,R.id.nkey1, R.id.nkey2, R.id.nkey3, R.id.nkey4, R.id.nkey5,R.id.nkey6, R.id.nkey7, R.id.nkey8, R.id.nkey9,
            R.id.nkey10 ,R.id.nkey11, R.id.nkey12, R.id.nkey13, R.id.nkey14, R.id.nkey15,R.id.nkey16, R.id.nkey17, R.id.nkey18,
            R.id.nkey20 ,R.id.nkey21, R.id.nkey22, R.id.nkey23, R.id.nkey24, R.id.nkey25,R.id.nkey26,
        )
        val enIds = listOf(
            R.id.keyA,
            R.id.keyB, R.id.keyC, R.id.keyD, R.id.keyE, R.id.keyF,
            R.id.keyG,R.id.keyH,  R.id.keyI, R.id.keyJ, R.id.keyK, R.id.keyL,
            R.id.keyM, R.id.keyN, R.id.keyO, R.id.keyP, R.id.keyQ, R.id.keyR,
            R.id.keyS, R.id.keyT, R.id.keyU, R.id.keyV, R.id.keyW, R.id.keyX,
            R.id.keyY, R.id.keyZ,
          
        )
        val numericIds = listOf(
            R.id.nkey0 ,R.id.nkey1, R.id.nkey2, R.id.nkey3, R.id.nkey4,
            R.id.nkey10 ,R.id.nkey11, R.id.nkey12, R.id.nkey13, R.id.nkey14,
            R.id.nkey20 ,R.id.nkey21, R.id.nkey22, R.id.nkey23, R.id.nkey24,
             R.id.nkey30 ,R.id.nkey31, R.id.nkey32, R.id.nkey33,
        )
        @JvmStatic
        fun changeCapsLetters(root: View,isPressCaps :Boolean) {
            for(id in enIds){
            
                val btn = root.findViewById<Button>(id)
                var letter=btn.text.toString()
                 if (isPressCaps)
                btn.text = letter.toString().uppercase()
                 else 
                  btn.text = letter.toString().lowercase()
                  // btn.text=letter.toString().uppercase()
                }
               
        }

     private val tasks = mutableListOf<(() -> Unit)>()
    // public var disableCtrl : () -> Unit
    // دالة تضيف دالة واحدة أو مجموعة دوال
    @JvmStatic
    fun addTasks(vararg newTasks: (() -> Unit)) {
        tasks.addAll(newTasks)
    }
    
    
    
    @JvmStatic
    fun runAndClearTasks() {
        tasks.forEach{it()}
        tasks.clear()
        
    }
    public fun changeLang(service: InputMethodService,rootView: View,current:String){
        when(current){
            "en"->{
                changeLang(service,rootView,R.layout.en,Key.enIds)
                currentLang="en"
                CapsLockKey(service,rootView)
                 Key.isNumeric = false
            }
            "ar"->{
                changeLang(service,rootView,R.layout.ar,Key.arIds)
                currentLang="ar"
                 Key.isNumeric = false
            }
            "nums"->{
                changeLang(service,rootView,R.layout.symbols,Key.numsEnIds)
                 Key.isNumeric = false
            }
            "numeric"->{
                changeLang(service,rootView,R.layout.numeric,Key.numericIds,false)
                Key.isNumeric = true
                
            }
            else->{
                changeLang(service,rootView,R.layout.en,Key.enIds)
                currentLang="en"
                CapsLockKey(service,rootView)
            }
        
        }
        if(current != "nums"){
            Key.isNumsEnabled = false
            rootView.findViewById<Button>(R.id.keyNums).text="123"
        }
    }
   public fun changeLang(service: InputMethodService,rootView: View){
        val i = (Key.langs.indexOf(Key.currentLang)+1)%Key.langs.size
        changeLang(service,rootView, Key.langs[i])
    }
    public fun changeLang(service: InputMethodService,rootView: View,xmlId:Int,ids :List<Int>,nums:Boolean=true){
        val newView =  LayoutInflater.from(rootView.context).inflate(xmlId, null)
        val partToReplace = rootView.findViewById<View>(R.id.symbols)

        val parent = partToReplace.parent as ViewGroup
        val index = parent.indexOfChild(partToReplace)
        parent.removeViewAt(index)
        parent.addView(newView, index)
        for (id in ids) {
           LetterKey(service, rootView, id)
        }
        if(nums){
            for (id in numsIds) {
           LetterKey(service, rootView, id)
        }
        }
        DeleteKey(service, rootView)
    }

    
    }
}

fun sendKeyPress(service:InputMethodService , keyCode: Int) {
    val ic = service.currentInputConnection
    ic.sendKeyEvent(KeyEvent(KeyEvent.ACTION_DOWN, keyCode))
    ic.sendKeyEvent(KeyEvent(KeyEvent.ACTION_UP, keyCode))
}
fun sendKeyUp(service:InputMethodService , keyCode: Int) {
    val ic = service.currentInputConnection
    ic.sendKeyEvent(KeyEvent(KeyEvent.ACTION_UP, keyCode))
}
fun sendKeyDown(service:InputMethodService , keyCode: Int) {
    val ic = service.currentInputConnection
    ic.sendKeyEvent(KeyEvent(KeyEvent.ACTION_DOWN, keyCode))
}
