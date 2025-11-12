import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'layouts.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE layouts (
        lang TEXT PRIMARY KEY,
        layout TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('DROP TABLE IF EXISTS layouts');
    await _onCreate(db, newVersion);
  }

  // إدراج أو تحديث تخطيط
  Future<void> insertOrUpdate(String lang, String layoutJson) async {
    final db = await database;
    await db.insert(
      'layouts',
      {
        'lang': lang,
        'layout': layoutJson,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // الحصول على تخطيط بلغة معينة
  Future<String?> getLayout(String lang) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'layouts',
      where: 'lang = ?',
      whereArgs: [lang],
    );

    if (maps.isNotEmpty) {
      return maps.first['layout'] as String;
    }
    return null;
  }

  // الحصول على جميع التخطيطات
  Future<Map<String, String>> getAllLayouts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('layouts');
    
    Map<String, String> layouts = {};
    for (var map in maps) {
      layouts[map['lang']] = map['layout'];
    }
    return layouts;
  }

  // حذف تخطيط
  Future<void> deleteLayout(String lang) async {
    final db = await database;
    await db.delete(
      'layouts',
      where: 'lang = ?',
      whereArgs: [lang],
    );
  }

  // حذف جميع التخطيطات
  Future<void> deleteAllLayouts() async {
    final db = await database;
    await db.delete('layouts');
  }

  // إدراج التخطيطات الافتراضية
  Future<void> insertDefaultLayouts() async {
    String? enLayout = await getLayout('en');
    if (enLayout == null) {
      await insertOrUpdate('en', _getDefaultEnglishJson());
    }

    String? arLayout = await getLayout('ar');
    if (arLayout == null) {
      await insertOrUpdate('ar', _getDefaultArabicJson());
    }
  }

  // الحصول على تخطيط أو إنشاء افتراضي
  Future<String> getOrCreateLayout(String lang) async {
    String? existing = await getLayout(lang);
    if (existing != null) return existing;

    String json = lang == 'ar' ? _getDefaultArabicJson() : _getDefaultEnglishJson();
    await insertOrUpdate(lang, json);
    return json;
  }

  String _getDefaultEnglishJson() {
    return jsonEncode({
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
          {"type": "All", "weight": 1.0, "text": "4", "hint": "\$", "click": "sendText", "longPress": "showPopup", "textToSend": "4"},
          {"type": "All", "weight": 1.0, "text": "5", "hint": "%", "click": "sendText", "longPress": "showPopup", "textToSend": "5"},
          {"type": "All", "weight": 1.0, "text": "6", "hint": "^", "click": "sendText", "longPress": "showPopup", "textToSend": "6"},
          {"type": "All", "weight": 1.0, "text": "7", "hint": "&", "click": "sendText", "longPress": "showPopup", "textToSend": "7"},
          {"type": "All", "weight": 1.0, "text": "8", "hint": "*", "click": "sendText", "longPress": "showPopup", "textToSend": "8"},
          {"type": "All", "weight": 1.0, "text": "9", "hint": "(", "click": "sendText", "longPress": "showPopup", "textToSend": "9"},
          {"type": "All", "weight": 1.0, "text": "0", "hint": ")", "click": "sendText", "longPress": "showPopup", "textToSend": "0"}
        ]
      }
    });
  }

  String _getDefaultArabicJson() {
    return jsonEncode({
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
      }
    });
  }
}