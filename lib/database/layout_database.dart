
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/keyboard_layout.dart';

class LayoutDatabase {
  static Database? _database;
  static const String tableName = 'layouts';
  static const String columnLang = 'lang';
  static const String columnJson = 'layout';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'layouts1.db');
    
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        $columnLang TEXT PRIMARY KEY,
        $columnJson TEXT NOT NULL
      )
    ''');
    
    // إضافة التخطيطات الافتراضية
    await _insertDefaultLayouts(db);
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('DROP TABLE IF EXISTS $tableName');
    await _onCreate(db, newVersion);
  }

  static Future<void> insertOrUpdate(String lang, String layoutJson) async {
    final db = await database;
    await db.insert(
      tableName,
      {columnLang: lang, columnJson: layoutJson},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<String?> getLayout(String lang) async {
    final db = await database;
    final result = await db.query(
      tableName,
      columns: [columnJson],
      where: '$columnLang = ?',
      whereArgs: [lang],
    );
    
    if (result.isNotEmpty) {
      return result.first[columnJson] as String;
    }
    return null;
  }

  static Future<List<String>> getAllLanguages() async {
    final db = await database;
    final result = await db.query(
      tableName,
      columns: [columnLang],
    );
    
    return result.map((row) => row[columnLang] as String).toList();
  }

  static Future<void> deleteLayout(String lang) async {
    final db = await database;
    await db.delete(
      tableName,
      where: '$columnLang = ?',
      whereArgs: [lang],
    );
  }

  static Future<void> deleteAllLayouts() async {
    final db = await database;
    await db.delete(tableName);
  }

  static Future<void> resetToDefaults() async {
    final db = await database;
    await db.delete(tableName);
    await _insertDefaultLayouts(db);
  }

  static Future<KeyboardLayout?> getKeyboardLayout(String lang) async {
    final jsonString = await getLayout(lang);
    if (jsonString != null) {
      return KeyboardLayout.fromJson(lang, jsonString);
    }
    return null;
  }

  static Future<void> saveKeyboardLayout(KeyboardLayout layout) async {
    await insertOrUpdate(layout.lang, layout.toJsonString());
  }

  static Future<void> _insertDefaultLayouts(Database db) async {
    const defaultEnglish = '''
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
      {"type": "All", "weight": 1.0, "text": "4", "hint": "\$", "click": "sendText", "longPress": "showPopup", "textToSend": "4"},
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
      {"type": "All", "weight": 1.0, "text": "o", "hint": "\$", "click": "sendText", "longPress": "showPopup", "textToSend": "o"},
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
      {"type": "All", "weight": 1.0, "text": "x", "hint": "\\\" \\\"\\\"", "click": "sendText", "longPress": "showPopup", "textToSend": "x"},
      {"type": "All", "weight": 1.0, "text": "c", "hint": "`", "click": "sendText", "longPress": "showPopup", "textToSend": "c"},
      {"type": "All", "weight": 1.0, "text": "v", "hint": "< <= <>", "click": "sendText", "longPress": "showPopup", "textToSend": "v"},
      {"type": "All", "weight": 1.0, "text": "b", "hint": "> >= </>", "click": "sendText", "longPress": "showPopup", "textToSend": "b"},
      {"type": "All", "weight": 1.0, "text": "n", "hint": "/ // /**/", "click": "sendText", "longPress": "showPopup", "textToSend": "n"},
      {"type": "All", "weight": 1.0, "text": "m", "hint": "\\\\", "click": "sendText", "longPress": "showPopup", "textToSend": "m"},
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
''';

    const defaultArabic = '''
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
      {"type": "All", "weight": 1.0, "text": "2", "hint": "\\"", "click": "sendText", "longPress": "showPopup", "textToSend": "2"},
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
''';

    await db.insert(tableName, {columnLang: 'en', columnJson: defaultEnglish});
    await db.insert(tableName, {columnLang: 'ar', columnJson: defaultArabic});
  }
}
