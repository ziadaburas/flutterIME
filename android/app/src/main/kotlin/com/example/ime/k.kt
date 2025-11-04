// package com.example.ime.views

// import android.content.ClipData
// import android.content.ClipboardManager
// import android.content.Context
// import android.graphics.Canvas
// import android.graphics.Color
// import android.graphics.Paint
// import android.graphics.Typeface
// import android.os.Handler
// import android.os.Looper
// import android.util.AttributeSet
// import android.util.TypedValue
// import android.view.Gravity
// import android.view.HapticFeedbackConstants
// import android.view.KeyEvent
// import android.view.MotionEvent
// import android.view.View
// import android.widget.Button
// import android.widget.FrameLayout
// import android.widget.ImageView
// import android.widget.LinearLayout
// import android.widget.ScrollView
// import android.widget.TextView
// import com.example.ime.FlutterIME
// import com.example.ime.R
// import com.example.ime.clipboard.*

// open class Key
// @JvmOverloads
// constructor(
//         context: Context,
//         attrs: AttributeSet? = null,
//         defStyle: Int = android.R.attr.buttonStyle
// ) : FrameLayout(context, attrs, defStyle) {
//     val screenWidth = context.resources.displayMetrics.widthPixels
//     val screenHeight = context.resources.displayMetrics.heightPixels
//     var hint = ""
//     var btnWidth = 0
//     private var mainText: String = ""
//     private var topRightText: String = ""
//     val longPressTimeout = 200L
//     var isHoldKey = false
//     var isHoldPressed = false
//     val longPressHandler = Handler(Looper.getMainLooper())
//     var isLongPressed = false
//     var isSpecialKey = false
//     var longPressRunnable = Runnable { onLongPress() }
//     var bgColor: Int = 0xFF2D2D2D.toInt()
//     var text = ""
//         set(value) {
//             field = value
//             invalidate()
//         }
//     var inset = 0f
//     var keyWidth = 0
//     var keyHeight = -1
//     var keyWeight = 1f
//     private val topRightPaint =
//             Paint().apply {
//                 color = 0xFFAAAAAA.toInt()
//                 textAlign = Paint.Align.RIGHT
//                 textSize = spToPx(10f)
//                 isAntiAlias = true
//             }
//     companion object {
//         val capslock = ValueListener(0)
//         val ctrl = ValueListener(0)
//         val alt = ValueListener(0)
//         val shift = ValueListener(0)
//         val keyPress = ValueListener("")
//         val isSymbols = ValueListener(false)
//         // val keyPress = ObservableBoolean(false)
//     }

//     init {
//         initAttributes(attrs)
//         //     post {
//         //     if (layoutParams == null) {
//         //         layoutParams = LinearLayout.LayoutParams(0,-1,1f)
//         //     }
//         // }
//         //text = tag.toString()
//         inset = dpToPx(2f)
//         hint = contentDescription.toString().replace(" ", "")
//         background = null
//         setWillNotDraw(false)
//         // setBackgroundColor(Color.TRANSPARENT)
//         // Key.keyPress.addOnChangeListener { newValue ->
//         //     onKeyPress()
//         //     // invalidate()
//         // }
//     }
//     private fun initAttributes(attrs: AttributeSet?) {
//         if (attrs == null) return
//         val ta = context.obtainStyledAttributes(attrs, R.styleable.keyAttrs)
//         try {
//             text = ta.getString(R.styleable.keyAttrs_text) ?: tag.toString()
//         } finally {
//             ta.recycle()
//         }
//         // invalidate()
//     }
//     override fun onAttachedToWindow() {
//         super.onAttachedToWindow()
//         // layoutParams = LinearLayout.LayoutParams(keyWidth,keyHeight,keyWeight)

//     }
//     open fun onKeyPress() {
//         if ((Key.capslock.value ?: 1) != 2) Key.capslock.value = 0
//         if ((Key.ctrl.value ?: 1) != 2) Key.ctrl.value = 0
//         if ((Key.alt.value ?: 1) != 2) Key.alt.value = 0
//         if ((Key.shift.value ?: 1) != 2) Key.shift.value = 0
//     }
//     open fun onClick() {
//         onKeyPress()
//     }
//     open fun onLongPress() {
//         isLongPressed = true
//     }

//     override fun onDraw(canvas: Canvas) {
//         super.onDraw(canvas)
//         canvas.drawColor(Color.TRANSPARENT)

//         val rectPaint =
//                 Paint().apply {
//                     color = bgColor
//                     style = Paint.Style.FILL
//                 }

//         canvas.drawRect(inset, inset, width.toFloat() - inset, height.toFloat() - inset, rectPaint)
//         val textPaint =
//                 Paint().apply {
//                     color = Color.WHITE
//                     textSize = spToPx(18f) // * resources.displayMetrics.density
//                     textAlign = Paint.Align.CENTER
//                     isAntiAlias = true
//                     typeface = Typeface.DEFAULT_BOLD
//                 }

