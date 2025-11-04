package com.example.ime.views

import android.content.Context
import android.util.AttributeSet
import android.graphics.Color
import android.graphics.Typeface
import android.view.MotionEvent
import android.view.View
import android.widget.Button
import android.widget.LinearLayout
import com.example.ime.FlutterIME
import com.example.ime.R
import com.example.ime.views.Key

class Letter
@JvmOverloads
constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyle: Int = android.R.attr.buttonStyle
) : Key(context, attrs, defStyle) {
    
    val popupBtns = mutableListOf<Button>()
    var isPopupVisible = false
    var selectedIndex = 0
    var autoHidePopup = true
    lateinit var popupContainer: LinearLayout
    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        popupContainer = FlutterIME.ime.rootView.findViewById<LinearLayout>(R.id.altPopupContainer)
    }
    override fun actionUp(e: MotionEvent): Boolean {
        super.actionUp(e)
        if (isPopupVisible && autoHidePopup) {
            if (popupKeys.isNotEmpty() && selectedIndex in popupKeys.indices) {
                FlutterIME.ime.sendKeyPress(popupKeys[selectedIndex].toString())
                onKeyPress()
            }
            popupContainer.visibility = View.GONE
            isPopupVisible = false
            popupBtns.clear()
            selectedIndex = 0
            isLongPressed = false
            EmojiView.isScrollable.value = false
            return true
        }
        return false
    }
    override fun actionMove(e: MotionEvent): Boolean {
        if (isPopupVisible && autoHidePopup) {
            val x = e.rawX.toInt()
            val y = popupBtns.getOrNull(0)?.let {
                val loc = IntArray(2)
                it.getLocationOnScreen(loc)
                loc[1] + it.height / 2
            } ?: 0
            val btnUnder = findButtonUnderRaw(x, y)
            val newIndex = popupBtns.indexOf(btnUnder)
            if (newIndex != selectedIndex) {
                selectedIndex = newIndex
                highlightButton(selectedIndex)
            }
        }
        return true
    }
    init {
       val params = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.MATCH_PARENT, 1f)
        layoutParams = params
        Key.capslock.addListener { 
            var value = it ?: 0
            if (value != 0) {
                text = text.uppercase()
            } else {
                text = text.lowercase()
            }
        }
    }
    override fun onLongPress() {
        super.onLongPress()
        if (popupKeys.isEmpty()) return
         EmojiView.isScrollable.value = true
        isPopupVisible = true
        showAltChars()
        selectedIndex = 0
        highlightButton(selectedIndex)
    }
    private fun showAltChars() {
        popupContainer.removeAllViews()
        popupContainer.setBackgroundColor(Color.WHITE)
        popupContainer.visibility = View.VISIBLE
        val rootViewLoc = IntArray(2)
        val btnLoc = IntArray(2)
        getLocationOnScreen(btnLoc)
        FlutterIME.ime.rootView.getLocationOnScreen(rootViewLoc)
        popupWidth = (btnWidth * popupKeys.size).toFloat()
        val y = btnLoc[1] - rootViewLoc[1] - dpToPx(48f)
        val x = if (btnLoc[0] + popupWidth + dpToPx(3f) < screenWidth) btnLoc[0].toFloat()
            else btnLoc[0] - popupWidth + btnWidth
        popupContainer.x = x
        popupContainer.y = y.toFloat()
        popupBtns.clear()
        popupKeys.forEach { altChar ->
            val altBtn = Button(context).apply {
                text = altChar.toString().lowercase()
                setPadding(0, 5, 0, 5)
                setTypeface(null, Typeface.BOLD)
                layoutParams = LinearLayout.LayoutParams(btnWidth, LinearLayout.LayoutParams.MATCH_PARENT)
                setOnClickListener {
                    FlutterIME.ime.sendKeyPress(altChar.toString())
                    onKeyPress()
                    popupContainer.visibility = View.GONE
                    isPopupVisible = false
                    popupBtns.clear()
                    selectedIndex = 0
                    isLongPressed = false
                    EmojiView.isScrollable.value = false
                }
            }
            popupBtns.add(altBtn)
            popupContainer.addView(altBtn)
        }
    }
    private fun highlightButton(index: Int) {
        popupBtns.forEachIndexed { i, btn ->
            btn.setBackgroundColor(if (i == index) Color.CYAN else Color.LTGRAY)
        }
    }
    private fun clearHighlight() {
        popupBtns.forEach { btn -> btn.setBackgroundColor(Color.LTGRAY) }
    }
    private fun findButtonUnderRaw(rawX: Int, rawY: Int): Button? {
        val loc = IntArray(2)
        popupBtns.forEach { btn ->
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
    override fun onClick() {
        FlutterIME.ime.sendKeyPress(text)
        super.onClick()
    }
}

class Letter1
@JvmOverloads
constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyle: Int = android.R.attr.buttonStyle
) : Key(context, attrs, defStyle) {
    
    val popupBtns = mutableListOf<Key>()
    var isPopupVisible = false
    var selectedIndex = 0
    var autoHidePopup = true
    lateinit var popupContainer: LinearLayout
    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        popupContainer = FlutterIME.ime.rootView.findViewById<LinearLayout>(R.id.altPopupContainer)
    }
    override fun actionUp(e: MotionEvent): Boolean {
        super.actionUp(e)
        if (isPopupVisible && autoHidePopup) {
            if (popupBtns.isNotEmpty() && selectedIndex in popupBtns.indices) {
                popupBtns[selectedIndex].onClick()
                onKeyPress()
            }
            popupContainer.visibility = View.GONE
            isPopupVisible = false
            // popupBtns.clear()
            selectedIndex = 0
            isLongPressed = false
            EmojiView.isScrollable.value = false
            return true
        }
        return false
    }
    override fun actionMove(e: MotionEvent): Boolean {
        if (isPopupVisible && autoHidePopup) {
            val x = e.rawX.toInt()
            val y = popupBtns.getOrNull(0)?.let {
                val loc = IntArray(2)
                it.getLocationOnScreen(loc)
                loc[1] + it.height / 2
            } ?: 0
            val btnUnder = findButtonUnderRaw(x, y)
            val newIndex = popupBtns.indexOf(btnUnder)
            if (newIndex != selectedIndex) {
                selectedIndex = newIndex
                highlightButton(selectedIndex)
            }
        }
        return true
    }
    init {
       
        Key.capslock.addListener { 
            var value = it ?: 0
            if (value != 0) {
                text = text.uppercase()
            } else {
                text = text.lowercase()
            }
        }
    }
    override fun onLongPress() {
        super.onLongPress()
        if (popupBtns.isEmpty()) return
         EmojiView.isScrollable.value = true
        isPopupVisible = true
        showAltChars()
        selectedIndex = 0
        highlightButton(selectedIndex)
    }
    private fun showAltChars() {
        popupContainer.removeAllViews()
        popupContainer.setBackgroundColor(Color.WHITE)
        popupContainer.visibility = View.VISIBLE
        val rootViewLoc = IntArray(2)
        val btnLoc = IntArray(2)
        getLocationOnScreen(btnLoc)
        FlutterIME.ime.rootView.getLocationOnScreen(rootViewLoc)
        popupWidth = (btnWidth * popupBtns.size).toFloat()
        val y = btnLoc[1] - rootViewLoc[1] - dpToPx(48f)
        val x = if (btnLoc[0] + popupWidth + dpToPx(3f) < screenWidth) btnLoc[0].toFloat()
            else btnLoc[0] - popupWidth + btnWidth
        popupContainer.x = x
        popupContainer.y = y.toFloat()
        //popupContainer.layoutParams.width= popupWidth.toInt()
        //popupContainer.requestLayout()
        // popupBtns.clear()
        popupBtns.forEach { altBtn ->
            altBtn.layoutParams.width = btnWidth
            popupContainer.addView(altBtn)
        }
    }
    private fun highlightButton(index: Int) {
        popupBtns.forEachIndexed { i, btn ->
            btn.setBackgroundColor(if (i == index) Color.CYAN else Color.LTGRAY)
        }
    }
    private fun clearHighlight() {
        popupBtns.forEach { btn -> btn.setBackgroundColor(Color.LTGRAY) }
    }
    private fun findButtonUnderRaw(rawX: Int, rawY: Int): Key? {
        val loc = IntArray(2)
        popupBtns.forEach { btn ->
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
    override fun onClick() {
        FlutterIME.ime.sendKeyPress(text)
        super.onClick()
    }
}
