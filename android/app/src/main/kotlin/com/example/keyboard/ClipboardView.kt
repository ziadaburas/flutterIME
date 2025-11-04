package com.example.ime.views

import android.content.*
import android.graphics.*
import android.os.*
import android.util.*
import android.view.*
import android.widget.*
import com.example.ime.FlutterIME
import com.example.ime.R

import com.example.ime.clipboard.*



open class ClipboardView
@JvmOverloads
constructor(
        context: Context,
        attrs: AttributeSet? = null,
        defStyle: Int = android.R.attr.buttonStyle
) : LinearLayout(context, attrs, defStyle) {
    var closeBtn: Button
    var topRow: LinearLayout
    var scrollContainer: LinearLayout
    var scrollView: ScrollView
    var dialog: LinearLayout
    var closeDialogBtn: Button
    var goToTopBtn: Button
    var goToDownBtn: Button
    var goToSettingsBtn: Button

    var copyDialogBtn: Button
    var deleteDialogBtn: Button
    var pinDialogBtn: Button
    var showMoreItemsBtn: Button
    var bottomRowDialog: LinearLayout
    var textViewDialog: TextView
    val clipboardDB = ClipboardDbHelper(context)
    var itemsPerPage = 30
    var currentOffset = 0
    init {
        // val params
        // =LinearLayout.LayoutParams(LayoutParams.MATCH_PARENT,FlutterIME.ime.rootView.height)
        // layoutParams = params
        visibility = View.GONE
        orientation = VERTICAL

        topRow =
                LinearLayout(context).apply {
                    setBackgroundColor(0xFF121212.toInt())
                    orientation = LinearLayout.HORIZONTAL
                    val params =
                            LinearLayout.LayoutParams(
                                    LinearLayout.LayoutParams.MATCH_PARENT,
                                    LinearLayout.LayoutParams.WRAP_CONTENT
                            )
                    params.gravity = Gravity.TOP
                    layoutParams = params
                }
        closeBtn =
                Button(context).apply {
                    setTextColor(Color.WHITE)
                    setPadding(0, 0, 0, 0)
                    text = "\u2716"
                    val params = LinearLayout.LayoutParams(0, dpToPx(30f).toInt(), 1f)
                    params.gravity = Gravity.CENTER
                    layoutParams = params
                    setOnClickListener { hide() }
                }
        goToTopBtn =
                Button(context).apply {
                    setTextColor(Color.WHITE)
                    setPadding(0, 0, 0, 0)
                    text = "\u25b2"
                    val params = LinearLayout.LayoutParams(0, dpToPx(30f).toInt(), 1f)
                    params.gravity = Gravity.CENTER
                    layoutParams = params
                    setOnClickListener { scrollView.fullScroll(View.FOCUS_UP) }
                }
        goToDownBtn =
                Button(context).apply {
                    setTextColor(Color.WHITE)
                    setPadding(0, 0, 0, 0)
                    text = "\u25bc"
                    val params = LinearLayout.LayoutParams(0, dpToPx(30f).toInt(), 1f)
                    params.gravity = Gravity.CENTER
                    layoutParams = params
                    setOnClickListener { scrollView.fullScroll(View.FOCUS_DOWN) }
                }
        goToSettingsBtn =
                Button(context).apply {
                    setTextColor(Color.WHITE)
                    setPadding(0, 0, 0, 0)
                    text = "\u2699"
                    val params = LinearLayout.LayoutParams(0, dpToPx(30f).toInt(), 1f)
                    params.gravity = Gravity.CENTER
                    layoutParams = params
                    setOnClickListener { hide() }
                }
        topRow.addView(goToSettingsBtn)
        topRow.addView(goToDownBtn)
        topRow.addView(goToTopBtn)
        topRow.addView(closeBtn)
        this.addView(topRow)

        scrollView =
                ScrollView(context).apply {
                    setPadding(0, 0, 0, 0)
                    val params =
                            LinearLayout.LayoutParams(
                                    LinearLayout.LayoutParams.MATCH_PARENT,
                                    LinearLayout.LayoutParams.MATCH_PARENT,
                            )
                    params.gravity = Gravity.TOP
                    layoutParams = params
                }
        scrollContainer =
                LinearLayout(context).apply {
                    orientation = LinearLayout.VERTICAL
                    setPadding(0, 0, 0, 0)
                    val params =
                            LinearLayout.LayoutParams(
                                    LinearLayout.LayoutParams.MATCH_PARENT,
                                    LinearLayout.LayoutParams.WRAP_CONTENT
                            )
                    params.gravity = Gravity.TOP
                    layoutParams = params
                }

        scrollView.addView(scrollContainer)
        this.addView(scrollView)
        showMoreItemsBtn =
                Button(context).apply {
                    setTextColor(Color.WHITE)
                    setPadding(0, 0, 0, 0)
                    setBackgroundColor(0xFF121212.toInt())
                    val params =
                            LinearLayout.LayoutParams(
                                    LinearLayout.LayoutParams.MATCH_PARENT,
                                    dpToPx(50f).toInt(),
                                    1f
                            )
                    // params.gravity=Gravity.CENTER
                    params.setMargins(0, 5, 0, 5)
                    layoutParams = params
                }
        closeDialogBtn =
                Button(context).apply {
                    text = "اغلاق"
                    setTextColor(Color.WHITE)
                    setBackgroundColor(0xFF2D2D2D.toInt())
                    val params =
                            LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.MATCH_PARENT, 1f)
                    params.setMargins(5, 5, 5, 5)
                    layoutParams = params
                    setOnClickListener { hideDialog() }
                }
        copyDialogBtn =
                Button(context).apply {
                    text = "نسخ"
                    setTextColor(Color.WHITE)
                    setBackgroundColor(0xFF2D2D2D.toInt())
                    val params =
                            LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.MATCH_PARENT, 1f)
                    params.setMargins(5, 5, 5, 5)
                    layoutParams = params
                    setOnClickListener {
                        val clipboard =
                                context.getSystemService(Context.CLIPBOARD_SERVICE) as
                                        ClipboardManager
                        val clip =
                                ClipData.newPlainText(
                                        "cliped from ime",
                                        textViewDialog.text.toString()
                                )
                        clipboard.setPrimaryClip(clip)
                        refresh()
                        hideDialog()
                    }
                }
        deleteDialogBtn =
                Button(context).apply {
                    text = "حذف"
                    setTextColor(Color.WHITE)
                    setBackgroundColor(0xFF2D2D2D.toInt())
                    val params =
                            LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.MATCH_PARENT, 1f)
                    params.setMargins(5, 5, 5, 5)
                    layoutParams = params
                    setOnClickListener {
                        clipboardDB.deleteText(textViewDialog.text.toString())
                        refresh()
                        hideDialog()
                    }
                }
        pinDialogBtn =
                Button(context).apply {
                    text = "تثبيت"
                    setTextColor(Color.WHITE)
                    setBackgroundColor(0xFF2D2D2D.toInt())
                    val params =
                            LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.MATCH_PARENT, 1f)
                    params.setMargins(5, 5, 5, 5)
                    layoutParams = params
                    setOnClickListener {
                        clipboardDB.setPinned(textViewDialog.text.toString(), true)
                        refresh()
                        hideDialog()
                    }
                }
        textViewDialog =
                TextView(context).apply {
                    text = ""
                    setTextColor(Color.WHITE)
                    setPadding(10, 10, 10, 0)
                    setBackgroundColor(0xFF2D2D2D.toInt())
                    val params =
                            LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, 0, 5f)
                    gravity = Gravity.CENTER
                    layoutParams = params
                }
        bottomRowDialog =
                LinearLayout(context).apply {
                    // isClickable = true
                    // setBackgroundColor(0xFF222222.toInt())
                    orientation = HORIZONTAL
                    val params =
                            LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, 0, 1f)
                    layoutParams = params
                    // addView(textViewDialog)
                    addView(closeDialogBtn)
                    addView(copyDialogBtn)
                    addView(pinDialogBtn)
                    addView(deleteDialogBtn)
                }
        dialog =
                LinearLayout(context).apply {
                    // y = dpToPx(30f)
                    isClickable = true
                    setBackgroundColor(0xFF222222.toInt())
                    orientation = VERTICAL
                    val params =
                            LinearLayout.LayoutParams(
                                    LinearLayout.LayoutParams.MATCH_PARENT,
                                    LinearLayout.LayoutParams.MATCH_PARENT
                            )
                    params.setMargins(0, dpToPx(30f).toInt(), 0, 0)
                    layoutParams = params
                    visibility = View.GONE
                    addView(textViewDialog)
                    addView(bottomRowDialog)
                }
    }
    override fun onAttachedToWindow() {
        super.onAttachedToWindow()

        (parent as FrameLayout).addView(dialog)
    }
    fun refresh() {
        scrollContainer.removeAllViews()
        currentOffset = 0
        getItems()
        showMoreItemsBtn.apply {
            text = "عرض المزيد"
            setOnClickListener { getItems() }
        }
        scrollContainer.addView(showMoreItemsBtn)
    }
    private fun getItems() {
        val items = clipboardDB.getClipboardItems(currentOffset, itemsPerPage)
        items.forEachIndexed { i, item -> addItem(item, i + currentOffset) }
        currentOffset += items.size
        if (items.size != itemsPerPage) {
            showMoreItemsBtn.apply {
                text = "لا يمكنك عرض المزيد"
                setOnClickListener {}
            }
        }
    }
    fun addItem(item: ClipboardItem, index: Int = -1) {
        val btn =
                Button(context).apply {
                    setTextColor(Color.WHITE)
                    setPadding(0, 0, 0, 0)
                    maxLines = 4
                    if (item.isPinned) background = context.getDrawable(R.drawable.ic_pinned)
                    else setBackgroundColor(0xFF2D2D2D.toInt())
                    text = item.text
                    val params =
                            LinearLayout.LayoutParams(
                                    LinearLayout.LayoutParams.MATCH_PARENT,
                                    dpToPx(100f).toInt(),
                                    1f
                            )
                    params.gravity = Gravity.CENTER
                    params.setMargins(0, 5, 0, 5)
                    layoutParams = params
                    setOnClickListener { onPaste(item.text) }
                    setOnLongClickListener {
                        dialog.visibility = View.VISIBLE
                        // pinDialogBtn.text = if(item.isPinned)"الغا التثبيت"else "تثبيت"
                        pinDialogBtn.apply {
                            text = if (item.isPinned) "الغا التثبيت" else "تثبيت"
                            setOnClickListener {
                                clipboardDB.setPinned(
                                        textViewDialog.text.toString(),
                                        !item.isPinned
                                )
                                refresh()
                                hideDialog()
                            }
                        }
                        textViewDialog.text = item.text
                        true
                    }
                }
        if (index != -1) scrollContainer.addView(btn, index)
        else
                scrollContainer.addView(
                        btn,
                )
    }
    private fun onPaste(text: String) {
        FlutterIME.ime.sendKeyPress(text)
        hide()
    }
    override fun setVisibility(v: Int) {
        post {
            if (visibility == View.VISIBLE) {
                layoutParams.height = dpToPx(325f).toInt()
                // scrollView.layoutParams.height = dpToPx(295f).toInt()
                requestLayout()
                refresh()
            } else {
                // hideDialog()
            }
        }
        super.setVisibility(v)
    }
    fun hideDialog() {
        post { dialog.visibility = View.GONE }
    }
    fun hide() {
        post {
            hideDialog()
            this.visibility = View.GONE
        }
    }
    fun dpToPx(dp: Float): Float {
        return dp * context.resources.displayMetrics.density
    }
    fun spToPx(sp: Float): Float =
            TypedValue.applyDimension(
                    TypedValue.COMPLEX_UNIT_SP,
                    sp,
                    context.resources.displayMetrics
            )
}

