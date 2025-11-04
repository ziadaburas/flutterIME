package com.example.ime.clipboard

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import android.content.ContentValues
import android.database.Cursor
data class ClipboardItem(
    val text: String,
    val date: String,
    val isPinned: Boolean
)

class ClipboardDbHelper(context: Context) : SQLiteOpenHelper(context, DATABASE_NAME, null, DATABASE_VERSION) {

    companion object {
        private const val DATABASE_NAME = "clipboard2.db"
        private const val DATABASE_VERSION = 2 // ← غيّرنا الإصدار من 1 إلى 2

        const val TABLE_NAME = "clipboard"
        const val COLUMN_ID = "id"
        const val COLUMN_TEXT = "text"

    }

    override fun onCreate(db: SQLiteDatabase) {
        val createTable = """
            CREATE TABLE $TABLE_NAME (
                $COLUMN_ID INTEGER PRIMARY KEY AUTOINCREMENT,
                $COLUMN_TEXT TEXT NOT NULL UNIQUE,
                copied_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                pinned INTEGER DEFAULT 0
            );
        """.trimIndent()
        db.execSQL(createTable)
    }

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        if (oldVersion < 2) {
            db.execSQL("ALTER TABLE $TABLE_NAME ADD COLUMN pinned INTEGER DEFAULT 0")
        }
    }

    fun insertText(text: String) {
        val db = writableDatabase
        val sql = """
            INSERT INTO $TABLE_NAME ($COLUMN_TEXT, copied_at)
            VALUES (?, CURRENT_TIMESTAMP)
            ON CONFLICT($COLUMN_TEXT) DO UPDATE SET
                copied_at = CURRENT_TIMESTAMP
            WHERE copied_at < CURRENT_TIMESTAMP;
        """.trimIndent()

        val stmt = db.compileStatement(sql)
        stmt.bindString(1, text)
        stmt.execute()

        db.close()
    }

    fun setPinned(text: String, pinned: Boolean) {
        val db = writableDatabase
        val sql = """
            UPDATE $TABLE_NAME
            SET pinned = ?
            WHERE $COLUMN_TEXT = ?
        """.trimIndent()

        val stmt = db.compileStatement(sql)
        stmt.bindLong(1, if (pinned) 1 else 0)
        stmt.bindString(2, text)
        stmt.execute()

        db.close()
    }
    fun getAllClipboardItems(): List<ClipboardItem> {
    val db = readableDatabase
    val list = mutableListOf<ClipboardItem>()

    val cursor = db.query(
        TABLE_NAME,
        arrayOf(COLUMN_TEXT, "copied_at", "pinned"),
        null,
        null,
        null,
        null,
        "pinned DESC, copied_at DESC"
    )

    cursor.use {
        if (it.moveToFirst()) {
            do {
                val text = it.getString(it.getColumnIndexOrThrow(COLUMN_TEXT))
                val date = it.getString(it.getColumnIndexOrThrow("copied_at"))
                val pinned = it.getInt(it.getColumnIndexOrThrow("pinned")) == 1

                val item = ClipboardItem(text, date, pinned)
                list.add(item)
            } while (it.moveToNext())
        }
    }

    return list
}
fun deleteText(text: String) {
    val db = writableDatabase
    db.delete(
        TABLE_NAME,
        "$COLUMN_TEXT = ?",
        arrayOf(text)
    )
    db.close()
}

    fun getAllTextsSortedByTime(): List<String> {
        val db = readableDatabase
        val list = mutableListOf<String>()
        val cursor: Cursor = db.query(
            TABLE_NAME,
            arrayOf(COLUMN_TEXT),
            null,
            null,
            null,
            null,
            "pinned DESC, copied_at DESC"
        )
        cursor.use {
            if (it.moveToFirst()) {
                do {
                    list.add(it.getString(it.getColumnIndexOrThrow(COLUMN_TEXT)))
                } while (it.moveToNext())
            }
        }
        return list
    }

    fun getAllTexts(): List<String> {
        val db = readableDatabase
        val list = mutableListOf<String>()
        val cursor: Cursor = db.query(
            TABLE_NAME,
            arrayOf(COLUMN_TEXT),
            null,
            null,
            null,
            null,
            "$COLUMN_ID DESC"
        )
        cursor.use {
            if (it.moveToFirst()) {
                do {
                    list.add(it.getString(it.getColumnIndexOrThrow(COLUMN_TEXT)))
                } while (it.moveToNext())
            }
        }
        return list
    }

    fun selectAllTexts(): List<String> {
        val db = readableDatabase
        val list = mutableListOf<String>()
        val cursor: Cursor = db.query(
            TABLE_NAME,
            arrayOf(COLUMN_TEXT),
            null,
            null,
            null,
            null,
            "$COLUMN_ID DESC"
        )
        cursor.use {
            if (it.moveToFirst()) {
                do {
                    list.add(it.getString(it.getColumnIndexOrThrow(COLUMN_TEXT)))
                } while (it.moveToNext())
            }
        }
        return list
    }

    fun isPinned(text: String): Boolean {
        val db = readableDatabase
        val cursor = db.query(
            TABLE_NAME,
            arrayOf("pinned"),
            "$COLUMN_TEXT = ?",
            arrayOf(text),
            null,
            null,
            null
        )
        cursor.use {
            if (it.moveToFirst()) {
                return it.getInt(it.getColumnIndexOrThrow("pinned")) == 1
            }
        }
        return false
    }
    fun getClipboardItems(offset: Int=0, limit: Int=50): List<ClipboardItem> {
    val db = readableDatabase
    val list = mutableListOf<ClipboardItem>()

    val cursor = db.query(
        TABLE_NAME, // اسم الجدول
        arrayOf(COLUMN_TEXT, "copied_at", "pinned"), // الأعمدة التي نريد استرجاعها
        null, // جملة WHERE (نتركها null لأنه لا يوجد شروط)
        null, // المتغيرات لـ WHERE (نتركها null)
        null, // GROUP BY
        null, // HAVING
        "pinned DESC, copied_at DESC", // ترتيب النتائج
        "$offset, $limit" // استخدام offset و limit
    )

    cursor.use {
        if (it.moveToFirst()) {
            do {
                val text = it.getString(it.getColumnIndexOrThrow(COLUMN_TEXT))
                val date = it.getString(it.getColumnIndexOrThrow("copied_at"))
                val pinned = it.getInt(it.getColumnIndexOrThrow("pinned")) == 1

                val item = ClipboardItem(text, date, pinned)
                list.add(item)
            } while (it.moveToNext())
        }
    }

    return list
}
}
