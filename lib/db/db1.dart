import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('layouts.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE layouts (
        lang TEXT PRIMARY KEY,
        layout TEXT NOT NULL
      )
    ''');
  }

  // إدراج أو تحديث التخطيط
  Future<void> insertOrUpdateLayout(String lang, String layoutJson) async {
    final db = await database;
    await db.insert(
      'layouts',
      {'lang': lang, 'layout': layoutJson},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // الحصول على التخطيط
  Future<String?> getLayout(String lang) async {
    final db = await database;
    final result = await db.query(
      'layouts',
      where: 'lang = ?',
      whereArgs: [lang],
    );

    if (result.isNotEmpty) {
      return result.first['layout'] as String;
    }
    return null;
  }

  // إنشاء التخطيطات الافتراضية
  Future<void> insertDefaultLayouts() async {
    if (await getLayout('en') == null) {
      await insertOrUpdateLayout('en', _defaultEnglishJson());
    }
    if (await getLayout('ar') == null) {
      await insertOrUpdateLayout('ar', _defaultArabicJson());
    }
  }

  // الحصول على التخطيط أو إنشاء واحد افتراضي
  Future<String> getOrCreateLayout(String lang) async {
    final existing = await getLayout(lang);
    if (existing != null) return existing;

    final json = lang == 'ar' ? _defaultArabicJson() : _defaultEnglishJson();
    await insertOrUpdateLayout(lang, json);
    return json;
  }

  String _defaultEnglishJson() {
    final layout = {
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
        "1": "!",
        "2": "@",
        "3": "#",
        "4": "\$",
        "5": "%",
        "6": "^",
        "7": "&",
        "8": "*",
        "9": "(",
        "0": ")"
      },
      "row1": {
        "q": "( ) ()",
        "w": "{ } {}",
        "e": "[ ] []",
        "r": "& &&",
        "t": "| ||",
        "y": "= == =>",
        "u": "+ ++ +=",
        "i": "- ->",
        "o": "\$",
        "p": "#"
      },
      "row2": {
        "a": "@ • @gmail.com",
        "s": "! !=",
        "d": "~",
        "f": "?",
        "g": "* **",
        "h": "%",
        "j": "_ __",
        "k": ":",
        "l": ";"
      },
      "row3": {
        "z": "' ''",
        "x": "\" \"\"",
        "c": "`",
        "v": "< <= <>",
        "b": "> >= </>",
        "n": "/ // /**/",
        "m": "\\"
      },
      "bottomRow": {
        "symbols": "123",
        "emoji": "",
        "comma": ",",
        "space": "",
        "dot": ".",
        "clip": "",
        "enter": "⏎"
      }
    };
    return jsonEncode(layout);
  }

  String _defaultArabicJson() {
    final layout = {
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
        "1": "!",
        "2": "\"",
        "3": "·",
        "4": ":",
        "5": "؟",
        "6": "؛",
        "7": "-",
        "8": "_",
        "9": "(",
        "0": ")"
      },
      "row1": {
        "ض": "!",
        "ص": "!",
        "ق": "!",
        "ف": "!",
        "غ": "!",
        "ع": "!",
        "ه": "!",
        "خ": "!",
        "ح": "!",
        "ج": "!"
      },
      "row2": {
        "ش": "!",
        "س": "!",
        "ي": "ى ئ",
        "ب": "!",
        "ل": "!",
        "ا": "ء أ إ آ",
        "ت": "ـ",
        "ن": "!",
        "م": "!",
        "ك": "؛"
      },
      "row3": {
        "ظ": "َ ِ ُ ً ٍ ٌ ّ ْ",
        "ط": "!",
        "ذ": "!",
        "د": "!",
        "ز": "!",
        "ر": "!",
        "و": "ؤ",
        "ة": "!",
        "ث": "!"
      },
      "bottomRow": {
        "symbols": "123",
        "emoji": "",
        "comma": "،",
        "space": "",
        "dot": ".",
        "clip": "",
        "enter": "⏎"
      }
    };
    return jsonEncode(layout);
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}