//         val centerX = width / 2f
//         val centerY = (height / 2f - (textPaint.descent() + textPaint.ascent()) / 2)

//         canvas.drawText(text.toString(), centerX, centerY, textPaint)
//         val fm = topRightPaint.fontMetrics
//         val y = inset - fm.ascent

//         val topTextX = width.toFloat() - 2 * inset // - dpToPx(hint.length.toFloat() * 2) // *
//         // resources.displayMetrics.density
//         canvas.drawText(
//                 contentDescription.toString().split(" ").take(2).joinToString(""),
//                 topTextX,
//                 y,
//                 topRightPaint
//         )
//         // }
//         super.onDraw(canvas)
//     }
//     override fun setBackgroundColor(color: Int) {
//         super.setBackgroundColor(Color.TRANSPARENT)

//         bgColor = color
//         invalidate()
//     }
//     override fun setTag(t: Any) {
//         super.setTag(t)
//         invalidate()
//     }
//     open fun actionDown(e: MotionEvent): Boolean {
//         isLongPressed = false
//         longPressHandler.postDelayed(longPressRunnable, longPressTimeout)
//         // bgColor= Color.CYAN.toInt()
//         // invalidate()
//         isHoldKey = true
//         setBackgroundColor(Color.CYAN.toInt())
//         return true
//     }
//     open fun actionUp(e: MotionEvent): Boolean {
//         isHoldKey = false
//         longPressHandler.removeCallbacks(longPressRunnable)
//         if (!isSpecialKey) setBackgroundColor(0xFF2D2D2D.toInt())
//         if (!isActionUp(e.rawX.toInt(), e.rawY.toInt())) return false
//         // if(!isHoldPressed)
//         // bgColor = 0xFF2D2D2D.toInt()
//         // invalidate()
//         val pressDuration = e.eventTime - e.downTime
//         if (pressDuration < longPressTimeout) {
//             onClick()
//         }

//         // if (isLongPressed) return@touchListener true
//         return false
//     }
//     open fun actionMove(e: MotionEvent): Boolean {
//         return false
//     }
//     override fun onTouchEvent(e: MotionEvent): Boolean {
//         super.onTouchEvent(e)
//         return when (e.action) {
//             MotionEvent.ACTION_DOWN -> {
//                 actionDown(e)
//             }
//             MotionEvent.ACTION_MOVE -> {
//                 actionMove(e)
//             }
//             MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
//                 actionUp(e)
//             }
//             else -> false
//         }
//         // return false
//     }
//     // open public fun onTouch(e: MotionEvent):Boolean{
//     //     return false
//     // }
//     fun isActionUp(x: Int, y: Int): Boolean {
//         val loc = IntArray(2)
//         getLocationOnScreen(loc)
//         val left = loc[0]
//         val top = loc[1]
//         val right = left + width
//         val bottom = top + height
//         return (x in left..right && y in top..bottom)
//     }
//     fun dpToPx(dp: Float): Float {
//         return dp * rootView.context.resources.displayMetrics.density
//     }
//     fun spToPx(sp: Float): Float =
//             TypedValue.applyDimension(
//                     TypedValue.COMPLEX_UNIT_SP,
//                     sp,
//                     context.resources.displayMetrics
//             )
//     override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
//         super.onSizeChanged(w, h, oldw, oldh)
//         btnWidth = w
//     }
// }

// class Letter
// @JvmOverloads
// constructor(
//         context: Context,
//         attrs: AttributeSet? = null,
//         defStyle: Int = android.R.attr.buttonStyle
// ) : Key(context, attrs, defStyle) {

//     var popupKeys: List<String> = emptyList()
//     val popupBtns = mutableListOf<Button>()
//     var isPopupVisible = false
//     var selectedIndex = 0
//     lateinit var popupContainer: LinearLayout
//     var popupWidth = 0f
//     override fun onAttachedToWindow() {
//         super.onAttachedToWindow()
//         popupContainer = FlutterIME.ime.rootView.findViewById<LinearLayout>(R.id.altPopupContainer)
//     }

//     override fun actionUp(e: MotionEvent): Boolean {
//         super.actionUp(e)
//         if (isPopupVisible) {
//             if (popupKeys.isNotEmpty() && selectedIndex in popupKeys.indices) {
//                 FlutterIME.ime.sendKeyPress(popupKeys[selectedIndex].toString())
//                 onKeyPress()
//             }
//             popupContainer.visibility = View.GONE
//             isPopupVisible = false
//             popupBtns.clear()
//             selectedIndex = 0
//             isLongPressed = false
//             return true
//         }
//         return false
//     }
//     override fun actionMove(e: MotionEvent): Boolean {
//         if (isPopupVisible) {
//             val x = e.rawX.toInt()
//             val y =
//                     popupBtns.getOrNull(0)?.let {
//                         val loc = IntArray(2)
//                         it.getLocationOnScreen(loc)
//                         loc[1] + it.height / 2
//                     }
//                             ?: 0

