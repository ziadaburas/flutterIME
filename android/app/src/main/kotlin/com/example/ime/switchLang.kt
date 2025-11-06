package com.example.ime.utils

import android.content.Context
import android.view.ViewGroup
import android.widget.LinearLayout
import com.example.ime.views.*

class KeyboardLayoutBuilder(private val context: Context) {
    
    companion object {
        const val KEYBOARD_HEIGHT = 325 // dp
        const val ROW_HEIGHT = 45 // dp for first row
        const val DEFAULT_WEIGHT = 1f
        const val LARGE_KEY_WEIGHT = 1.5f
    }
    
    // إنشاء الكيبورد الإنجليزي
    fun buildEnglishKeyboard(): LinearLayout {
        val mainLayout = createMainLayout()
        
        // Row 1: Navigation Keys
        mainLayout.addView(createNavigationRow())
        
        // Row 2: Numbers
        mainLayout.addView(createNumbersRow())
        
        // Row 3: Q-P
        mainLayout.addView(createEnglishRow1())
        
        // Row 4: A-L
        mainLayout.addView(createEnglishRow2())
        
        // Row 5: Z-M with Shift and Delete
        mainLayout.addView(createEnglishRow3())
        
        // Row 6: Bottom Row
        mainLayout.addView(createBottomRow())
        
        return mainLayout
    }
    
    // إنشاء الكيبورد العربي
    fun buildArabicKeyboard(): LinearLayout {
        val mainLayout = createMainLayout()
        
        // Row 1: Navigation Keys (نفس الإنجليزي)
        mainLayout.addView(createNavigationRow())
        
        // Row 2: Numbers (نفس الإنجليزي)
        mainLayout.addView(createNumbersRow())
        
        // Row 3: ض-ج
        mainLayout.addView(createArabicRow1())
        
        // Row 4: ش-ك
        mainLayout.addView(createArabicRow2())
        
        // Row 5: ظ-ث with Delete
        mainLayout.addView(createArabicRow3())
        
        // Row 6: Bottom Row (معدل قليلاً للعربي)
        mainLayout.addView(createBottomRowArabic())
        
        return mainLayout
    }
    
    // ===== الدوال المساعدة =====
    
