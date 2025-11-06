package com.example.ime.utils

import android.content.Context
import android.util.Log
import android.view.ViewGroup
import android.widget.LinearLayout
import com.example.ime.db.KeyboardLayoutDB
import com.example.ime.views.*
import org.json.JSONException
import org.json.JSONObject

class KeyboardLayoutBuilder(private val context: Context) {

    companion object {
        private const val TAG = "KeyboardLayoutBuilder"
        const val KEYBOARD_HEIGHT = 325
        const val ROW_HEIGHT = 45
        const val DEFAULT_WEIGHT = 1f
        const val LARGE_KEY_WEIGHT = 1.5f
    }

    private val db = KeyboardLayoutDB(context)

    // واجهات سريعة للغات
    fun buildEnglishKeyboard(): LinearLayout = safeBuildKeyboard("en")
    fun buildArabicKeyboard(): LinearLayout = safeBuildKeyboard("ar")
    fun buildKeyboard(lang: String): LinearLayout = safeBuildKeyboard(lang)

    // غلاف آمن يمنع التعطل عند الخطأ
    private fun safeBuildKeyboard(lang: String): LinearLayout {
        val layoutJson = try {
            db.getOrCreateLayout(lang)
        } catch (ex: Exception) {
            Log.e(TAG, "DB error getting layout for $lang: ${ex.message}", ex)
            null
        }

        return try {
            if (layoutJson != null) {
                val json = JSONObject(layoutJson)
                buildFromJson(json, lang)
            } else {
                buildDefaultKeyboard(lang)
            }
        } catch (ex: Exception) {
            Log.e(TAG, "Error building keyboard for $lang: ${ex.message}", ex)
            buildDefaultKeyboard(lang)
        }
    }

    // بناء الكيبورد من JSON
    private fun buildFromJson(json: JSONObject, lang: String): LinearLayout {
        val mainLayout = createMainLayout()
        try {
            val navRow = json.optJSONObject("navRow") ?: JSONObject()
            mainLayout.addView(createNavRow(navRow))

            val numRow = json.optJSONObject("numRow") ?: JSONObject()
            mainLayout.addView(createSimpleRow(numRow))

            val row1 = json.optJSONObject("row1") ?: JSONObject()
            mainLayout.addView(createLetterRow(row1))

            val row2 = json.optJSONObject("row2") ?: JSONObject()
            mainLayout.addView(createLetterRow(row2))

            val row3 = json.optJSONObject("row3") ?: JSONObject()
            // ✅ لا نضيف CapsLock إذا كانت اللغة عربية
            mainLayout.addView(createLetterRow(row3,lang= lang,true))

            val bottom = json.optJSONObject("bottomRow") ?: JSONObject()
            mainLayout.addView(createBottomRow(bottom))

        } catch (ex: JSONException) {
            Log.e(TAG, "JSONException while building layout: ${ex.message}", ex)
            return buildDefaultKeyboard(lang)
        } catch (ex: Exception) {
            Log.e(TAG, "Unexpected error while building layout: ${ex.message}", ex)
            return buildDefaultKeyboard(lang)
        }

        return mainLayout
    }

    // إذا فشلنا، نبني الافتراضي من القاعدة
    private fun buildDefaultKeyboard(lang: String): LinearLayout {
        return try {
            val jsonString = db.getOrCreateLayout(lang)
            JSONObject(jsonString).let { buildFromJson(it, lang) }
        } catch (ex: Exception) {
            Log.e(TAG, "Failed to load default from DB for $lang: ${ex.message}", ex)
            createFallbackKeyboard(lang)
        }
    }

    // كيبورد بسيط كنسخة طوارئ
    private fun createFallbackKeyboard(lang: String): LinearLayout {
        val main = createMainLayout()

        // navRow
        main.addView(createRow(ROW_HEIGHT).apply {
            addView(safeCreateKey(LeftKey::class.java, "←", ""))
            addView(safeCreateKey(UpKey::class.java, "↑", ""))
            addView(safeCreateKey(Tab::class.java, "⇥", ""))
            addView(safeCreateKey(Ctrl::class.java, "Ctrl", ""))
            addView(safeCreateKey(Alt::class.java, "Alt", ""))
            addView(safeCreateKey(Shift::class.java, "Shift", ""))
            addView(safeCreateKey(DownKey::class.java, "↓", ""))
            addView(safeCreateKey(RightKey::class.java, "→", ""))
        })

        // numRow
        main.addView(createRow().apply {
            listOf("1","2","3","4","5","6","7","8","9","0").forEach {
                addView(safeCreateKey(Letter::class.java, it, "!"))
            }
        })

        // row1
        main.addView(createRow().apply {
            listOf("q","w","e","r","t","y","u","i","o","p").forEach {
                addView(safeCreateKey(Letter::class.java, it, ""))
            }
        })

        // row2
        main.addView(createRow().apply {
            listOf("a","s","d","f","g","h","j","k","l").forEach {
                addView(safeCreateKey(Letter::class.java, it, ""))
            }
        })

        // row3
        main.addView(createRow().apply {
            if (lang == "en") addView(safeCreateKey(Capslock::class.java, "⇧", "", LARGE_KEY_WEIGHT))
            listOf("z","x","c","v","b","n","m").forEach {
                addView(safeCreateKey(Letter::class.java, it, ""))
            }
            addView(safeCreateKey(Delete::class.java, "⌫", "", LARGE_KEY_WEIGHT))
        })

        // bottomRow
        main.addView(createRow().apply {
            addView(safeCreateKey(Symbols::class.java, "123", "", LARGE_KEY_WEIGHT))
            addView(safeCreateKey(Emoji::class.java, "", ""))
            addView(safeCreateKey(Letter::class.java, ",", ""))
            addView(safeCreateKey(Space::class.java, "Space", ""))
            addView(safeCreateKey(Letter::class.java, ".", ""))
            addView(safeCreateKey(Clip::class.java, "", ""))
            addView(safeCreateKey(Enter::class.java, "⏎", ""))
        })

        return main
    }