//             val btnUnder = findButtonUnderRaw(x, y)
//             val newIndex = popupBtns.indexOf(btnUnder)
//             if (newIndex != selectedIndex) {
//                 selectedIndex = newIndex
//                 highlightButton(selectedIndex)
//             }
//         }
//         return true
//     }

//     init {
//         val popup = contentDescription.toString()
//         popupKeys = if (popup.length != 0) popup.split(" ") else emptyList()
//         popupWidth = (btnWidth * popupKeys.size).toFloat()
//         Key.capslock.addListener {
//             var value = it ?: 0
//             if (value != 0) {
//                 text = text.uppercase()
//             } else {
//                 text = text.lowercase()
//             }
//         }
//     }

//     override fun onLongPress() {
//         super.onLongPress()
//         if (popupKeys.isEmpty()) return
//         isPopupVisible = true
//         showAltChars()
//         selectedIndex = 0
//         highlightButton(selectedIndex)
//     }

//     private fun showAltChars() {
//         popupContainer.removeAllViews()
//         popupContainer.setBackgroundColor(Color.WHITE)
//         popupContainer.visibility = View.VISIBLE
//         val rootViewLoc = IntArray(2)
//         val btnLoc = IntArray(2)
//         getLocationOnScreen(btnLoc)
//         FlutterIME.ime.rootView.getLocationOnScreen(rootViewLoc)
//         popupWidth = (btnWidth * popupKeys.size).toFloat()

//         val y = btnLoc[1] - rootViewLoc[1] - dpToPx(48f)
//         val x =
//                 if (btnLoc[0] + popupWidth + dpToPx(3f) < screenWidth) btnLoc[0].toFloat()
//                 else btnLoc[0] - popupWidth + btnWidth // - altChars.size*16;
//         popupContainer.x = x
//         popupContainer.y = y.toFloat() // (currentRow.parent as View).y-btn.height-16 hhنUنD

//         popupBtns.clear()
//         popupKeys.forEach { altChar ->
//             val altBtn =
//                     Button(context).apply {
//                         text = altChar.toString().lowercase()
//                         setPadding(0, 5, 0, 5)
//                         setTypeface(null, Typeface.BOLD)
//                         layoutParams =
//                                 LinearLayout.LayoutParams(
//                                         btnWidth,
//                                         LinearLayout.LayoutParams.MATCH_PARENT
//                                 )
//                         isClickable = false
//                     }
//             popupBtns.add(altBtn)
//             popupContainer.addView(altBtn)
//         }
//     }
//     private fun highlightButton(index: Int) {
//         popupBtns.forEachIndexed { i, btn ->
//             btn.setBackgroundColor(if (i == index) Color.CYAN else Color.LTGRAY)
//         }
//     }

//     private fun clearHighlight() {
//         popupBtns.forEach { btn -> btn.setBackgroundColor(Color.LTGRAY) }
//     }

//     private fun findButtonUnderRaw(rawX: Int, rawY: Int): Button? {
//         val loc = IntArray(2)

//         popupBtns.forEach { btn ->
//             btn.getLocationOnScreen(loc)
//             val left = loc[0]
//             val top = loc[1]
//             val right = left + btn.width
//             val bottom = top + btn.height
//             if (rawX in left..right && rawY in top..bottom) {
//                 return btn
//             }
//         }
//         return null
//     }

//     override fun onClick() {
//         FlutterIME.ime.sendKeyPress(tag.toString())
//         super.onClick()
//     }
// }

// open class LoopKey
// @JvmOverloads
// constructor(
//         context: Context,
//         attrs: AttributeSet? = null,
//         defStyle: Int = android.R.attr.buttonStyle
// ) : Key(context, attrs, defStyle) {
//     lateinit var fn: (() -> Unit)
//     init {
//         fn = {}
//     }
//     override fun onLongPress() {
//         super.onLongPress()
//         if (isHoldKey) {
//             onClick()
//             longPressHandler.postDelayed(longPressRunnable, 50)
//         }
//     }
//     override fun onClick() {
//         fn()
//         super.onClick()
//     }
// }

// class LeftKey
// @JvmOverloads
// constructor(
//         context: Context,
//         attrs: AttributeSet? = null,
//         defStyle: Int = android.R.attr.buttonStyle
// ) : LoopKey(context, attrs, defStyle) {

//     init {
//         tag = "←"
//         fn = { FlutterIME.ime.sendKeyPress(KeyEvent.KEYCODE_DPAD_LEFT) }
//     }
// }