    private fun createMainLayout(): LinearLayout {
        return LinearLayout(context).apply {
            id = android.R.id.content // سنستخدم ID مخصص لاحقاً
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                dpToPx(KEYBOARD_HEIGHT)
            )
            orientation = LinearLayout.VERTICAL
        }
    }
    
    private fun createRow(height: Int = 0, weight: Float = 1f): LinearLayout {
        return LinearLayout(context).apply {
            layoutParams = if (height > 0) {
                LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    dpToPx(height)
                )
            } else {
                LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    0,
                    weight
                )
            }
            orientation = LinearLayout.HORIZONTAL
        }
    }
    
    // Row 1: Navigation Keys
    private fun createNavigationRow(): LinearLayout {
        val row = createRow(height = ROW_HEIGHT)
        
        row.addView(createKey(LeftKey::class.java, "←", ""))
        row.addView(createKey(UpKey::class.java, "↑", "Home"))
        row.addView(createKey(Tab::class.java, "⇥", ""))
        row.addView(createKey(Ctrl::class.java, "Ctrl", ""))
        row.addView(createKey(Alt::class.java, "Alt", ""))
        row.addView(createKey(Shift::class.java, "Shift", ""))
        row.addView(createKey(DownKey::class.java, "↓", "End"))
        row.addView(createKey(RightKey::class.java, "→", ""))
        
        return row
    }
    
    // Row 2: Numbers
    private fun createNumbersRow(): LinearLayout {
        val row = createRow()
        
        val numbers = listOf("1", "2", "3", "4", "5", "6", "7", "8", "9", "0")
        numbers.forEach { num ->
            row.addView(createKey(Letter::class.java, num, "!"))
        }
        
        return row
    }
    
    // Row 3: Q-P (English)
    private fun createEnglishRow1(): LinearLayout {
        val row = createRow()
        
        val keys = mapOf(
            "q" to "( ) ()",
            "w" to "{ } {}",
            "e" to "[ ]  []",
            "r" to "& &&",
            "t" to "| ||",
            "y" to "= == =>",
            "u" to "+ ++ +=",
            "i" to "- ->",
            "o" to "$",
            "p" to "#"
        )
        
        keys.forEach { (text, popup) ->
            row.addView(createKey(Letter::class.java, text, popup))
        }
        
        return row
    }
    
    // Row 4: A-L (English)
    private fun createEnglishRow2(): LinearLayout {
        val row = createRow()
        
        val keys = mapOf(
            "a" to "@ • @gmail.com",
            "s" to "! !=",
            "d" to "~",
            "f" to "?",
            "g" to "* **",
            "h" to "%",
            "j" to "_ __",
            "k" to ":",
            "l" to ";"
        )
        
        keys.forEach { (text, popup) ->
            row.addView(createKey(Letter::class.java, text, popup))
        }
        
        return row
    }
    
    // Row 5: Z-M (English)
    private fun createEnglishRow3(): LinearLayout {
        val row = createRow()
        
        // Capslock key
        row.addView(createKey(Capslock::class.java, "⇧", "", weight = LARGE_KEY_WEIGHT))
        
        val keys = mapOf(
            "z" to "' ''",
            "x" to "\" \"\"",
            "c" to "`",
            "v" to "< <= <>",
            "b" to "> >= </>",
            "n" to "/ // /**/",
            "m" to "\\"
        )
        
        keys.forEach { (text, popup) ->
            row.addView(createKey(Letter::class.java, text, popup))
        }
        
        // Delete key
        row.addView(createKey(Delete::class.java, "⌫", "", weight = LARGE_KEY_WEIGHT))
        
        return row
    }
    
    // Row 3: ض-ج (Arabic)
    private fun createArabicRow1(): LinearLayout {
        val row = createRow()
        
        val letters = listOf("ض", "ص", "ق", "ف", "غ", "ع", "ه", "خ", "ح", "ج")
        letters.forEach { letter ->
            row.addView(createKey(Letter::class.java, letter, "!"))
        }
        
        return row
    }
    
    // Row 4: ش-ك (Arabic)
    private fun createArabicRow2(): LinearLayout {
        val row = createRow()
        
        val keys = mapOf(
            "ش" to "!",
            "س" to "!",
            "ي" to "ى ئ",
            "ب" to "!",
            "ل" to "!",
            "ا" to "ء أ إ آ",
            "ت" to "ـ",
            "ن" to "!",
            "م" to "!",
            "ك" to "؛"
        )
        
        keys.forEach { (text, popup) ->
            row.addView(createKey(Letter::class.java, text, popup))
        }
        
        return row
    }
    
    // Row 5: ظ-ث (Arabic)
    private fun createArabicRow3(): LinearLayout {
        val row = createRow()
        
        val keys = mapOf(
            "ظ" to "َ ِ ُ ً ٍ ٌ ّ ْ",
            "ط" to "!",
            "ذ" to "!",
            "د" to "!",
            "ز" to "!",
            "ر" to "!",
            "و" to "ؤ",
            "ة" to "!",
            "ث" to "!"
        )
        
        keys.forEach { (text, popup) ->
            row.addView(createKey(Letter::class.java, text, popup))
        }
        
        // Delete key
        row.addView(createKey(Delete::class.java, "⌫", "", weight = LARGE_KEY_WEIGHT))
        
        return row
    }
    
    // Row 6: Bottom Row (English)
    private fun createBottomRow(): LinearLayout {
        val row = createRow()
        
        row.addView(createKey(Symbols::class.java, "123", "", weight = LARGE_KEY_WEIGHT))
        row.addView(createKey(Emoji::class.java, "", "", isTransparent = true))
        row.addView(createKey(Letter::class.java, ",", ""))
        row.addView(createKey(Space::class.java, "Space", ""))
        row.addView(createKey(Dot::class.java, ".", ""))
        row.addView(createKey(Clip::class.java, "", "", isTransparent = true))
        row.addView(createKey(Enter::class.java, "⏎", ""))
        
        return row
    }
    
    // Row 6: Bottom Row (Arabic)
    private fun createBottomRowArabic(): LinearLayout {
        val row = createRow()
        
        row.addView(createKey(Symbols::class.java, "123", "", weight = LARGE_KEY_WEIGHT))
        row.addView(createKey(Emoji::class.java, "", "", isTransparent = true))
        row.addView(createKey(Letter::class.java, ",", "،"))
        row.addView(createKey(Space::class.java, "n", ""))
        row.addView(createKey(Letter::class.java, ".", ""))
        row.addView(createKey(Clip::class.java, "", "", isTransparent = true))
        row.addView(createKey(Enter::class.java, "⏎", ""))
        
        return row
    }
    
    // دالة عامة لإنشاء أي مفتاح
    private fun <T : Key> createKey(
        keyClass: Class<T>,
        text: String,
        popupKeys: String,
        weight: Float = DEFAULT_WEIGHT,
        isTransparent: Boolean = false
    ): T {
        return keyClass.getConstructor(Context::class.java).newInstance(context).apply {
            this.text = text
            this.hint = popupKeys
            
            layoutParams = LinearLayout.LayoutParams(
                0,
                ViewGroup.LayoutParams.MATCH_PARENT,
                weight
            )
            
            if (isTransparent) {
                setBackgroundColor(android.graphics.Color.TRANSPARENT)
            }
        }
    }
    
    private fun dpToPx(dp: Int): Int {
        return (dp * context.resources.displayMetrics.density).toInt()
    }
}
