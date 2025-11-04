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
import androidx.viewpager2.widget.ViewPager2
import androidx.recyclerview.widget.RecyclerView

import org.json.JSONArray
import java.nio.charset.Charset
import android.content.res.AssetManager

import android.graphics.drawable.*


open class EmojiView
@JvmOverloads
constructor(
        context: Context,
        attrs: AttributeSet? = null,
        defStyle: Int = android.R.attr.buttonStyle
) : LinearLayout(context, attrs, defStyle) {
    var closeBtn: Button
    
    var topRow: LinearLayout
    var bottomRow: LinearLayout
    var goToTopBtn: Button
    var goToDownBtn: Button
    var goToSettingsBtn: Button 

    var itemsPerPage = 30
    var currentOffset = 0
    companion object {
        val isScrollable = ValueListener(false)
    }

    var pager: SystemViewsPager2
    init {
        visibility = View.GONE
        orientation = VERTICAL


        topRow =
                LinearLayout(context).apply {
                    setBackgroundColor(0xFF121212.toInt())
                    orientation = LinearLayout.HORIZONTAL
                    val params =
                            LinearLayout.LayoutParams(
                                    LinearLayout.LayoutParams.MATCH_PARENT,
                                    dpToPx(30f).toInt()
                            )
                    params.gravity = Gravity.TOP
                    layoutParams = params
                }
        bottomRow  =
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
                closeBtn = setupRowBtn("\u2716",::hide)
                
                goToTopBtn =setupRowBtn("\u25b2",{
                    val page = pager.pages[pager.viewPager2.currentItem] as ScrollView
                    page.fullScroll(View.FOCUS_UP)
                    
                })
                
        goToDownBtn =setupRowBtn("\u25bc",{
                    val page = pager.pages[pager.viewPager2.currentItem] as ScrollView
                    page.fullScroll(View.FOCUS_DOWN)
        })
        
        goToSettingsBtn =setupRowBtn("\u2699",::hide)
        
        topRow.addView(goToSettingsBtn)
        topRow.addView(goToDownBtn)
        topRow.addView(goToTopBtn)
        topRow.addView(closeBtn)
        this.addView(topRow)
        
        pager = SystemViewsPager2(context).apply{
            layoutParams = LinearLayout.LayoutParams(-1,0,1f)
            setPadding(0, 0, 0, 0)
            
        }
        
        //loadEmojisFromAssetAndPopulatePager(context.assets)
        
        bottomRow.addView(setupRowBtn("0",{pager.goToPage(0)}))
        bottomRow.addView(setupRowBtn("1",{pager.goToPage(1)}))
        bottomRow.addView(Delete(context).apply {
            layoutParams = LinearLayout.LayoutParams(0, -1, 1f)
            setPadding(0, 0, 0, 0)
            text = "⌫"
            
        })
        // bottomRow.addView(setupRowBtn("⌫",{
        //     FlutterIME.ime.delete()
        //     FlutterIME.ime.delete()
        // }))
        // pager.addPage(setupImojiPage(emojis))
        // pager.addPage(setupImojiPage(emojis))
        this.addView(pager)
        this.addView(bottomRow)
        
    }
    fun setupRowBtn(label:String,fn:(()->Unit)={}):Button{
        return Button(context).apply {
             //context.getDrawable( R.drawable.emoji_language) 
            setTextColor(Color.WHITE)
            setPadding(0, 0, 0, 0)
            text = label
            layoutParams = LinearLayout.LayoutParams(0,-1, 1f)
            setOnClickListener { fn() }
        }
    }
    fun refresh() {
        // scrollContainer.removeAllViews()
        
        
    
 
    }
    fun loadEmojisFromAssetAndPopulatePager(assetManager: AssetManager, assetFileName: String = "emoji.json") {
        try {
            val inputStream = assetManager.open(assetFileName)
            val size = inputStream.available()
            val buffer = ByteArray(size)
            inputStream.read(buffer)
            inputStream.close()
            val jsonString = String(buffer, Charsets.UTF_8)
            // Assuming emoji.json is an array of objects: [{"category":"Smileys","emoji":"😀"}, ...]
            val categoryMap = mutableMapOf<String, MutableList<String>>()
            val jsonArray = org.json.JSONArray(jsonString)
            for (i in 0 until jsonArray.length()) {
                val obj = jsonArray.getJSONObject(i)
                val category = obj.optString("category", "Other")
                val emoji = obj.optString("emoji", "")
                if (emoji.isNotEmpty()) {
                    val list = categoryMap.getOrPut(category) { mutableListOf() }
                    list.add(emoji)
                }
            }
            // Add a page for each category
            for ((_, emojis) in categoryMap) {
                pager.addPage(setupImojiPage(emojis))
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
    private fun setupImojiPage(emojis: List<String>):ScrollView {
        val scrollView = ScrollView(context).apply {
            setPadding(0, 0, 0, 0)
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.MATCH_PARENT
            )
        }
        val scrollContainer = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(0, 0, 0, 0)
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
        }
        val emojisPerRow = 9
        var currentRow: LinearLayout? = null
        val emojiTypeface = Typeface.createFromAsset(context.assets, "fonts/NotoColorEmoji.ttf")

        for ((index, emoji) in emojis.withIndex()) {
            if (index % emojisPerRow == 0) {
                currentRow = LinearLayout(context).apply {
                    orientation = LinearLayout.HORIZONTAL
                    layoutParams = LinearLayout.LayoutParams(
                        LayoutParams.MATCH_PARENT,
                        dpToPx(55f).toInt()
                    )
                }
                scrollContainer.addView(currentRow)
            }

            val emojiButton = Button(context).apply {
                text = emoji
                typeface = emojiTypeface
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 25f)
                layoutParams = LinearLayout.LayoutParams(-2, -1 , 1f).apply { 
                    setMargins(0, 0, 0, 0)
                 }
                // layoutParams.setMargins(0, 0, 0, 0)
                setBackgroundColor(Color.TRANSPARENT)
                setPadding(0, 0, 0, 0)
                setOnClickListener {
                    FlutterIME.ime.sendKeyPress(emoji)
                }
            }
            currentRow?.addView(emojiButton)
        }
        scrollView.addView(scrollContainer)
        return scrollView
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
   
    fun hide() {
        post {
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


class SystemViewsPager2 @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : LinearLayout(context, attrs) {

    val viewPager2: ViewPager2
    val pages = mutableListOf<View>()
    private val adapter: CustomAdapter

    init {
        orientation = VERTICAL
        layoutParams = LayoutParams(LayoutParams.MATCH_PARENT,300)

        viewPager2 = ViewPager2(context).apply {
            layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT)
        }

        addView(viewPager2)
        //pages = generateSystemViews(context)
        
        adapter = CustomAdapter(pages)
        viewPager2.adapter = adapter
        
    }
    fun addPage(view: View) {
        pages.add((view))
        adapter.notifyItemInserted(pages.size - 1)
    }
    fun goToPage(index:Int) {
        if (index in 0 until pages.size) {
            viewPager2.setCurrentItem(index, true)
        } 
    }

    fun wrap(view: View): View {
        return LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT)
            setPadding(32, 32, 32, 32)
            addView(view)
        }
    }
    private fun generateSystemViews(context: Context): MutableList<View> {

        val page1 = wrap(EditText(context).apply {
            hint = "اكتب شيئًا"
            layoutParams = LayoutParams(600, LayoutParams.WRAP_CONTENT)
        })

        val page2 = wrap(Switch(context).apply {
            text = "تشغيل / إيقاف"
            isChecked = true
        })

        val page3 = wrap(ProgressBar(context).apply {
            isIndeterminate = true
        })

        val page4 = wrap(SeekBar(context).apply {
            max = 100
            progress = 50
        })

        return mutableListOf(page1, page2, page3, page4)
    }

    private class CustomAdapter(private val pages: List<View>) :
        RecyclerView.Adapter<CustomAdapter.ViewHolder>() {

        class ViewHolder(val container: FrameLayout) : RecyclerView.ViewHolder(container)

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
            val frame = FrameLayout(parent.context).apply {
                layoutParams = ViewGroup.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT
                )
            }
            return ViewHolder(frame)
        }

        override fun onBindViewHolder(holder: ViewHolder, position: Int) {
            holder.container.removeAllViews()
            holder.container.addView(pages[position])
        }

        override fun getItemCount(): Int = pages.size
    }
}