// class RightKey
// @JvmOverloads
// constructor(
//         context: Context,
//         attrs: AttributeSet? = null,
//         defStyle: Int = android.R.attr.buttonStyle
// ) : LoopKey(context, attrs, defStyle) {

//     init {
//         tag = "→"
//         fn = { FlutterIME.ime.sendKeyPress(KeyEvent.KEYCODE_DPAD_RIGHT) }
//     }
// }

// open class TowFnKey
// @JvmOverloads
// constructor(
//         context: Context,
//         attrs: AttributeSet? = null,
//         defStyle: Int = android.R.attr.buttonStyle
// ) : Key(context, attrs, defStyle) {
//     open var fn1: (() -> Unit) = {}
//     open var fn2: (() -> Unit) = {}

//     override fun onLongPress() {
//         super.onLongPress()

//         performHapticFeedback(HapticFeedbackConstants.LONG_PRESS)
//         fn2()
//     }
//     override fun onClick() {
//         fn1()
//         super.onClick()
//     }
// }

// class UpKey
// @JvmOverloads
// constructor(
//         context: Context,
//         attrs: AttributeSet? = null,
//         defStyle: Int = android.R.attr.buttonStyle
// ) : TowFnKey(context, attrs, defStyle) {

//     init {
//         //tag = "↑"
//         fn1 = { FlutterIME.ime.sendKeyPress(KeyEvent.KEYCODE_DPAD_UP) }
//         fn2 = { FlutterIME.ime.sendKeyPress(KeyEvent.KEYCODE_MOVE_HOME) }
//     }
// }

// class DownKey
// @JvmOverloads
// constructor(
//         context: Context,
//         attrs: AttributeSet? = null,
//         defStyle: Int = android.R.attr.buttonStyle
// ) : TowFnKey(context, attrs, defStyle) {

//     init {
//        // tag = "↓"
//         fn1 = { FlutterIME.ime.sendKeyPress(KeyEvent.KEYCODE_DPAD_DOWN) }
//         fn2 = { FlutterIME.ime.sendKeyPress(KeyEvent.KEYCODE_MOVE_END) }
//     }
// }

// class ObservableBoolean(initialValue: Boolean = false) {
//     private val listeners = mutableListOf<(Boolean) -> Unit>()

//     var value: Boolean = initialValue
//         set(newValue) {
//             if (field != newValue) {
//                 field = newValue
//                 listeners.forEach { it.invoke(newValue) }
//             }
//         }

//     fun addOnChangeListener(listener: (Boolean) -> Unit) {
//         listeners.add(listener)
//     }

//     fun removeOnChangeListener(listener: (Boolean) -> Unit) {
//         listeners.remove(listener)
//     }

//     fun clearListeners() {
//         listeners.clear()
//     }
// }

// abstract class Special
// @JvmOverloads
// constructor(
//         context: Context,
//         attrs: AttributeSet? = null,
//         defStyle: Int = android.R.attr.buttonStyle
// ) : Key(context, attrs, defStyle) {
//     open val keyCode = 0
//     abstract val listener: ValueListener<Int>
//     open public fun disable() {
//         FlutterIME.ime.sendKeyUp(keyCode)
//         listener.value = 0
//         setBackgroundColor(0xFF2D2D2D.toInt())
//     }

//     open public fun enable(hold: Int = 0) {
//         listener.value = hold + 1
//         FlutterIME.ime.sendKeyDown(keyCode)
//     }
//     override fun onLongPress() {
//         performHapticFeedback(HapticFeedbackConstants.LONG_PRESS)
//         super.onLongPress()
//         enable(1)
//     }
//     override fun onClick() {
//         // super.onClick()
//         if ((listener.value ?: 1) != 0) disable() else enable()
//     }
//     init {
//         isSpecialKey = true
//     }
//     open fun init() {
//         listener.addListener {
//             var value = it ?: 0
//             if (value == 0) {
//                 disable()
                
//             }
//         }
//     }
// }

// class ValueListener<T : Any?> private constructor(private var _value: T?) {
//     private val listeners = mutableListOf<(T?) -> Unit>()

//     var value: T?
//         get() = _value
//         set(newValue) {
//             if (_value != newValue) {
//                 _value = newValue
//                 notifyListeners(newValue)
//             }
//         }

//     fun addListener(listener: (T?) -> Unit) {
//         listeners.add(listener)
//     }

//     fun removeListener(listener: (T?) -> Unit) {
//         listeners.remove(listener)
//     }

//     fun clearListeners() {
//         listeners.clear()
//     }

//     fun notifyListeners() {
//         notifyListeners(_value)
//     }

//     private fun notifyListeners(value: T?) {
//         listeners.forEach { it.invoke(value) }
//     }

