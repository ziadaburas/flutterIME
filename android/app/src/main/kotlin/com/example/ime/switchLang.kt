package com.example.ime.utils

import android.content.Context
import android.view.ViewGroup
import android.widget.LinearLayout
import com.example.ime.views.*

class KeyboardLayoutBuilder(private val context: Context) {

    companion object {
        const val KEYBOARD_HEIGHT = 325
        const val ROW_HEIGHT = 45
        const val DEFAULT_WEIGHT = 1f
        const val LARGE_KEY_WEIGHT = 1.5f
    }

    // ✅ إنشاء الكيبورد الإنجليزي
    fun buildEnglishKeyboard() = createKeyboard(
        rowsData = englishRows,
        bottomRowCreator = ::createBottomRow
    )

    // ✅ إنشاء الكيبورد العربي
    fun buildArabicKeyboard() = createKeyboard(
        rowsData = arabicRows,
        bottomRowCreator = ::createBottomRowArabic
    )

    // =============================
    // 🧩 الدوال العامة
    // =============================

    private fun createKeyboard(
        rowsData: List<Any>,
        bottomRowCreator: () -> LinearLayout
    ): LinearLayout = createMainLayout().apply {
        // صف التنقل
        addView(createNavigationRow())
        // صف الأرقام
        addView(createNumbersRow())
        // باقي الصفوف من القاموس
        rowsData.forEach { data ->
            addView(createGenericRow(data))
        }
        // الصف الأخير
        addView(bottomRowCreator())
    }

    private fun createMainLayout() = LinearLayout(context).apply {
        id = android.R.id.content
        layoutParams = LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            dpToPx(KEYBOARD_HEIGHT)
        )
        orientation = LinearLayout.VERTICAL
    }

    private fun createRow(height: Int = 0, weight: Float = 1f) = LinearLayout(context).apply {
        layoutParams = if (height > 0)
            LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, dpToPx(height))
        else
            LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0, weight)
        orientation = LinearLayout.HORIZONTAL
    }

    // =============================
    // 🧱 صفوف عامة ثابتة
    // =============================

    private fun createNavigationRow() = createRow(ROW_HEIGHT).apply {
        // الآن يشمل أيضاً popups لـ Up (Home) و Down (End)
        listOf(
            Triple(LeftKey::class.java, "←", ""),
            Triple(UpKey::class.java, "↑", "Home"),
            Triple(Tab::class.java, "⇥", ""),
            Triple(Ctrl::class.java, "Ctrl", ""),
            Triple(Alt::class.java, "Alt", ""),
            Triple(Shift::class.java, "Shift", ""),
            Triple(DownKey::class.java, "↓", "End"),
            Triple(RightKey::class.java, "→", "")
        ).forEach { (cls, label, popup) ->
            addView(createKey(cls, label, popup))
        }
    }

    private fun createNumbersRow() = createRow().apply {
        (1..9).map { it.toString() }.plus("0").forEach {
            addView(createKey(Letter::class.java, it, "!"))
        }
    }

    // =============================
    // 🇬🇧 صفوف الكيبورد الإنجليزي (قاموس واحد)
    // =============================

    private val englishRows = listOf(
        // Row 3 (Q → P)
        mapOf(
            "q" to "( ) ()", "w" to "{ } {}", "e" to "[ ]  []", "r" to "& &&",
            "t" to "| ||", "y" to "= == =>", "u" to "+ ++ +=", "i" to "- ->",
            "o" to "$", "p" to "#"
        ),
        // Row 4 (A → L)
        mapOf(
            "a" to "@ • @gmail.com", "s" to "! !=", "d" to "~", "f" to "?",
            "g" to "* **", "h" to "%", "j" to "_ __", "k" to ":", "l" to ";"
        ),
        // Row 5 (Z → M)
        mapOf(
            "⇧" to "CAPSLOCK", // رمز خاص (سيتم تفسيره)
            "z" to "' ''", "x" to "\" \"\"", "c" to "`", "v" to "< <= <>",
            "b" to "> >= </>", "n" to "/ // /**/", "m" to "\\", "⌫" to "DELETE"
        )
    )

    // =============================
    // 🇸🇦 صفوف الكيبورد العربي (قاموس واحد)
    // =============================

    private val arabicRows = listOf(
        // Row 3 (ض → ج)
        listOf("ض", "ص", "ق", "ف", "غ", "ع", "ه", "خ", "ح", "ج"),
        // Row 4 (ش → ك)
        mapOf(
            "ش" to "!", "س" to "!", "ي" to "ى ئ", "ب" to "!", "ل" to "!",
            "ا" to "ء أ إ آ", "ت" to "ـ", "ن" to "!", "م" to "!", "ك" to "؛"
        ),
        // Row 5 (ظ → ث)
        mapOf(
            "ظ" to "َ ِ ُ ً ٍ ٌ ّ ْ", "ط" to "!", "ذ" to "!", "د" to "!",
            "ز" to "!", "ر" to "!", "و" to "ؤ", "ة" to "!", "ث" to "!", "⌫" to "DELETE"
        )
    )

    // =============================
    // 🧠 مولّد صف عام لأي لغة
    // =============================

    private fun createGenericRow(data: Any): LinearLayout = createRow().apply {
        when (data) {
            is List<*> -> data.forEach {
                addView(createKey(Letter::class.java, it.toString(), "!"))
            }
            is Map<*, *> -> data.forEach { (text, popup) ->
                when (text) {
                    "⇧" -> addView(createKey(Capslock::class.java, "⇧", "", LARGE_KEY_WEIGHT))
                    "⌫" -> addView(createKey(Delete::class.java, "⌫", "", LARGE_KEY_WEIGHT))
                    else -> addView(createKey(Letter::class.java, text.toString(), popup.toString()))
                }
            }
        }
    }

    // =============================
    // ⌨️ الصف السفلي المشترك
    // =============================

    private fun createBottomRow() = createBottomRowCommon(",", "Space", ".")
    private fun createBottomRowArabic() = createBottomRowCommon("،", "n", ".")

    private fun createBottomRowCommon(comma: String, spaceText: String, dot: String) = createRow().apply {
        addView(createKey(Symbols::class.java, "123", "", LARGE_KEY_WEIGHT))
        addView(createKey(Emoji::class.java, "", ""))
        addView(createKey(Letter::class.java, ",", comma))
        addView(createKey(Space::class.java, spaceText, ""))
        addView(createKey(Letter::class.java, ".", dot))
        addView(createKey(Clip::class.java, "", ""))
        addView(createKey(Enter::class.java, "⏎", ""))
    }

    // =============================
    // 🧩 دوال مساعدة أساسية
    // =============================

    private fun <T : Key> createKey(
        keyClass: Class<T>,
        text: String,
        popupKeys: String,
        weight: Float = DEFAULT_WEIGHT,
        transparent: Boolean = false
    ): T = keyClass.getConstructor(Context::class.java).newInstance(context).apply {
        this.text = text
        this.hint = popupKeys
        layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.MATCH_PARENT, weight)
        if (transparent) setBackgroundColor(android.graphics.Color.TRANSPARENT)
    }

    private fun dpToPx(dp: Int) = (dp * context.resources.displayMetrics.density).toInt()
}