    // ✅ صف الأسهم والتبديل
    private fun createNavRow(json: JSONObject): LinearLayout {
        val row = createRow(height = ROW_HEIGHT)
        val keys = listOf(
            "Left" to Pair(LeftKey::class.java, "←"),
            "Up" to Pair(UpKey::class.java, "↑"),
            "Tab" to Pair(Tab::class.java, "⇥"),
            "Ctrl" to Pair(Ctrl::class.java, "Ctrl"),
            "Alt" to Pair(Alt::class.java, "Alt"),
            "Shift" to Pair(Shift::class.java, "Shift"),
            "Down" to Pair(DownKey::class.java, "↓"),
            "Right" to Pair(RightKey::class.java, "→")
        )

        keys.forEach { (name, pair) ->
            val clazz = pair.first
            val text = pair.second
            try {
                val hint = json.optJSONObject(name)?.optString("hint", "") ?: ""
                row.addView(safeCreateKey(clazz, text, hint))
            } catch (ex: Exception) {
                Log.e(TAG, "Failed to create nav key $name: ${ex.message}", ex)
                row.addView(safeCreateKey(Letter::class.java, text, ""))
            }
        }
        return row
    }

    private fun createSimpleRow(json: JSONObject): LinearLayout {
        val row = createRow()
        val keys = json.keys().asSequence().toList()
        keys.forEach { k ->
            try {
                val hint = json.optString(k, "")
                row.addView(safeCreateKey(Letter::class.java, k, hint))
            } catch (ex: Exception) {
                Log.e(TAG, "Failed to create simple key $k: ${ex.message}", ex)
            }
        }
        return row
    }

    private fun createLetterRow(json: JSONObject,lang:String = "en", is3row: Boolean = false): LinearLayout {
        val row = createRow()
        val keys = json.keys().asSequence().toList()

        if (lang == "en" && is3row) row.addView(safeCreateKey(Capslock::class.java, "⇧", "", LARGE_KEY_WEIGHT))

        keys.forEach { k ->
            try {
                val popup = json.optString(k, "")
                row.addView(safeCreateKey(Letter::class.java, k, popup))
            } catch (ex: Exception) {
                Log.e(TAG, "Failed to create letter key $k: ${ex.message}", ex)
            }
        }

        if(is3row)row.addView(safeCreateKey(Delete::class.java, "⌫", "", LARGE_KEY_WEIGHT))
        return row
    }

    private fun createBottomRow(json: JSONObject): LinearLayout {
        val row = createRow()
        try {
            row.addView(safeCreateKey(Symbols::class.java, json.optString("symbols", "123"), "", LARGE_KEY_WEIGHT))
            row.addView(safeCreateKey(Emoji::class.java, "", ""))
            row.addView(safeCreateKey(Letter::class.java, json.optString("comma", ","), ""))
            row.addView(safeCreateKey(Space::class.java, "Space", ""))
            row.addView(safeCreateKey(Letter::class.java, json.optString("dot", "."), ""))
            row.addView(safeCreateKey(Clip::class.java, "", ""))
            row.addView(safeCreateKey(Enter::class.java, json.optString("enter", "⏎"), ""))
        } catch (ex: Exception) {
            Log.e(TAG, "Failed to create bottom row: ${ex.message}", ex)
        }
        return row
    }

    private fun <T : Key> safeCreateKey(
        keyClass: Class<T>,
        text: String,
        popupKeys: String,
        weight: Float = DEFAULT_WEIGHT
    ): Key {
        return try {
            createKey(keyClass, text, popupKeys, weight)
        } catch (ex: Exception) {
            Log.e(TAG, "Reflection/createKey failed for $text with ${keyClass.simpleName}: ${ex.message}", ex)
            createKey(Letter::class.java, text, popupKeys, weight)
        }
    }

    private fun <T : Key> createKey(
        keyClass: Class<T>,
        text: String,
        popupKeys: String,
        weight: Float = DEFAULT_WEIGHT
    ): T {
        return keyClass.getConstructor(Context::class.java).newInstance(context).apply {
            this.text = text
            this.hint = popupKeys
            layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.MATCH_PARENT, weight)
        }
    }

    private fun createMainLayout() = LinearLayout(context).apply {
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

    private fun dpToPx(dp: Int) =
        (dp * context.resources.displayMetrics.density).toInt()
}