//     companion object {
//         // factory function بدون Generic:
//         operator fun invoke(): ValueListener<Any?> = ValueListener(null)

//         // factory function مع قيمة:
//         operator fun <T : Any?> invoke(initialValue: T?): ValueListener<T> =
//                 ValueListener(initialValue)
//     }
// }

// open class Ctrl
// @JvmOverloads
// constructor(
//         context: Context,
//         attrs: AttributeSet? = null,
//         defStyle: Int = android.R.attr.buttonStyle
// ) : Special(context, attrs, defStyle) {
//     override var listener = Key.ctrl
//     override fun init() {

//         keyCode = KeyEvent.KEYCODE_CTRL_LEFT
//         listener = Key.ctrl
//     }
// }

// open class Alt
// @JvmOverloads
// constructor(
//         context: Context,
//         attrs: AttributeSet? = null,
//         defStyle: Int = android.R.attr.buttonStyle
// ) : Special(context, attrs, defStyle) {
//     override var listener = Key.alt
//     override fun init() {
//         keyCode = KeyEvent.KEYCODE_ALT_LEFT
//         listener = Key.alt
//     }
// }

// open class Shift
// @JvmOverloads
// constructor(
//         context: Context,
//         attrs: AttributeSet? = null,
//         defStyle: Int = android.R.attr.buttonStyle
// ) : Special(context, attrs, defStyle) {
//     override var listener = Key.shift
//     override fun init() {
//         keyCode = KeyEvent.KEYCODE_SHIFT_LEFT
//         listener = Key.shift
//     }
// }

// open class Capslock
// @JvmOverloads
// constructor(
//         context: Context,
//         attrs: AttributeSet? = null,
//         defStyle: Int = android.R.attr.buttonStyle
// ) : Special(context, attrs, defStyle) {
    
//     override fun init() {
//         listener = Key.capslock
//     }
//     override fun onAttachedToWindow() {
//         super.onAttachedToWindow()
//         tag = "⇧"
//         // layoutParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.MATCH_PARENT,1.5f)
//     }
// }

// class Delete
// @JvmOverloads
// constructor(
//         context: Context,
//         attrs: AttributeSet? = null,
//         defStyle: Int = android.R.attr.buttonStyle
// ) : LoopKey(context, attrs, defStyle) {

//     override fun onClick() {
//         FlutterIME.ime.delete() 
//         super.onClick()
//     }  
// }

// open class NormalKey
// @JvmOverloads
// constructor(
//         context: Context,
//         attrs: AttributeSet? = null,
//         defStyle: Int = android.R.attr.buttonStyle
// ) : Key(context, attrs, defStyle) {
//     open var keyCode = 0
    
//     override fun onClick() {
//         FlutterIME.ime.sendKeyPress(keyCode)
//         super.onClick()
//     }
// }

// open class Enter
// @JvmOverloads
// constructor(
//         context: Context,
//         attrs: AttributeSet? = null,
//         defStyle: Int = android.R.attr.buttonStyle
// ) : NormalKey(context, attrs, defStyle) {
//     override var keyCode = KeyEvent.KEYCODE_ENTER

//     override fun onAttachedToWindow() {
//         super.onAttachedToWindow()
//         tag = "⏎"
//         layoutParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.MATCH_PARENT, 1.5f)
//     }
// }

// open class Tab
// @JvmOverloads
// constructor(
//         context: Context,
//         attrs: AttributeSet? = null,
//         defStyle: Int = android.R.attr.buttonStyle
// ) : NormalKey(context, attrs, defStyle) {
//     override var keyCode = KeyEvent.KEYCODE_TAB

//     override fun onAttachedToWindow() {
//         super.onAttachedToWindow()
//         // layoutParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.MATCH_PARENT,1.5f)

//         tag = "⇥"
//     }
// }

// open class Space
// @JvmOverloads
// constructor(
//         context: Context,
//         attrs: AttributeSet? = null,
//         defStyle: Int = android.R.attr.buttonStyle
// ) : NormalKey(context, attrs, defStyle) {
//     override var keyCode = KeyEvent.KEYCODE_SPACE
//     var touchStartX = 0f
//     var offset = 0
//     override fun onAttachedToWindow() {
//         super.onAttachedToWindow()
//         layoutParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.MATCH_PARENT, 3f)

//         tag = "SPACE"
//     }
//     override fun actionDown(e: MotionEvent): Boolean {
//         super.actionDown(e)
//         touchStartX = e.x
//         offset = 0
//         return true
//     }
//     override fun actionMove(e: MotionEvent): Boolean {
//         super.actionMove(e)
//         offset = Math.abs(e.x - touchStartX).toInt()
//         return true
//     }
//     override fun actionUp(e: MotionEvent): Boolean {
//         super.actionUp(e)
//         if (offset > (btnWidth / 2)) post { FlutterIME.ime.switchLang() }
//         return true
//     }
// }

