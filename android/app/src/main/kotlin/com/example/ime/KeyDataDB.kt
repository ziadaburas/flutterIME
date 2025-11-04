package com.example.ime.keyData

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import java.io.File
data class KeyData(
    val type: String,
    val text: String,
    val popupKeys: String,
    val clickFn: String,
    val longPressFn: String,
    val clickParam: String,
    val longPressParam: String,
    val keyCode: Int
) {
    fun toJson(): String = Gson().toJson(this)
    companion object {
        fun fromJson(json: String): KeyData {
            return Gson().fromJson(json, KeyData::class.java)
        }
    }
}

class KeyDataDbHelper(context: Context) : SQLiteOpenHelper(context, DB_NAME, null, DB_VERSION) {

    companion object {
        private const val DB_NAME = "keyboard.db"
        private const val DB_VERSION = 1
        private const val TABLE_NAME = "layouts"
    }

    override fun onCreate(db: SQLiteDatabase) {
        val sql = """
            CREATE TABLE $TABLE_NAME (
                name TEXT PRIMARY KEY,
                data_json TEXT
            )
        """.trimIndent()
        db.execSQL(sql)
    }

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        db.execSQL("DROP TABLE IF EXISTS $TABLE_NAME")
        onCreate(db)
    }

    // ✅ حفظ مصفوفة مربعة من KeyData تحت اسم معين
    fun saveLayout(name: String, matrix: List<List<KeyData>>): Long {
        val db = writableDatabase
        val values = ContentValues().apply {
            val json = Gson().toJson(matrix)
            put("name", name)
            put("data_json", json)
        }
        return db.insertWithOnConflict(TABLE_NAME, null, values, SQLiteDatabase.CONFLICT_REPLACE)
    }

    // ✅ تحميل مصفوفة مربعة من KeyData حسب الاسم
    fun loadLayout(name: String): List<List<KeyData>>? {
        val db = readableDatabase
        val cursor = db.rawQuery("SELECT data_json FROM $TABLE_NAME WHERE name = ?", arrayOf(name))
        var result: List<List<KeyData>>? = null

        if (cursor.moveToFirst()) {
            val json = cursor.getString(0)
            val type = object : TypeToken<List<List<KeyData>>>() {}.type
            result = Gson().fromJson(json, type)
        }

        cursor.close()
        return result
    }

    // ✅ حذف تخطيط
    fun deleteLayout(name: String) {
        writableDatabase.delete(TABLE_NAME, "name = ?", arrayOf(name))
    }

    // ✅ استرجاع كل أسماء التخطيطات
    fun getAllLayoutNames(): List<String> {
        val cursor = readableDatabase.rawQuery("SELECT name FROM $TABLE_NAME", null)
        val names = mutableListOf<String>()
        if (cursor.moveToFirst()) {
            do {
                names.add(cursor.getString(0))
            } while (cursor.moveToNext())
        }
        cursor.close()
        return names
    }
}
