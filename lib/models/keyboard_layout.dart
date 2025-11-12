import 'dart:convert';
import 'keyboard_row.dart';

class KeyboardLayout {
  final String lang;
  final Map<String, KeyboardRow> rows;

  KeyboardLayout({
    required this.lang,
    required this.rows,
  });

  factory KeyboardLayout.fromJson(String lang, String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    Map<String, KeyboardRow> rows = {};
    
    json.forEach((key, value) {
      rows[key] = KeyboardRow.fromJson(value);
    });

    return KeyboardLayout(
      lang: lang,
      rows: rows,
    );
  }

  String toJsonString() {
    Map<String, dynamic> json = {};
    rows.forEach((key, row) {
      json[key] = row.toJson();
    });
    return jsonEncode(json);
  }

  KeyboardLayout copyWith({
    String? lang,
    Map<String, KeyboardRow>? rows,
  }) {
    return KeyboardLayout(
      lang: lang ?? this.lang,
      rows: rows ?? this.rows,
    );
  }

  // إضافة صف جديد
  void addRow(String rowKey, KeyboardRow row) {
    rows[rowKey] = row;
  }

  // حذف صف
  void removeRow(String rowKey) {
    rows.remove(rowKey);
  }

  // الحصول على قائمة مرتبة من الصفوف
  List<MapEntry<String, KeyboardRow>> getSortedRows() {
    var sortedKeys = rows.keys.toList()..sort();
    return sortedKeys.map((key) => MapEntry(key, rows[key]!)).toList();
  }
}