// open class Clip
// @JvmOverloads
// constructor(
//         context: Context,
//         attrs: AttributeSet? = null,
//         defStyle: Int = android.R.attr.buttonStyle
// ) : Key(context, attrs, defStyle) {
   
//     init {
//         val img =
//                 ImageView(context).apply {
//                     setImageResource(R.drawable.ic_clipboard)
//                     val params =
//                             FrameLayout.LayoutParams(LayoutParams.MATCH_PARENT, dpToPx(35f).toInt())
//                     params.gravity = Gravity.CENTER
//                     layoutParams = params
//                     setBackgroundColor(Color.TRANSPARENT)
//                 }
//         addView(img)
//     }
//     override fun onClick() {
//         super.onClick()
//         var clip = FlutterIME.ime.rootView.findViewById<ClipboardView>(R.id.clipboard)
//         clip.refresh()
//         clip.visibility = View.VISIBLE
    
//     }
// }

// open class ClipboardView
// @JvmOverloads
// constructor(
//         context: Context,
//         attrs: AttributeSet? = null,
//         defStyle: Int = android.R.attr.buttonStyle
// ) : LinearLayout(context, attrs, defStyle) {
//     var closeBtn: Button
//     var topRow: LinearLayout
//     var scrollContainer: LinearLayout
//     var scrollView: ScrollView
//     var dialog: LinearLayout
//     var closeDialogBtn: Button
//     var goToTopBtn: Button
//     var goToDownBtn: Button
//     var goToSettingsBtn: Button

//     var copyDialogBtn: Button
//     var deleteDialogBtn: Button
//     var pinDialogBtn: Button
//     var showMoreItemsBtn: Button
//     var bottomRowDialog: LinearLayout
//     var textViewDialog: TextView
//     val clipboardDB = ClipboardDbHelper(context)
//     var itemsPerPage = 30
//     var currentOffset = 0
//     init {
//         // val params
//         // =LinearLayout.LayoutParams(LayoutParams.MATCH_PARENT,FlutterIME.ime.rootView.height)
//         // layoutParams = params
//         visibility = View.GONE
//         orientation = VERTICAL

//         topRow =
//                 LinearLayout(context).apply {
//                     setBackgroundColor(0xFF121212.toInt())
//                     orientation = LinearLayout.HORIZONTAL
//                     val params =
//                             LinearLayout.LayoutParams(
//                                     LinearLayout.LayoutParams.MATCH_PARENT,
//                                     LinearLayout.LayoutParams.WRAP_CONTENT
//                             )
//                     params.gravity = Gravity.TOP
//                     layoutParams = params
//                 }
//         closeBtn =
//                 Button(context).apply {
//                     setTextColor(Color.WHITE)
//                     setPadding(0, 0, 0, 0)
//                     text = "\u2716"
//                     val params = LinearLayout.LayoutParams(0, dpToPx(30f).toInt(), 1f)
//                     params.gravity = Gravity.CENTER
//                     layoutParams = params
//                     setOnClickListener { hide() }
//                 }
//         goToTopBtn =
//                 Button(context).apply {
//                     setTextColor(Color.WHITE)
//                     setPadding(0, 0, 0, 0)
//                     text = "\u25b2"
//                     val params = LinearLayout.LayoutParams(0, dpToPx(30f).toInt(), 1f)
//                     params.gravity = Gravity.CENTER
//                     layoutParams = params
//                     setOnClickListener { scrollView.fullScroll(View.FOCUS_UP) }
//                 }
//         goToDownBtn =
//                 Button(context).apply {
//                     setTextColor(Color.WHITE)
//                     setPadding(0, 0, 0, 0)
//                     text = "\u25bc"
//                     val params = LinearLayout.LayoutParams(0, dpToPx(30f).toInt(), 1f)
//                     params.gravity = Gravity.CENTER
//                     layoutParams = params
//                     setOnClickListener { scrollView.fullScroll(View.FOCUS_DOWN) }
//                 }
//         goToSettingsBtn =
//                 Button(context).apply {
//                     setTextColor(Color.WHITE)
//                     setPadding(0, 0, 0, 0)
//                     text = "\u2699"
//                     val params = LinearLayout.LayoutParams(0, dpToPx(30f).toInt(), 1f)
//                     params.gravity = Gravity.CENTER
//                     layoutParams = params
//                     setOnClickListener { hide() }
//                 }
//         topRow.addView(goToSettingsBtn)
//         topRow.addView(goToDownBtn)
//         topRow.addView(goToTopBtn)
//         topRow.addView(closeBtn)
//         this.addView(topRow)

