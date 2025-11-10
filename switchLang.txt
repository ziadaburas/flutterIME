package com.example.ime.utils

import android.content.Context
import android.util.Log
import android.view.ViewGroup
import android.widget.LinearLayout
import com.example.ime.db.KeyboardLayoutDB
import com.example.ime.views.*
import org.json.JSONException
import org.json.JSONObject
import org.json.JSONArray

class KeyboardLayoutBuilder(private val context: Context) {

    companion object {
        private const val TAG = "KeyboardLayoutBuilder"
        const val KEYBOARD_HEIGHT = 325
        const val DEFAULT_WEIGHT = 1f
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

    // بناء الكيبورد من JSON بالبنية الجديدة
    private fun buildFromJson(json: JSONObject, lang: String): LinearLayout {
        val mainLayout = createMainLayout()
        try {
            // بناء الصفوف من row1 إلى row6
            for (i in 1..6) {
                val rowKey = "row$i"
                val rowObj = json.optJSONObject(rowKey)
                if (rowObj != null) {
                    mainLayout.addView(createDynamicRow(rowObj))
                } else {
                    Log.w(TAG, "Row $rowKey not found in JSON")
                }
            }

        } catch (ex: JSONException) {
            Log.e(TAG, "JSONException while building layout: ${ex.message}", ex)
            return buildDefaultKeyboard(lang)
        } catch (ex: Exception) {
            Log.e(TAG, "Unexpected error while building layout: ${ex.message}", ex)
            return buildDefaultKeyboard(lang)
        }

        return mainLayout
    }

    // إنشاء صف ديناميكي من JSON
    private fun createDynamicRow(rowObj: JSONObject): LinearLayout {
        val height = rowObj.optInt("height", 55)
        val row = createRow(height = height)
        
        val keysArray = rowObj.optJSONArray("keys")
        if (keysArray != null) {
            for (i in 0 until keysArray.length()) {
                try {
                    val keyObj = keysArray.getJSONObject(i)
                    val key = createKeyFromJson(keyObj)
                    row.addView(key)
                } catch (ex: Exception) {
                    Log.e(TAG, "Failed to create key at index $i: ${ex.message}", ex)
                }
            }
        }
        
        return row
    }

    // إنشاء مفتاح من JSON بشكل ديناميكي
    private fun createKeyFromJson(keyObj: JSONObject): Key {
        val type = keyObj.optString("type", "letter")
        val weight = keyObj.optDouble("weight", 1.0).toFloat()
        val text = keyObj.optString("text", "")
        val hint = keyObj.optString("hint", "")
        
        // تحديد نوع المفتاح بناءً على type
        val keyClass: Class<out Key> = when (type) {
            "letter" -> Letter::class.java
            "specialKey" -> when (text.lowercase()) {
                "ctrl" -> Ctrl::class.java
                "alt" -> Alt::class.java
                "shift" -> Shift::class.java
                "⇧" -> Capslock::class.java
                else -> Special::class.java
            }
            "loopKey" -> when (text) {
                "←" -> LeftKey::class.java
                "→" -> RightKey::class.java
                else -> LoopKey::class.java
            }
            "normal" -> when (text) {
                "↑" -> UpKey::class.java
                "↓" -> DownKey::class.java
                "⇥" -> Tab::class.java
                "⏎" -> Enter::class.java
                else -> Normal::class.java
            }
            "space" -> Space::class.java
            "delete" -> Delete::class.java
            "emoji" -> Emoji::class.java
            "symbols" -> Symbols::class.java
            "clip" -> Clip::class.java
            else -> {
                Log.w(TAG, "Unknown key type: $type, defaulting to Letter")
                Letter::class.java
            }
        }
        
        return try {
            createKey(keyClass, text, hint, weight, keyObj)
        } catch (ex: Exception) {
            Log.e(TAG, "Failed to create key of type $type: ${ex.message}", ex)
            createKey(Letter::class.java, text, hint, weight, keyObj)
        }
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

        // row1 - navRow
        main.addView(createRow(height = 45).apply {
            addView(createSimpleKey(LeftKey::class.java, "←", ""))
            addView(createSimpleKey(UpKey::class.java, "↑", ""))
            addView(createSimpleKey(Tab::class.java, "⇥", ""))
            addView(createSimpleKey(Ctrl::class.java, "Ctrl", ""))
            addView(createSimpleKey(Alt::class.java, "Alt", ""))
            addView(createSimpleKey(Shift::class.java, "Shift", ""))
            addView(createSimpleKey(DownKey::class.java, "↓", ""))
            addView(createSimpleKey(RightKey::class.java, "→", ""))
        })

        // row2 - numRow
        main.addView(createRow().apply {
            listOf("1","2","3","4","5","6","7","8","9","0").forEach {
                addView(createSimpleKey(Letter::class.java, it, "!"))
            }
        })

        // row3
        main.addView(createRow().apply {
            listOf("q","w","e","r","t","y","u","i","o","p").forEach {
                addView(createSimpleKey(Letter::class.java, it, ""))
            }
        })

        // row4
        main.addView(createRow().apply {
            listOf("a","s","d","f","g","h","j","k","l").forEach {
                addView(createSimpleKey(Letter::class.java, it, ""))
            }
        })

        // row5
        main.addView(createRow().apply {
            if (lang == "en") addView(createSimpleKey(Capslock::class.java, "⇧", "", 1.5f))
            listOf("z","x","c","v","b","n","m").forEach {
                addView(createSimpleKey(Letter::class.java, it, ""))
            }
            addView(createSimpleKey(Delete::class.java, "⌫", "", 1.5f))
        })

        // row6 - bottomRow
        main.addView(createRow().apply {
            addView(createSimpleKey(Symbols::class.java, "123", "", 1.5f))
            addView(createSimpleKey(Emoji::class.java, "", ""))
            addView(createSimpleKey(Letter::class.java, ",", ""))
            addView(createSimpleKey(Space::class.java, "Space", "", 3.0f))
            addView(createSimpleKey(Letter::class.java, ".", ""))
            addView(createSimpleKey(Clip::class.java, "", ""))
            addView(createSimpleKey(Enter::class.java, "⏎", ""))
        })

        return main
    }

    // إنشاء مفتاح بسيط (للـ fallback)
    private fun <T : Key> createSimpleKey(
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

    // إنشاء مفتاح متقدم مع معالجة الخصائص الإضافية
    private fun <T : Key> createKey(
        keyClass: Class<T>,
        text: String,
        popupKeys: String,
        weight: Float = DEFAULT_WEIGHT,
        keyObj: JSONObject? = null
    ): T {
        val key = keyClass.getConstructor(Context::class.java).newInstance(context).apply {
            this.text = text
            this.hint = popupKeys
            layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.MATCH_PARENT, weight)
        }
        
        // إضافة الخصائص الخاصة بناءً على النوع
        keyObj?.let { json ->
            try {
                // للمفاتيح من نوع specialKey - إضافة keyCode
                if (json.optString("type") == "specialKey" && json.has("keyCode")) {
                    val keyCode = json.getInt("keyCode")
                    // يمكن تخزين keyCode في الـ tag أو خاصية مخصصة
                    key.tag = keyCode
                }
                
                // للمفاتيح من نوع normal - إضافة click و longPress
                if (json.optString("type") == "normal") {
                    val click = json.optString("click", "")
                    val longPress = json.optString("longPress", "")
                    // يمكن تخزين هذه القيم أو استخدامها مباشرة
                    // على سبيل المثال في الـ tag كـ Map
                    key.tag = mapOf("click" to click, "longPress" to longPress)
                }
                
                // للمفاتيح من نوع loopKey - إضافة click
                if (json.optString("type") == "loopKey") {
                    val click = json.optString("click", "")
                    key.tag = mapOf("click" to click)
                }
                
            } catch (ex: Exception) {
                Log.e(TAG, "Failed to set additional properties for key: ${ex.message}", ex)
            }
        }
        
        return key
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
