
package com.example.ime.db

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import android.content.ContentValues
import android.database.Cursor

class KeyboardLayoutDB(context: Context) : SQLiteOpenHelper(context, DATABASE_NAME, null, DATABASE_VERSION) {

    companion object {
        private const val DATABASE_NAME = "layouts1.db"
        private const val DATABASE_VERSION = 2  // تم تغيير الإصدار للبنية الجديدة

        const val TABLE_NAME = "layouts"
        const val COLUMN_LANG = "lang"
        const val COLUMN_JSON = "layout"
    }

    override fun onCreate(db: SQLiteDatabase) {
        val createTable = """
            CREATE TABLE $TABLE_NAME (
                $COLUMN_LANG TEXT PRIMARY KEY,
                $COLUMN_JSON TEXT NOT NULL
            );
        """.trimIndent()
        db.execSQL(createTable)
    }

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        db.execSQL("DROP TABLE IF EXISTS $TABLE_NAME")
        onCreate(db)
    }

    // ====== دوال CRUD ======

    fun insertOrUpdate(lang: String, layoutJson: String) {
        val db = this.writableDatabase
        val values = ContentValues().apply {
            put(COLUMN_LANG, lang)
            put(COLUMN_JSON, layoutJson)
        }
        db.insertWithOnConflict(TABLE_NAME, null, values, SQLiteDatabase.CONFLICT_REPLACE)
        db.close()
    }

    fun getLayout(lang: String): String? {
        val db = this.readableDatabase
        val cursor: Cursor = db.query(
            TABLE_NAME,
            arrayOf(COLUMN_JSON),
            "$COLUMN_LANG = ?",
            arrayOf(lang),
            null, null, null
        )

        var layout: String? = null
        if (cursor.moveToFirst()) {
            layout = cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_JSON))
        }

        cursor.close()
        db.close()
        return layout
    }

    // ====== إنشاء التخطيطات الافتراضية ======

    fun insertDefaultLayouts() {
        if (getLayout("en") == null) insertOrUpdate("en", defaultEnglishJson())
        if (getLayout("ar") == null) insertOrUpdate("ar", defaultArabicJson())
    }

    fun getOrCreateLayout(lang: String): String {
        val existing = getLayout(lang)
        if (existing != null) return existing

        val json = if (lang == "ar") defaultArabicJson() else defaultEnglishJson()
        insertOrUpdate(lang, json)
        return json
    }
  /**
     * دالة لحذف جميع محتويات (السجلات) من جدول التخطيطات.
     */
    fun deleteAllLayouts() {
        val db = this.writableDatabase
        try {
            // تنفيذ أمر الحذف لجميع الصفوف
            // يرسل: DELETE FROM layouts
            db.delete(TABLE_NAME, null, null)
        } catch (e: Exception) {
            // يمكنك إضافة معالجة للأخطاء هنا إذا أردت
            e.printStackTrace()
        } finally {
            // التأكد من إغلاق الاتصال بقاعدة البيانات
            // (بما أنك تغلقه في دوالك الأخرى، سنتبع نفس النمط)
            db.close()
        }
    }

    // ====== التخطيطات الافتراضية بالبنية الجديدة ======

    private fun defaultEnglishJson(): String = """
    {
      "row1": {
        "height": 45,
        "keys": [
          {"type": "All", "weight": 1.0, "text": "←", "hint": "", "click": "sendCode", "longPress": "loop", "codeToSendClick": 21, "codeToSendLongPress": 0},
          {"type": "All", "weight": 1.0, "text": "↑", "hint": "Home", "click": "sendCode", "longPress": "sendCode", "codeToSendClick": 19, "codeToSendLongPress": 122},
          {"type": "All", "weight": 1.0, "text": "⇥", "hint": "", "click": "sendCode", "longPress": "", "codeToSendClick": 61, "codeToSendLongPress": 0},
          {"type": "ctrl", "weight": 1.0, "text": "Ctrl", "hint": ""},
          {"type": "alt", "weight": 1.0, "text": "Alt", "hint": ""},
          {"type": "shift", "weight": 1.0, "text": "Shift", "hint": ""},
          {"type": "All", "weight": 1.0, "text": "↓", "hint": "End", "click": "sendCode", "longPress": "sendCode", "codeToSendClick": 20, "codeToSendLongPress": 123},
          {"type": "All", "weight": 1.0, "text": "→", "hint": "", "click": "sendCode", "longPress": "", "codeToSendClick": 22, "codeToSendLongPress": 0}
        ]
      },
      "row2": {
        "height": 55,
        "keys": [
          {"type": "All", "weight": 1.0, "text": "1", "hint": "!", "click": "sendText", "longPress": "showPopup", "textToSend": "1"},
          {"type": "All", "weight": 1.0, "text": "2", "hint": "@", "click": "sendText", "longPress": "showPopup", "textToSend": "2"},
          {"type": "All", "weight": 1.0, "text": "3", "hint": "#", "click": "sendText", "longPress": "showPopup", "textToSend": "3"},
          {"type": "All", "weight": 1.0, "text": "4", "hint": "$", "click": "sendText", "longPress": "showPopup", "textToSend": "4"},
          {"type": "All", "weight": 1.0, "text": "5", "hint": "%", "click": "sendText", "longPress": "showPopup", "textToSend": "5"},
          {"type": "All", "weight": 1.0, "text": "6", "hint": "^", "click": "sendText", "longPress": "showPopup", "textToSend": "6"},
          {"type": "All", "weight": 1.0, "text": "7", "hint": "&", "click": "sendText", "longPress": "showPopup", "textToSend": "7"},
          {"type": "All", "weight": 1.0, "text": "8", "hint": "*", "click": "sendText", "longPress": "showPopup", "textToSend": "8"},
          {"type": "All", "weight": 1.0, "text": "9", "hint": "(", "click": "sendText", "longPress": "showPopup", "textToSend": "9"},
          {"type": "All", "weight": 1.0, "text": "0", "hint": ")", "click": "sendText", "longPress": "showPopup", "textToSend": "0"}
        ]
      },
      "row3": {
        "height": 55,
        "keys": [
          {"type": "All", "weight": 1.0, "text": "q", "hint": "( ) ()", "click": "sendText", "longPress": "showPopup", "textToSend": "q"},
          {"type": "All", "weight": 1.0, "text": "w", "hint": "{ } {}", "click": "sendText", "longPress": "showPopup", "textToSend": "w"},
          {"type": "All", "weight": 1.0, "text": "e", "hint": "[ ] []", "click": "sendText", "longPress": "showPopup", "textToSend": "e"},
          {"type": "All", "weight": 1.0, "text": "r", "hint": "& &&", "click": "sendText", "longPress": "showPopup", "textToSend": "r"},
          {"type": "All", "weight": 1.0, "text": "t", "hint": "| ||", "click": "sendText", "longPress": "showPopup", "textToSend": "t"},
          {"type": "All", "weight": 1.0, "text": "y", "hint": "= == =>", "click": "sendText", "longPress": "showPopup", "textToSend": "y"},
          {"type": "All", "weight": 1.0, "text": "u", "hint": "+ ++ +=", "click": "sendText", "longPress": "showPopup", "textToSend": "u"},
          {"type": "All", "weight": 1.0, "text": "i", "hint": "- ->", "click": "sendText", "longPress": "showPopup", "textToSend": "i"},
          {"type": "All", "weight": 1.0, "text": "o", "hint": "$", "click": "sendText", "longPress": "showPopup", "textToSend": "o"},
          {"type": "All", "weight": 1.0, "text": "p", "hint": "#", "click": "sendText", "longPress": "showPopup", "textToSend": "p"}
        ]
      },
      "row4": {
        "height": 55,
        "keys": [
          {"type": "All", "weight": 1.0, "text": "a", "hint": "@ • @gmail.com", "click": "sendText", "longPress": "showPopup", "textToSend": "a"},
          {"type": "All", "weight": 1.0, "text": "s", "hint": "! !=", "click": "sendText", "longPress": "showPopup", "textToSend": "s"},
          {"type": "All", "weight": 1.0, "text": "d", "hint": "~", "click": "sendText", "longPress": "showPopup", "textToSend": "d"},
          {"type": "All", "weight": 1.0, "text": "f", "hint": "?", "click": "sendText", "longPress": "showPopup", "textToSend": "f"},
          {"type": "All", "weight": 1.0, "text": "g", "hint": "* **", "click": "sendText", "longPress": "showPopup", "textToSend": "g"},
          {"type": "All", "weight": 1.0, "text": "h", "hint": "%", "click": "sendText", "longPress": "showPopup", "textToSend": "h"},
          {"type": "All", "weight": 1.0, "text": "j", "hint": "_ __", "click": "sendText", "longPress": "showPopup", "textToSend": "j"},
          {"type": "All", "weight": 1.0, "text": "k", "hint": ":", "click": "sendText", "longPress": "showPopup", "textToSend": "k"},
          {"type": "All", "weight": 1.0, "text": "l", "hint": ";", "click": "sendText", "longPress": "showPopup", "textToSend": "l"}
        ]
      },
      "row5": {
        "height": 55,
        "keys": [
          {"type": "capslock", "weight": 1.5, "text": "⇧", "hint": ""},
          {"type": "All", "weight": 1.0, "text": "z", "hint": "' ''", "click": "sendText", "longPress": "showPopup", "textToSend": "z"},
          {"type": "All", "weight": 1.0, "text": "x", "hint": "\" \"\"", "click": "sendText", "longPress": "showPopup", "textToSend": "x"},
          {"type": "All", "weight": 1.0, "text": "c", "hint": "`", "click": "sendText", "longPress": "showPopup", "textToSend": "c"},
          {"type": "All", "weight": 1.0, "text": "v", "hint": "< <= <>", "click": "sendText", "longPress": "showPopup", "textToSend": "v"},
          {"type": "All", "weight": 1.0, "text": "b", "hint": "> >= </>", "click": "sendText", "longPress": "showPopup", "textToSend": "b"},
          {"type": "All", "weight": 1.0, "text": "n", "hint": "/ // /**/", "click": "sendText", "longPress": "showPopup", "textToSend": "n"},
          {"type": "All", "weight": 1.0, "text": "m", "hint": "\\", "click": "sendText", "longPress": "showPopup", "textToSend": "m"},
          {"type": "delete", "weight": 1.5, "text": "⌫", "hint": ""}
        ]
      },
      "row6": {
        "height": 60,
        "keys": [
          {"type": "symbols", "weight": 1.5, "text": "123", "hint": ""},
          {"type": "emoji", "weight": 1.0, "text": "", "hint": ""},
          {"type": "All", "weight": 1.0, "text": ",", "hint": "", "click": "sendText", "longPress": "", "textToSend": ","},
          {"type": "space", "weight": 3.0, "text": "Space", "hint": ""},
          {"type": "All", "weight": 1.0, "text": ".", "hint": "", "click": "sendText", "longPress": "", "textToSend": "."},
          {"type": "clip", "weight": 1.0, "text": "", "hint": ""},
          {"type": "All", "weight": 1.5, "text": "⏎", "hint": "", "click": "sendCode", "longPress": "", "codeToSendClick": 66, "codeToSendLongPress": 0}
        ]
      }
    }
    """.trimIndent()

    private fun defaultArabicJson(): String = """
    {
      "row1": {
        "height": 45,
        "keys": [
          {"type": "All", "weight": 1.0, "text": "←", "hint": "", "click": "sendCode", "longPress": "", "codeToSendClick": 21, "codeToSendLongPress": 0},
          {"type": "All", "weight": 1.0, "text": "↑", "hint": "Home", "click": "sendCode", "longPress": "sendCode", "codeToSendClick": 19, "codeToSendLongPress": 122},
          {"type": "All", "weight": 1.0, "text": "⇥", "hint": "", "click": "sendCode", "longPress": "", "codeToSendClick": 61, "codeToSendLongPress": 0},
          {"type": "ctrl", "weight": 1.0, "text": "Ctrl", "hint": ""},
          {"type": "alt", "weight": 1.0, "text": "Alt", "hint": ""},
          {"type": "shift", "weight": 1.0, "text": "Shift", "hint": ""},
          {"type": "All", "weight": 1.0, "text": "↓", "hint": "End", "click": "sendCode", "longPress": "sendCode", "codeToSendClick": 20, "codeToSendLongPress": 123},
          {"type": "All", "weight": 1.0, "text": "→", "hint": "", "click": "sendCode", "longPress": "", "codeToSendClick": 22, "codeToSendLongPress": 0}
        ]
      },
      "row2": {
        "height": 55,
        "keys": [
          {"type": "All", "weight": 1.0, "text": "1", "hint": "!", "click": "sendText", "longPress": "showPopup", "textToSend": "1"},
          {"type": "All", "weight": 1.0, "text": "2", "hint": "\"", "click": "sendText", "longPress": "showPopup", "textToSend": "2"},
          {"type": "All", "weight": 1.0, "text": "3", "hint": "·", "click": "sendText", "longPress": "showPopup", "textToSend": "3"},
          {"type": "All", "weight": 1.0, "text": "4", "hint": ":", "click": "sendText", "longPress": "showPopup", "textToSend": "4"},
          {"type": "All", "weight": 1.0, "text": "5", "hint": "؟", "click": "sendText", "longPress": "showPopup", "textToSend": "5"},
          {"type": "All", "weight": 1.0, "text": "6", "hint": "؛", "click": "sendText", "longPress": "showPopup", "textToSend": "6"},
          {"type": "All", "weight": 1.0, "text": "7", "hint": "-", "click": "sendText", "longPress": "showPopup", "textToSend": "7"},
          {"type": "All", "weight": 1.0, "text": "8", "hint": "_", "click": "sendText", "longPress": "showPopup", "textToSend": "8"},
          {"type": "All", "weight": 1.0, "text": "9", "hint": "(", "click": "sendText", "longPress": "showPopup", "textToSend": "9"},
          {"type": "All", "weight": 1.0, "text": "0", "hint": ")", "click": "sendText", "longPress": "showPopup", "textToSend": "0"}
        ]
      },
      "row3": {
        "height": 55,
        "keys": [
          {"type": "All", "weight": 1.0, "text": "ض", "hint": "!", "click": "sendText", "longPress": "showPopup", "textToSend": "ض"},
          {"type": "All", "weight": 1.0, "text": "ص", "hint": "!", "click": "sendText", "longPress": "showPopup", "textToSend": "ص"},
          {"type": "All", "weight": 1.0, "text": "ق", "hint": "!", "click": "sendText", "longPress": "showPopup", "textToSend": "ق"},
          {"type": "All", "weight": 1.0, "text": "ف", "hint": "!", "click": "sendText", "longPress": "showPopup", "textToSend": "ف"},
          {"type": "All", "weight": 1.0, "text": "غ", "hint": "!", "click": "sendText", "longPress": "showPopup", "textToSend": "غ"},
          {"type": "All", "weight": 1.0, "text": "ع", "hint": "!", "click": "sendText", "longPress": "showPopup", "textToSend": "ع"},
          {"type": "All", "weight": 1.0, "text": "ه", "hint": "!", "click": "sendText", "longPress": "showPopup", "textToSend": "ه"},
          {"type": "All", "weight": 1.0, "text": "خ", "hint": "!", "click": "sendText", "longPress": "showPopup", "textToSend": "خ"},
          {"type": "All", "weight": 1.0, "text": "ح", "hint": "!", "click": "sendText", "longPress": "showPopup", "textToSend": "ح"},
          {"type": "All", "weight": 1.0, "text": "ج", "hint": "!", "click": "sendText", "longPress": "showPopup", "textToSend": "ج"}
        ]
      },
      "row4": {
        "height": 55,
        "keys": [
          {"type": "All", "weight": 1.0, "text": "ش", "hint": "!", "click": "sendText", "longPress": "showPopup", "textToSend": "ش"},
          {"type": "All", "weight": 1.0, "text": "س", "hint": "!", "click": "sendText", "longPress": "showPopup", "textToSend": "س"},
          {"type": "All", "weight": 1.0, "text": "ي", "hint": "ى ئ", "click": "sendText", "longPress": "showPopup", "textToSend": "ي"},
          {"type": "All", "weight": 1.0, "text": "ب", "hint": "!", "click": "sendText", "longPress": "showPopup", "textToSend": "ب"},
          {"type": "All", "weight": 1.0, "text": "ل", "hint": "!", "click": "sendText", "longPress": "showPopup", "textToSend": "ل"},
          {"type": "All", "weight": 1.0, "text": "ا", "hint": "ء أ إ آ", "click": "sendText", "longPress": "showPopup", "textToSend": "ا"},
          {"type": "All", "weight": 1.0, "text": "ت", "hint": "ـ", "click": "sendText", "longPress": "showPopup", "textToSend": "ت"},
          {"type": "All", "weight": 1.0, "text": "ن", "hint": "!", "click": "sendText", "longPress": "showPopup", "textToSend": "ن"},
          {"type": "All", "weight": 1.0, "text": "م", "hint": "!", "click": "sendText", "longPress": "showPopup", "textToSend": "م"},
          {"type": "All", "weight": 1.0, "text": "ك", "hint": "؛", "click": "sendText", "longPress": "showPopup", "textToSend": "ك"}
        ]
      },
      "row5": {
        "height": 55,
        "keys": [
          {"type": "All", "weight": 1.0, "text": "ظ", "hint": "َ ِ ُ ً ٍ ٌ ّ ْ", "click": "sendText", "longPress": "showPopup", "textToSend": "ظ"},
          {"type": "All", "weight": 1.0, "text": "ط", "hint": "!", "click": "sendText", "longPress": "showPopup", "textToSend": "ط"},
          {"type": "All", "weight": 1.0, "text": "ذ", "hint": "!", "click": "sendText", "longPress": "showPopup", "textToSend": "ذ"},
          {"type": "All", "weight": 1.0, "text": "د", "hint": "!", "click": "sendText", "longPress": "showPopup", "textToSend": "د"},
          {"type": "All", "weight": 1.0, "text": "ز", "hint": "!", "click": "sendText", "longPress": "showPopup", "textToSend": "ز"},
          {"type": "All", "weight": 1.0, "text": "ر", "hint": "!", "click": "sendText", "longPress": "showPopup", "textToSend": "ر"},
          {"type": "All", "weight": 1.0, "text": "و", "hint": "ؤ", "click": "sendText", "longPress": "showPopup", "textToSend": "و"},
          {"type": "All", "weight": 1.0, "text": "ة", "hint": "!", "click": "sendText", "longPress": "showPopup", "textToSend": "ة"},
          {"type": "All", "weight": 1.0, "text": "ث", "hint": "!", "click": "sendText", "longPress": "showPopup", "textToSend": "ث"},
          {"type": "delete", "weight": 1.5, "text": "⌫", "hint": ""}
        ]
      },
      "row6": {
        "height": 60,
        "keys": [
          {"type": "symbols", "weight": 1.5, "text": "123", "hint": ""},
          {"type": "emoji", "weight": 1.0, "text": "", "hint": ""},
          {"type": "All", "weight": 1.0, "text": "،", "hint": "", "click": "sendText", "longPress": "", "textToSend": "،"},
          {"type": "space", "weight": 3.0, "text": "Space", "hint": ""},
          {"type": "All", "weight": 1.0, "text": ".", "hint": "", "click": "sendText", "longPress": "", "textToSend": "."},
          {"type": "clip", "weight": 1.0, "text": "", "hint": ""},
          {"type": "All", "weight": 1.5, "text": "⏎", "hint": "", "click": "sendCode", "longPress": "", "codeToSendClick": 66, "codeToSendLongPress": 0}
        ]
      }
    }
    """.trimIndent()
}
