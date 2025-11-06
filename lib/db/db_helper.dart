
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
      version: 1,
      onCreate: _onCreate,
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

  // حفظ أو تحديث التخطيط
  Future<void> insertOrUpdate(String lang, Map<String, dynamic> layoutMap) async {
    final db = await database;
    String layoutJson = jsonEncode(layoutMap);
    await db.insert(
      'layouts',
      {'lang': lang, 'layout': layoutJson},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // الحصول على التخطيط
  Future<Map<String, dynamic>?> getLayout(String lang) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'layouts',
      where: 'lang = ?',
      whereArgs: [lang],
    );

    if (results.isNotEmpty) {
      String layoutJson = results.first['layout'];
      return jsonDecode(layoutJson);
    }
    return null;
  }

  // الحصول على التخطيط أو إنشاء واحد افتراضي
  Future<Map<String, dynamic>> getOrCreateLayout(String lang) async {
    Map<String, dynamic>? existing = await getLayout(lang);
    if (existing != null) return existing;

    Map<String, dynamic> defaultLayout = lang == 'ar' ? _getDefaultArabic() : _getDefaultEnglish();
    await insertOrUpdate(lang, defaultLayout);
    return defaultLayout;
  }

  // إدراج التخطيطات الافتراضية
  Future<void> insertDefaultLayouts() async {
    if (await getLayout('en') == null) {
      await insertOrUpdate('en', _getDefaultEnglish());
    }
    if (await getLayout('ar') == null) {
      await insertOrUpdate('ar', _getDefaultArabic());
    }
  }

  Map<String, dynamic> _getDefaultEnglish() {
    return {
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
        "1": "!", "2": "@", "3": "#", "4": "\$", "5": "%",
        "6": "^", "7": "&", "8": "*", "9": "(", "0": ")"
      },
      "row1": {
        "q": "( ) ()", "w": "{ } {}", "e": "[ ] []", "r": "& &&", "t": "| ||",
        "y": "= == =>", "u": "+ ++ +=", "i": "- ->", "o": "\$", "p": "#"
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
    };
  }

  Map<String, dynamic> _getDefaultArabic() {
    return {
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
    };
  }
}
