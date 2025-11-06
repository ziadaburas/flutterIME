import 'dart:convert';

class KeyboardLayout {
  Map<String, dynamic> navRow;
  Map<String, String> numRow;
  Map<String, String> row1;
  Map<String, String> row2;
  Map<String, String> row3;
  Map<String, String> bottomRow;

  KeyboardLayout({
    required this.navRow,
    required this.numRow,
    required this.row1,
    required this.row2,
    required this.row3,
    required this.bottomRow,
  });

  factory KeyboardLayout.fromJson(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    
    return KeyboardLayout(
      navRow: json['navRow'] as Map<String, dynamic>,
      numRow: Map<String, String>.from(json['numRow'] as Map),
      row1: Map<String, String>.from(json['row1'] as Map),
      row2: Map<String, String>.from(json['row2'] as Map),
      row3: Map<String, String>.from(json['row3'] as Map),
      bottomRow: Map<String, String>.from(json['bottomRow'] as Map),
    );
  }

  String toJson() {
    final map = {
      'navRow': navRow,
      'numRow': numRow,
      'row1': row1,
      'row2': row2,
      'row3': row3,
      'bottomRow': bottomRow,
    };
    return jsonEncode(map);
  }

  Map<String, dynamic> getRow(String rowName) {
    switch (rowName) {
      case 'navRow':
        return navRow;
      case 'numRow':
        return numRow;
      case 'row1':
        return row1;
      case 'row2':
        return row2;
      case 'row3':
        return row3;
      case 'bottomRow':
        return bottomRow;
      default:
        return {};
    }
  }

  void updateRow(String rowName, Map<String, dynamic> newRowData) {
    switch (rowName) {
      case 'navRow':
        navRow = newRowData;
        break;
      case 'numRow':
        numRow = Map<String, String>.from(newRowData);
        break;
      case 'row1':
        row1 = Map<String, String>.from(newRowData);
        break;
      case 'row2':
        row2 = Map<String, String>.from(newRowData);
        break;
      case 'row3':
        row3 = Map<String, String>.from(newRowData);
        break;
      case 'bottomRow':
        bottomRow = Map<String, String>.from(newRowData);
        break;
    }
  }
}