//         scrollView =
//                 ScrollView(context).apply {
//                     setPadding(0, 0, 0, 0)
//                     val params =
//                             LinearLayout.LayoutParams(
//                                     LinearLayout.LayoutParams.MATCH_PARENT,
//                                     LinearLayout.LayoutParams.MATCH_PARENT,
//                             )
//                     params.gravity = Gravity.TOP
//                     layoutParams = params
//                 }
//         scrollContainer =
//                 LinearLayout(context).apply {
//                     orientation = LinearLayout.VERTICAL
//                     setPadding(0, 0, 0, 0)
//                     val params =
//                             LinearLayout.LayoutParams(
//                                     LinearLayout.LayoutParams.MATCH_PARENT,
//                                     LinearLayout.LayoutParams.WRAP_CONTENT
//                             )
//                     params.gravity = Gravity.TOP
//                     layoutParams = params
//                 }

//         scrollView.addView(scrollContainer)
//         this.addView(scrollView)
//         showMoreItemsBtn =
//                 Button(context).apply {
//                     setTextColor(Color.WHITE)
//                     setPadding(0, 0, 0, 0)
//                     setBackgroundColor(0xFF121212.toInt())
//                     val params =
//                             LinearLayout.LayoutParams(
//                                     LinearLayout.LayoutParams.MATCH_PARENT,
//                                     dpToPx(50f).toInt(),
//                                     1f
//                             )
//                     // params.gravity=Gravity.CENTER
//                     params.setMargins(0, 5, 0, 5)
//                     layoutParams = params
//                 }
//         closeDialogBtn =
//                 Button(context).apply {
//                     text = "اغلاق"
//                     setTextColor(Color.WHITE)
//                     setBackgroundColor(0xFF2D2D2D.toInt())
//                     val params =
//                             LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.MATCH_PARENT, 1f)
//                     params.setMargins(5, 5, 5, 5)
//                     layoutParams = params
//                     setOnClickListener { hideDialog() }
//                 }
//         copyDialogBtn =
//                 Button(context).apply {
//                     text = "نسخ"
//                     setTextColor(Color.WHITE)
//                     setBackgroundColor(0xFF2D2D2D.toInt())
//                     val params =
//                             LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.MATCH_PARENT, 1f)
//                     params.setMargins(5, 5, 5, 5)
//                     layoutParams = params
//                     setOnClickListener {
//                         val clipboard =
//                                 context.getSystemService(Context.CLIPBOARD_SERVICE) as
//                                         ClipboardManager
//                         val clip =
//                                 ClipData.newPlainText(
//                                         "cliped from ime",
//                                         textViewDialog.text.toString()
//                                 )
//                         clipboard.setPrimaryClip(clip)
//                         refresh()
//                         hideDialog()
//                     }
//                 }
//         deleteDialogBtn =
//                 Button(context).apply {
//                     text = "حذف"
//                     setTextColor(Color.WHITE)
//                     setBackgroundColor(0xFF2D2D2D.toInt())
//                     val params =
//                             LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.MATCH_PARENT, 1f)
//                     params.setMargins(5, 5, 5, 5)
//                     layoutParams = params
//                     setOnClickListener {
//                         clipboardDB.deleteText(textViewDialog.text.toString())
//                         refresh()
//                         hideDialog()
//                     }
//                 }
//         pinDialogBtn =
//                 Button(context).apply {
//                     text = "تثبيت"
//                     setTextColor(Color.WHITE)
//                     setBackgroundColor(0xFF2D2D2D.toInt())
//                     val params =
//                             LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.MATCH_PARENT, 1f)
//                     params.setMargins(5, 5, 5, 5)
//                     layoutParams = params
//                     setOnClickListener {
//                         clipboardDB.setPinned(textViewDialog.text.toString(), true)
//                         refresh()
//                         hideDialog()
//                     }
//                 }
//         textViewDialog =
//                 TextView(context).apply {
//                     text = ""
//                     setTextColor(Color.WHITE)
//                     setPadding(10, 10, 10, 0)
//                     setBackgroundColor(0xFF2D2D2D.toInt())
//                     val params =
//                             LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, 0, 5f)
//                     gravity = Gravity.CENTER
//                     layoutParams = params
//                 }
//         bottomRowDialog =
//                 LinearLayout(context).apply {
//                     // isClickable = true
//                     // setBackgroundColor(0xFF222222.toInt())
//                     orientation = HORIZONTAL
//                     val params =
//                             LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, 0, 1f)
//                     layoutParams = params
//                     // addView(textViewDialog)
//                     addView(closeDialogBtn)
//                     addView(copyDialogBtn)
//                     addView(pinDialogBtn)
//                     addView(deleteDialogBtn)
//                 }
//         dialog =
//                 LinearLayout(context).apply {
//                     // y = dpToPx(30f)
//                     isClickable = true
//                     setBackgroundColor(0xFF222222.toInt())
//                     orientation = VERTICAL
//                     val params =
//                             LinearLayout.LayoutParams(
//                                     LinearLayout.LayoutParams.MATCH_PARENT,
//                                     LinearLayout.LayoutParams.MATCH_PARENT
//                             )
//                     params.setMargins(0, dpToPx(30f).toInt(), 0, 0)
//                     layoutParams = params
//                     visibility = View.GONE
//                     addView(textViewDialog)
//                     addView(bottomRowDialog)
//                 }
//     }
//     override fun onAttachedToWindow() {
//         super.onAttachedToWindow()

