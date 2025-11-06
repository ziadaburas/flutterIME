package com.example.ime.db

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import android.content.ContentValues
import android.database.Cursor

class KeyboardLayoutDB(context: Context) : SQLiteOpenHelper(context, DATABASE_NAME, null, DATABASE_VERSION) {

    companion object {
        private const val DATABASE_NAME = "layouts.db"
        private const val DATABASE_VERSION = 1

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

    // ====== التخطيطات الافتراضية ======

    private fun defaultEnglishJson(): String = """
    {
      "navRow": {
        "Left": {"hint": "", "fun": "loop"},
        "Up": {"hint": "Home", "fun": "sendHome"},
        "Tab": {"hint": "", "fun": ""},
        "Ctrl": {"fun": "hold"},
        "Alt": {"fun": "hold"},
        "Shift": {"fun": "hold"},
        "Down": {"hint": "End", "fun": "sendEnd"},
        "Right": {"hint": "", "fun": ""}
      },
      "numRow": {
        "1": "!", "2": "@", "3": "#", "4": "$", "5": "%",
        "6": "^", "7": "&", "8": "*", "9": "(", "0": ")"
      },
      "row1": {
        "q": "( ) ()", "w": "{ } {}", "e": "[ ] []", "r": "& &&", "t": "| ||",
        "y": "= == =>", "u": "+ ++ +=", "i": "- ->", "o": "$", "p": "#"
      },
      "row2": {
        "a": "@ • @gmail.com", "s": "! !=", "d": "~", "f": "?",
        "g": "* **", "h": "%", "j": "_ __", "k": ":", "l": ";"
      },
      "row3": {
        "z": "' ''", "x": "\" \"\"", "c": "`", "v": "< <= <>", 
        "b": "> >= </>", "n": "/ // /**/", "m": "\\"
      },
      "bottomRow": {
        "symbols": "123", "emoji": "", "comma": ",", "space": "", 
        "dot": ".", "clip": "", "enter": "⏎"
      }
    }
    """.trimIndent()

    private fun defaultArabicJson(): String = """
    {
      "navRow": {
        "Left": {"hint": "", "fun": "loop"},
        "Up": {"hint": "Home", "fun": "sendHome"},
        "Tab": {"hint": "", "fun": ""},
        "Ctrl": {"fun": "hold"},
        "Alt": {"fun": "hold"},
        "Shift": {"fun": "hold"},
        "Down": {"hint": "End", "fun": "sendEnd"},
        "Right": {"hint": "", "fun": ""}
      },
      "numRow": {
        "1": "!", "2": "\"", "3": "·", "4": ":", "5": "؟",
        "6": "؛", "7": "-", "8": "_", "9": "(", "0": ")"
      },
      "row1": {
        "ض": "!", "ص": "!", "ق": "!", "ف": "!", "غ": "!", "ع": "!",
        "ه": "!", "خ": "!", "ح": "!", "ج": "!"
      },
      "row2": {
        "ش": "!", "س": "!", "ي": "ى ئ", "ب": "!", "ل": "!",
        "ا": "ء أ إ آ", "ت": "ـ", "ن": "!", "م": "!", "ك": "؛"
      },
      "row3": {
        "ظ": "َ ِ ُ ً ٍ ٌ ّ ْ", "ط": "!", "ذ": "!", "د": "!", 
        "ز": "!", "ر": "!", "و": "ؤ", "ة": "!", "ث": "!"
      },
      "bottomRow": {
        "symbols": "123", "emoji": "", "comma": "،", "space": "",
        "dot": ".", "clip": "", "enter": "⏎"
      }
    }
    """.trimIndent()
}
