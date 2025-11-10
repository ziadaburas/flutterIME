package com.example.ime.db

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import android.content.ContentValues
import android.database.Cursor

class KeyboardLayoutDB(context: Context) : SQLiteOpenHelper(context, DATABASE_NAME, null, DATABASE_VERSION) {

    companion object {
        private const val DATABASE_NAME = "layouts.db"
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

    // ====== التخطيطات الافتراضية بالبنية الجديدة ======

    private fun defaultEnglishJson(): String = """
    {
      "row1": {
        "height": 45,
        "keys": [
          {"type": "loopKey", "weight": 1.0, "text": "←", "hint": "", "click": "loop"},
          {"type": "normal", "weight": 1.0, "text": "↑", "hint": "Home", "click": "sendHome", "longPress": ""},
          {"type": "normal", "weight": 1.0, "text": "⇥", "hint": "", "click": "sendKeyPress", "longPress": ""},
          {"type": "specialKey", "weight": 1.0, "text": "Ctrl", "hint": "", "keyCode": 113},
          {"type": "specialKey", "weight": 1.0, "text": "Alt", "hint": "", "keyCode": 57},
          {"type": "specialKey", "weight": 1.0, "text": "Shift", "hint": "", "keyCode": 59},
          {"type": "normal", "weight": 1.0, "text": "↓", "hint": "End", "click": "sendEnd", "longPress": ""},
          {"type": "loopKey", "weight": 1.0, "text": "→", "hint": "", "click": "loop"}
        ]
      },
      "row2": {
        "height": 55,
        "keys": [
          {"type": "letter", "weight": 1.0, "text": "1", "hint": "!"},
          {"type": "letter", "weight": 1.0, "text": "2", "hint": "@"},
          {"type": "letter", "weight": 1.0, "text": "3", "hint": "#"},
          {"type": "letter", "weight": 1.0, "text": "4", "hint": "$"},
          {"type": "letter", "weight": 1.0, "text": "5", "hint": "%"},
          {"type": "letter", "weight": 1.0, "text": "6", "hint": "^"},
          {"type": "letter", "weight": 1.0, "text": "7", "hint": "&"},
          {"type": "letter", "weight": 1.0, "text": "8", "hint": "*"},
          {"type": "letter", "weight": 1.0, "text": "9", "hint": "("},
          {"type": "letter", "weight": 1.0, "text": "0", "hint": ")"}
        ]
      },
      "row3": {
        "height": 55,
        "keys": [
          {"type": "letter", "weight": 1.0, "text": "q", "hint": "( ) ()"},
          {"type": "letter", "weight": 1.0, "text": "w", "hint": "{ } {}"},
          {"type": "letter", "weight": 1.0, "text": "e", "hint": "[ ] []"},
          {"type": "letter", "weight": 1.0, "text": "r", "hint": "& &&"},
          {"type": "letter", "weight": 1.0, "text": "t", "hint": "| ||"},
          {"type": "letter", "weight": 1.0, "text": "y", "hint": "= == =>"},
          {"type": "letter", "weight": 1.0, "text": "u", "hint": "+ ++ +="},
          {"type": "letter", "weight": 1.0, "text": "i", "hint": "- ->"},
          {"type": "letter", "weight": 1.0, "text": "o", "hint": "$"},
          {"type": "letter", "weight": 1.0, "text": "p", "hint": "#"}
        ]
      },
      "row4": {
        "height": 55,
        "keys": [
          {"type": "letter", "weight": 1.0, "text": "a", "hint": "@ • @gmail.com"},
          {"type": "letter", "weight": 1.0, "text": "s", "hint": "! !="},
          {"type": "letter", "weight": 1.0, "text": "d", "hint": "~"},
          {"type": "letter", "weight": 1.0, "text": "f", "hint": "?"},
          {"type": "letter", "weight": 1.0, "text": "g", "hint": "* **"},
          {"type": "letter", "weight": 1.0, "text": "h", "hint": "%"},
          {"type": "letter", "weight": 1.0, "text": "j", "hint": "_ __"},
          {"type": "letter", "weight": 1.0, "text": "k", "hint": ":"},
          {"type": "letter", "weight": 1.0, "text": "l", "hint": ";"}
        ]
      },
      "row5": {
        "height": 55,
        "keys": [
          {"type": "specialKey", "weight": 1.5, "text": "⇧", "hint": "", "keyCode": 115},
          {"type": "letter", "weight": 1.0, "text": "z", "hint": "' ''"},
          {"type": "letter", "weight": 1.0, "text": "x", "hint": "\" \"\""},
          {"type": "letter", "weight": 1.0, "text": "c", "hint": "`"},
          {"type": "letter", "weight": 1.0, "text": "v", "hint": "< <= <>"},
          {"type": "letter", "weight": 1.0, "text": "b", "hint": "> >= </>"},
          {"type": "letter", "weight": 1.0, "text": "n", "hint": "/ // /**/"},
          {"type": "letter", "weight": 1.0, "text": "m", "hint": "\\"},
          {"type": "delete", "weight": 1.5, "text": "⌫", "hint": ""}
        ]
      },
      "row6": {
        "height": 60,
        "keys": [
          {"type": "symbols", "weight": 1.5, "text": "123", "hint": ""},
          {"type": "emoji", "weight": 1.0, "text": "", "hint": ""},
          {"type": "letter", "weight": 1.0, "text": ",", "hint": ""},
          {"type": "space", "weight": 3.0, "text": "Space", "hint": ""},
          {"type": "letter", "weight": 1.0, "text": ".", "hint": ""},
          {"type": "clip", "weight": 1.0, "text": "", "hint": ""},
          {"type": "normal", "weight": 1.0, "text": "⏎", "hint": "", "click": "sendKeyPress", "longPress": ""}
        ]
      }
    }
    """.trimIndent()

    private fun defaultArabicJson(): String = """
    {
      "row1": {
        "height": 45,
        "keys": [
          {"type": "loopKey", "weight": 1.0, "text": "←", "hint": "", "click": "loop"},
          {"type": "normal", "weight": 1.0, "text": "↑", "hint": "Home", "click": "sendHome", "longPress": ""},
          {"type": "normal", "weight": 1.0, "text": "⇥", "hint": "", "click": "sendKeyPress", "longPress": ""},
          {"type": "specialKey", "weight": 1.0, "text": "Ctrl", "hint": "", "keyCode": 113},
          {"type": "specialKey", "weight": 1.0, "text": "Alt", "hint": "", "keyCode": 57},
          {"type": "specialKey", "weight": 1.0, "text": "Shift", "hint": "", "keyCode": 59},
          {"type": "normal", "weight": 1.0, "text": "↓", "hint": "End", "click": "sendEnd", "longPress": ""},
          {"type": "loopKey", "weight": 1.0, "text": "→", "hint": "", "click": "loop"}
        ]
      },
      "row2": {
        "height": 55,
        "keys": [
          {"type": "letter", "weight": 1.0, "text": "1", "hint": "!"},
          {"type": "letter", "weight": 1.0, "text": "2", "hint": "\""},
          {"type": "letter", "weight": 1.0, "text": "3", "hint": "·"},
          {"type": "letter", "weight": 1.0, "text": "4", "hint": ":"},
          {"type": "letter", "weight": 1.0, "text": "5", "hint": "؟"},
          {"type": "letter", "weight": 1.0, "text": "6", "hint": "؛"},
          {"type": "letter", "weight": 1.0, "text": "7", "hint": "-"},
          {"type": "letter", "weight": 1.0, "text": "8", "hint": "_"},
          {"type": "letter", "weight": 1.0, "text": "9", "hint": "("},
          {"type": "letter", "weight": 1.0, "text": "0", "hint": ")"}
        ]
      },
      "row3": {
        "height": 55,
        "keys": [
          {"type": "letter", "weight": 1.0, "text": "ض", "hint": "!"},
          {"type": "letter", "weight": 1.0, "text": "ص", "hint": "!"},
          {"type": "letter", "weight": 1.0, "text": "ق", "hint": "!"},
          {"type": "letter", "weight": 1.0, "text": "ف", "hint": "!"},
          {"type": "letter", "weight": 1.0, "text": "غ", "hint": "!"},
          {"type": "letter", "weight": 1.0, "text": "ع", "hint": "!"},
          {"type": "letter", "weight": 1.0, "text": "ه", "hint": "!"},
          {"type": "letter", "weight": 1.0, "text": "خ", "hint": "!"},
          {"type": "letter", "weight": 1.0, "text": "ح", "hint": "!"},
          {"type": "letter", "weight": 1.0, "text": "ج", "hint": "!"}
        ]
      },
      "row4": {
        "height": 55,
        "keys": [
          {"type": "letter", "weight": 1.0, "text": "ش", "hint": "!"},
          {"type": "letter", "weight": 1.0, "text": "س", "hint": "!"},
          {"type": "letter", "weight": 1.0, "text": "ي", "hint": "ى ئ"},
          {"type": "letter", "weight": 1.0, "text": "ب", "hint": "!"},
          {"type": "letter", "weight": 1.0, "text": "ل", "hint": "!"},
          {"type": "letter", "weight": 1.0, "text": "ا", "hint": "ء أ إ آ"},
          {"type": "letter", "weight": 1.0, "text": "ت", "hint": "ـ"},
          {"type": "letter", "weight": 1.0, "text": "ن", "hint": "!"},
          {"type": "letter", "weight": 1.0, "text": "م", "hint": "!"},
          {"type": "letter", "weight": 1.0, "text": "ك", "hint": "؛"}
        ]
      },
      "row5": {
        "height": 55,
        "keys": [
          {"type": "letter", "weight": 1.0, "text": "ظ", "hint": "َ ِ ُ ً ٍ ٌ ّ ْ"},
          {"type": "letter", "weight": 1.0, "text": "ط", "hint": "!"},
          {"type": "letter", "weight": 1.0, "text": "ذ", "hint": "!"},
          {"type": "letter", "weight": 1.0, "text": "د", "hint": "!"},
          {"type": "letter", "weight": 1.0, "text": "ز", "hint": "!"},
          {"type": "letter", "weight": 1.0, "text": "ر", "hint": "!"},
          {"type": "letter", "weight": 1.0, "text": "و", "hint": "ؤ"},
          {"type": "letter", "weight": 1.0, "text": "ة", "hint": "!"},
          {"type": "letter", "weight": 1.0, "text": "ث", "hint": "!"},
          {"type": "delete", "weight": 1.5, "text": "⌫", "hint": ""}
        ]
      },
      "row6": {
        "height": 60,
        "keys": [
          {"type": "symbols", "weight": 1.5, "text": "123", "hint": ""},
          {"type": "emoji", "weight": 1.0, "text": "", "hint": ""},
          {"type": "letter", "weight": 1.0, "text": "،", "hint": ""},
          {"type": "space", "weight": 3.0, "text": "Space", "hint": ""},
          {"type": "letter", "weight": 1.0, "text": ".", "hint": ""},
          {"type": "clip", "weight": 1.0, "text": "", "hint": ""},
          {"type": "normal", "weight": 1.0, "text": "⏎", "hint": "", "click": "sendKeyPress", "longPress": ""}
        ]
      }
    }
    """.trimIndent()
}