//         (parent as FrameLayout).addView(dialog)
//     }
//     fun refresh() {
//         scrollContainer.removeAllViews()
//         currentOffset = 0
//         getItems()
//         showMoreItemsBtn.apply {
//             text = "عرض المزيد"
//             setOnClickListener { getItems() }
//         }
//         scrollContainer.addView(showMoreItemsBtn)
//     }
//     private fun getItems() {
//         val items = clipboardDB.getClipboardItems(currentOffset, itemsPerPage)
//         items.forEachIndexed { i, item -> addItem(item, i + currentOffset) }
//         currentOffset += items.size
//         if (items.size != itemsPerPage) {
//             showMoreItemsBtn.apply {
//                 text = "لا يمكنك عرض المزيد"
//                 setOnClickListener {}
//             }
//         }
//     }
//     fun addItem(item: ClipboardItem, index: Int = -1) {
//         val btn =
//                 Button(context).apply {
//                     setTextColor(Color.WHITE)
//                     setPadding(0, 0, 0, 0)
//                     maxLines = 4
//                     if (item.isPinned) background = context.getDrawable(R.drawable.ic_pinned)
//                     else setBackgroundColor(0xFF2D2D2D.toInt())
//                     text = item.text
//                     val params =
//                             LinearLayout.LayoutParams(
//                                     LinearLayout.LayoutParams.MATCH_PARENT,
//                                     dpToPx(100f).toInt(),
//                                     1f
//                             )
//                     params.gravity = Gravity.CENTER
//                     params.setMargins(0, 5, 0, 5)
//                     layoutParams = params
//                     setOnClickListener { onPaste(item.text) }
//                     setOnLongClickListener {
//                         dialog.visibility = View.VISIBLE
//                         // pinDialogBtn.text = if(item.isPinned)"الغا التثبيت"else "تثبيت"
//                         pinDialogBtn.apply {
//                             text = if (item.isPinned) "الغا التثبيت" else "تثبيت"
//                             setOnClickListener {
//                                 clipboardDB.setPinned(
//                                         textViewDialog.text.toString(),
//                                         !item.isPinned
//                                 )
//                                 refresh()
//                                 hideDialog()
//                             }
//                         }
//                         textViewDialog.text = item.text
//                         true
//                     }
//                 }
//         if (index != -1) scrollContainer.addView(btn, index)
//         else
//                 scrollContainer.addView(
//                         btn,
//                 )
//     }
//     private fun onPaste(text: String) {
//         FlutterIME.ime.sendKeyPress(text)
//         hide()
//     }
//     override fun setVisibility(v: Int) {
//         post {
//             if (visibility == View.VISIBLE) {
//                 layoutParams.height = dpToPx(325f).toInt()
//                 // scrollView.layoutParams.height = dpToPx(295f).toInt()
//                 requestLayout()
//                 refresh()
//             } else {
//                 // hideDialog()
//             }
//         }
//         super.setVisibility(v)
//     }
//     fun hideDialog() {
//         post { dialog.visibility = View.GONE }
//     }
//     fun hide() {
//         post {
//             hideDialog()
//             this.visibility = View.GONE
//         }
//     }
//     fun dpToPx(dp: Float): Float {
//         return dp * context.resources.displayMetrics.density
//     }
//     fun spToPx(sp: Float): Float =
//             TypedValue.applyDimension(
//                     TypedValue.COMPLEX_UNIT_SP,
//                     sp,
//                     context.resources.displayMetrics
//             )
// }

// class Symbols
// @JvmOverloads
// constructor(
//         context: Context,
//         attrs: AttributeSet? = null,
//         defStyle: Int = android.R.attr.buttonStyle
// ) : TowFnKey(context, attrs, defStyle) {
//     companion object {
//         var isSymbols = false
//     }
//     override var fn1 = {
//         Key.isSymbols.value = !(Key.isSymbols.value ?: true)
//         FlutterIME.ime.switchSymbols(Key.isSymbols.value == true)
//         // tag = if(isSymbols)"abc" else "123"
//     }
//     init {
//         tag = if (Key.isSymbols.value == true) "abc" else "123"
//         Key.isSymbols.addListener { newVal -> tag = if (newVal == true) "abc" else "123" }
//     }
// }
