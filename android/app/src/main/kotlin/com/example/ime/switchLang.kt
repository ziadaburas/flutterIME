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
            //db.deleteAllLayouts()
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
        val type = keyObj.optString("type", "All")
        val weight = keyObj.optDouble("weight", 1.0).toFloat()
        val text = keyObj.optString("text", "")
        val hint = keyObj.optString("hint", "")
        
        // تحديد نوع المفتاح بناءً على type
        val keyClass: Class<out Key> = when (type.lowercase()) {
            "all" -> All::class.java
            "space" -> Space::class.java
            "delete" -> Delete::class.java
            "ctrl" -> Ctrl::class.java
            "alt" -> Alt::class.java
            "shift" -> Shift::class.java
            "capslock" -> Capslock::class.java
            "emoji" -> Emoji::class.java
            "symbols" -> Symbols::class.java
            "clip" -> Clip::class.java
            // تحويل جميع الأنواع الأخرى إلى All
            "letter" -> All::class.java
            "normal" -> All::class.java
            "loopkey" -> All::class.java
            "specialkey" -> when (text.lowercase()) {
                "ctrl" -> Ctrl::class.java
                "alt" -> Alt::class.java
                "shift" -> Shift::class.java
                "⇧" -> Capslock::class.java
                else -> All::class.java
            }
            else -> {
                Log.w(TAG, "Unknown key type: $type, using All")
                All::class.java
            }
        }
        
        return try {
            createKey(keyClass, text, hint, weight, keyObj)
        } catch (ex: Exception) {
            Log.e(TAG, "Failed to create key of type $type: ${ex.message}", ex)
            createKey(All::class.java, text, hint, weight, keyObj)
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
            addView(createSimpleKey(All::class.java, "←", "", 1f, mapOf("click" to "sendCode", "codeToSendClick" to 21)))
            addView(createSimpleKey(All::class.java, "↑", "Home", 1f, mapOf("click" to "sendCode", "longPress" to "sendCode", "codeToSendClick" to 19, "codeToSendLongPress" to 122)))
            addView(createSimpleKey(All::class.java, "⇥", "", 1f, mapOf("click" to "sendCode", "codeToSendClick" to 61)))
            addView(createSimpleKey(Ctrl::class.java, "Ctrl", ""))
            addView(createSimpleKey(Alt::class.java, "Alt", ""))
            addView(createSimpleKey(Shift::class.java, "Shift", ""))
            addView(createSimpleKey(All::class.java, "↓", "End", 1f, mapOf("click" to "sendCode", "longPress" to "sendCode", "codeToSendClick" to 20, "codeToSendLongPress" to 123)))
            addView(createSimpleKey(All::class.java, "→", "", 1f, mapOf("click" to "sendCode", "codeToSendClick" to 22)))
        })

        // row2 - numRow
        main.addView(createRow().apply {
            listOf("1","2","3","4","5","6","7","8","9","0").forEach {
                addView(createSimpleKey(All::class.java, it, "!", 1f, mapOf("click" to "sendText", "longPress" to "showPopup", "textToSend" to it)))
            }
        })

        // row3
        main.addView(createRow().apply {
            listOf("q","w","e","r","t","y","u","i","o","p").forEach {
                addView(createSimpleKey(All::class.java, it, "", 1f, mapOf("click" to "sendText", "longPress" to "showPopup", "textToSend" to it)))
            }
        })

        // row4
        main.addView(createRow().apply {
            listOf("a","s","d","f","g","h","j","k","l").forEach {
                addView(createSimpleKey(All::class.java, it, "", 1f, mapOf("click" to "sendText", "longPress" to "showPopup", "textToSend" to it)))
            }
        })

        // row5
        main.addView(createRow().apply {
            if (lang == "en") addView(createSimpleKey(Capslock::class.java, "⇧", "", 1.5f))
            listOf("z","x","c","v","b","n","m").forEach {
                addView(createSimpleKey(All::class.java, it, "", 1f, mapOf("click" to "sendText", "longPress" to "showPopup", "textToSend" to it)))
            }
            addView(createSimpleKey(Delete::class.java, "⌫", "", 1.5f))
        })

        // row6 - bottomRow
        main.addView(createRow().apply {
            addView(createSimpleKey(Symbols::class.java, "123", "", 1.5f))
            addView(createSimpleKey(Emoji::class.java, "", ""))
            addView(createSimpleKey(All::class.java, ",", "", 1f, mapOf("click" to "sendText", "textToSend" to ",")))
            addView(createSimpleKey(Space::class.java, "Space", "", 3.0f))
            addView(createSimpleKey(All::class.java, ".", "", 1f, mapOf("click" to "sendText", "textToSend" to ".")))
            addView(createSimpleKey(Clip::class.java, "", ""))
            addView(createSimpleKey(All::class.java, "⏎", "", 1f, mapOf("click" to "sendCode", "codeToSendClick" to 66)))
        })

        return main
    }

    // إنشاء مفتاح بسيط (للـ fallback)
    private fun <T : Key> createSimpleKey(
        keyClass: Class<T>,
        text: String,
        popupKeys: String,
        weight: Float = DEFAULT_WEIGHT,
        extraProps: Map<String, Any> = emptyMap()
    ): T {
        val key = keyClass.getConstructor(Context::class.java).newInstance(context).apply {
            this.text = text
            this.hint = popupKeys
            layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.MATCH_PARENT, weight)
        }
        
        // إذا كان من نوع All، قم بتعيين الخصائص الإضافية
        if (key is All) {
            extraProps["click"]?.let { key.click = it.toString() }
            extraProps["longPress"]?.let { key.longPress = it.toString() }
            extraProps["textToSend"]?.let { key.textToSend = it.toString() }
            extraProps["textToSendLongPress"]?.let { key.textToSendLongPress = it.toString() }
            extraProps["codeToSendClick"]?.let { 
                when (it) {
                    is Int -> key.codeToSendClick = it
                    is String -> key.codeToSendClick = it.toIntOrNull() ?: 0
                }
            }
            extraProps["codeToSendLongPress"]?.let { 
                when (it) {
                    is Int -> key.codeToSendLongPress = it
                    is String -> key.codeToSendLongPress = it.toIntOrNull() ?: 0
                }
            }
            
            // --- [ بداية الإضافة ] ---
            extraProps["leftScroll"]?.let { key.leftScroll = it.toString() }
            extraProps["rightScroll"]?.let { key.rightScroll = it.toString() }
            extraProps["textToSendLeftScroll"]?.let { key.textToSendLeftScroll = it.toString() }
            extraProps["textToSendRightScroll"]?.let { key.textToSendRightScroll = it.toString() }
            
            extraProps["codeToSendLeftScroll"]?.let { 
                when (it) {
                    is Int -> key.codeToSendLeftScroll = it
                    is String -> key.codeToSendLeftScroll = it.toIntOrNull() ?: 0
                }
            }
            extraProps["codeToSendRightScroll"]?.let { 
                when (it) {
                    is Int -> key.codeToSendRightScroll = it
                    is String -> key.codeToSendRightScroll = it.toIntOrNull() ?: 0
                }
            }
            // --- [ نهاية الإضافة ] ---

            // تعيين popupKeys
            if (popupKeys.isNotEmpty()) {
                key.hint = popupKeys
            }
        }
        
        return key
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
        
        // إضافة الخصائص الخاصة للمفاتيح من نوع All
        if (key is All && keyObj != null) {
            try {
                // تعيين click
                val click = keyObj.optString("click", "")
                if (click.isNotEmpty()) {
                    key.click = click
                }
                
                // تعيين longPress
                val longPress = keyObj.optString("longPress", "")
                if (longPress.isNotEmpty()) {
                    key.longPress = longPress
                }
                
                // تعيين textToSend
                val textToSend = keyObj.optString("textToSend", "")
                if (textToSend.isNotEmpty()) {
                    key.textToSend = textToSend
                }
                
                // تعيين textToSendLongPress 
                val textToSendLongPress = keyObj.optString("textToSendLongPress", "")
                if (textToSendLongPress.isNotEmpty()) {
                    key.textToSendLongPress = textToSendLongPress
                }
                
                // تعيين codeToSendClick
                if (keyObj.has("codeToSendClick")) {
                    key.codeToSendClick = keyObj.getInt("codeToSendClick")
                }
                
                // تعيين codeToSendLongPress
                if (keyObj.has("codeToSendLongPress")) {
                    key.codeToSendLongPress = keyObj.getInt("codeToSendLongPress")
                }

                // --- [ بداية الإضافة ] ---
                
                // تعيين leftScroll
                val leftScroll = keyObj.optString("leftScroll", "")
                if (leftScroll.isNotEmpty()) {
                    key.leftScroll = leftScroll
                }

                // تعيين rightScroll
                val rightScroll = keyObj.optString("rightScroll", "")
                if (rightScroll.isNotEmpty()) {
                    key.rightScroll = rightScroll
                }

                // تعيين textToSendLeftScroll
                val textToSendLeftScroll = keyObj.optString("textToSendLeftScroll", "")
                if (textToSendLeftScroll.isNotEmpty()) {
                    key.textToSendLeftScroll = textToSendLeftScroll
                }

                // تعيين textToSendRightScroll
                val textToSendRightScroll = keyObj.optString("textToSendRightScroll", "")
                if (textToSendRightScroll.isNotEmpty()) {
                    key.textToSendRightScroll = textToSendRightScroll
                }

                // تعيين codeToSendLeftScroll
                if (keyObj.has("codeToSendLeftScroll")) {
                    key.codeToSendLeftScroll = keyObj.getInt("codeToSendLeftScroll")
                }

                // تعيين codeToSendRightScroll
                if (keyObj.has("codeToSendRightScroll")) {
                    key.codeToSendRightScroll = keyObj.getInt("codeToSendRightScroll")
                }
                
                // --- [ نهاية الإضافة ] ---
                
                // تعيين popupKeys من hint
                if (popupKeys.isNotEmpty()) {
                    key.hint = popupKeys
                }
                
            } catch (ex: Exception) {
                Log.e(TAG, "Failed to set properties for All key: ${ex.message}", ex)
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