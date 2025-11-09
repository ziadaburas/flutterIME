
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/layout.dart';

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
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
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

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      await db.execute('DROP TABLE IF EXISTS layouts');
      await _createDB(db, newVersion);
    }
  }

  // إدراج أو تحديث تخطيط
  Future<void> insertOrUpdateLayout(String lang, KeyboardLayout layout) async {
    final db = await database;
    final layoutJson = jsonEncode(layout.toJson());
    
    await db.insert(
      'layouts',
      {'lang': lang, 'layout': layoutJson},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // الحصول على تخطيط
  Future<KeyboardLayout?> getLayout(String lang) async {
    final db = await database;
    final maps = await db.query(
      'layouts',
      where: 'lang = ?',
      whereArgs: [lang],
    );

    if (maps.isNotEmpty) {
      final layoutJson = jsonDecode(maps.first['layout'] as String);
      return KeyboardLayout.fromJson(layoutJson);
    }
    return null;
  }

  // الحصول على جميع اللغات
  Future<List<String>> getAllLanguages() async {
    final db = await database;
    final result = await db.query('layouts', columns: ['lang']);
    return result.map((e) => e['lang'] as String).toList();
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

  // إنشاء التخطيطات الافتراضية
  Future<void> insertDefaultLayouts() async {
    final languages = await getAllLanguages();
    
    if (!languages.contains('en')) {
      await insertOrUpdateLayout('en', KeyboardLayout.defaultEnglish());
    }
    if (!languages.contains('ar')) {
      await insertOrUpdateLayout('ar', KeyboardLayout.defaultArabic());
    }
  }

  // الحصول على أو إنشاء تخطيط
  Future<KeyboardLayout> getOrCreateLayout(String lang) async {
    var layout = await getLayout(lang);
    if (layout != null) return layout;

    layout = lang == 'ar' 
        ? KeyboardLayout.defaultArabic() 
        : KeyboardLayout.defaultEnglish();
    
    await insertOrUpdateLayout(lang, layout);
    return layout;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
