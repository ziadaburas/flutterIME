
import 'dart:convert';
import 'keyboard_row.dart';

class KeyboardLayout {
  String lang;
  Map<String, KeyboardRow> rows;

  KeyboardLayout({
    required this.lang,
    required this.rows,
  });

  factory KeyboardLayout.fromJson(String lang, String jsonString) {
    final json = jsonDecode(jsonString);
    final Map<String, KeyboardRow> rows = {};
    
    json.forEach((key, value) {
      rows[key] = KeyboardRow.fromJson(value);
    });
    
    return KeyboardLayout(
      lang: lang,
      rows: rows,
    );
  }

  String toJsonString() {
    final Map<String, dynamic> json = {};
    rows.forEach((key, row) {
      json[key] = row.toJson();
    });
    return jsonEncode(json);
  }

  KeyboardLayout copy() {
    final Map<String, KeyboardRow> copiedRows = {};
    rows.forEach((key, row) {
      copiedRows[key] = row.copy();
    });
    return KeyboardLayout(
      lang: lang,
      rows: copiedRows,
    );
  }

  List<String> get rowKeys {
    final keys = rows.keys.toList();
    keys.sort();
    return keys;
  }
}
