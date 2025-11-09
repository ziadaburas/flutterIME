
import 'dart:convert';

class KeyboardLayout {
  Map<String, KeyboardRow> rows;

  KeyboardLayout({required this.rows});

  factory KeyboardLayout.fromJson(Map<String, dynamic> json) {
    Map<String, KeyboardRow> rows = {};
    json.forEach((key, value) {
      if (key.startsWith('row') && value is Map) {
        rows[key] = KeyboardRow.fromJson(value as Map<String, dynamic>);
      }
    });
    return KeyboardLayout(rows: rows);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    rows.forEach((key, value) {
      json[key] = value.toJson();
    });
    return json;
  }

  // التخطيط الافتراضي الإنجليزي
  static KeyboardLayout defaultEnglish() {
    return KeyboardLayout.fromJson(jsonDecode('''
    {
      "row1": {
        "height": 45,
        "keys": [
          {"type": "loopKey", "weight": 1.0, "text": "←", "hint": "", "click": "loop"},
          {"type": "normal", "weight": 1.0, "text": "↑", "hint": "Home", "click": "sendHome", "longPress": ""},
          {"type": "normal", "weight": 1.0, "text": "⇥", "hint": "", "click": "sendKeyPress", "longPress": ""},
          {"type": "specialKey", "weight": 1.0, "text": "Ctrl", "hint": "", "keyCode": 113},
          {"type": "specialKey", "weight": 1.0, "text": "Alt", "hint": "", "keyCode": 57},
          {"type": "specialKey", "weight": 1.0, "text": "Shift", "hint": "", "keyCode": 59},
          {"type": "normal", "weight": 1.0, "text": "↓", "hint": "End", "click": "sendEnd", "longPress": ""},
          {"type": "loopKey", "weight": 1.0, "text": "→", "hint": "", "click": "loop"}
        ]
      },
      "row2": {
        "height": 55,
        "keys": [
          {"type": "letter", "weight": 1.0, "text": "1", "hint": "!"},
          {"type": "letter", "weight": 1.0, "text": "2", "hint": "@"},
          {"type": "letter", "weight": 1.0, "text": "3", "hint": "#"},
          {"type": "letter", "weight": 1.0, "text": "4", "hint": "\$"},
          {"type": "letter", "weight": 1.0, "text": "5", "hint": "%"},
          {"type": "letter", "weight": 1.0, "text": "6", "hint": "^"},
          {"type": "letter", "weight": 1.0, "text": "7", "hint": "&"},
          {"type": "letter", "weight": 1.0, "text": "8", "hint": "*"},
          {"type": "letter", "weight": 1.0, "text": "9", "hint": "("},
          {"type": "letter", "weight": 1.0, "text": "0", "hint": ")"}
        ]
      },
      "row3": {
        "height": 55,
        "keys": [
          {"type": "letter", "weight": 1.0, "text": "q", "hint": "( ) ()"},
          {"type": "letter", "weight": 1.0, "text": "w", "hint": "{ } {}"},
          {"type": "letter", "weight": 1.0, "text": "e", "hint": "[ ] []"},
          {"type": "letter", "weight": 1.0, "text": "r", "hint": "& &&"},
          {"type": "letter", "weight": 1.0, "text": "t", "hint": "| ||"},
          {"type": "letter", "weight": 1.0, "text": "y", "hint": "= == =>"},
          {"type": "letter", "weight": 1.0, "text": "u", "hint": "+ ++ +="},
          {"type": "letter", "weight": 1.0, "text": "i", "hint": "- ->"},
          {"type": "letter", "weight": 1.0, "text": "o", "hint": "\$"},
          {"type": "letter", "weight": 1.0, "text": "p", "hint": "#"}
        ]
      },
      "row4": {
        "height": 55,
        "keys": [
          {"type": "letter", "weight": 1.0, "text": "a", "hint": "@ • @gmail.com"},
          {"type": "letter", "weight": 1.0, "text": "s", "hint": "! !="},
          {"type": "letter", "weight": 1.0, "text": "d", "hint": "~"},
          {"type": "letter", "weight": 1.0, "text": "f", "hint": "?"},
          {"type": "letter", "weight": 1.0, "text": "g", "hint": "* **"},
          {"type": "letter", "weight": 1.0, "text": "h", "hint": "%"},
          {"type": "letter", "weight": 1.0, "text": "j", "hint": "_ __"},
          {"type": "letter", "weight": 1.0, "text": "k", "hint": ":"},
          {"type": "letter", "weight": 1.0, "text": "l", "hint": ";"}
        ]
      },
      "row5": {
        "height": 55,
        "keys": [
          {"type": "specialKey", "weight": 1.5, "text": "⇧", "hint": "", "keyCode": 115},
          {"type": "letter", "weight": 1.0, "text": "z", "hint": "' ''"},
          {"type": "letter", "weight": 1.0, "text": "x", "hint": "\\" \\\\""},
          {"type": "letter", "weight": 1.0, "text": "c", "hint": "`"},
          {"type": "letter", "weight": 1.0, "text": "v", "hint": "< <= <>"},
          {"type": "letter", "weight": 1.0, "text": "b", "hint": "> >= </>"},
          {"type": "letter", "weight": 1.0, "text": "n", "hint": "/ // /**/"},
          {"type": "letter", "weight": 1.0, "text": "m", "hint": "\\\\"},
          {"type": "delete", "weight": 1.5, "text": "⌫", "hint": ""}
        ]
      },
      "row6": {
        "height": 60,
        "keys": [
          {"type": "symbols", "weight": 1.5, "text": "123", "hint": ""},
          {"type": "emoji", "weight": 1.0, "text": "😀", "hint": ""},
          {"type": "letter", "weight": 1.0, "text": ",", "hint": ""},
          {"type": "space", "weight": 3.0, "text": "Space", "hint": ""},
          {"type": "letter", "weight": 1.0, "text": ".", "hint": ""},
          {"type": "clip", "weight": 1.0, "text": "📋", "hint": ""},
          {"type": "normal", "weight": 1.0, "text": "⏎", "hint": "", "click": "sendKeyPress", "longPress": ""}
        ]
      }
    }
    '''));
  }

  // التخطيط الافتراضي العربي
  static KeyboardLayout defaultArabic() {
    return KeyboardLayout.fromJson(jsonDecode('''
    {
      "row1": {
        "height": 45,
        "keys": [
          {"type": "loopKey", "weight": 1.0, "text": "←", "hint": "", "click": "loop"},
          {"type": "normal", "weight": 1.0, "text": "↑", "hint": "Home", "click": "sendHome", "longPress": ""},
          {"type": "normal", "weight": 1.0, "text": "⇥", "hint": "", "click": "sendKeyPress", "longPress": ""},
          {"type": "specialKey", "weight": 1.0, "text": "Ctrl", "hint": "", "keyCode": 113},
          {"type": "specialKey", "weight": 1.0, "text": "Alt", "hint": "", "keyCode": 57},
          {"type": "specialKey", "weight": 1.0, "text": "Shift", "hint": "", "keyCode": 59},
          {"type": "normal", "weight": 1.0, "text": "↓", "hint": "End", "click": "sendEnd", "longPress": ""},
          {"type": "loopKey", "weight": 1.0, "text": "→", "hint": "", "click": "loop"}
        ]
      },
      "row2": {
        "height": 55,
        "keys": [
          {"type": "letter", "weight": 1.0, "text": "1", "hint": "!"},
          {"type": "letter", "weight": 1.0, "text": "2", "hint": "\\""},
          {"type": "letter", "weight": 1.0, "text": "3", "hint": "·"},
          {"type": "letter", "weight": 1.0, "text": "4", "hint": ":"},
          {"type": "letter", "weight": 1.0, "text": "5", "hint": "؟"},
          {"type": "letter", "weight": 1.0, "text": "6", "hint": "؛"},
          {"type": "letter", "weight": 1.0, "text": "7", "hint": "-"},
          {"type": "letter", "weight": 1.0, "text": "8", "hint": "_"},
          {"type": "letter", "weight": 1.0, "text": "9", "hint": "("},
          {"type": "letter", "weight": 1.0, "text": "0", "hint": ")"}
        ]
      },
      "row3": {
        "height": 55,
        "keys": [
          {"type": "letter", "weight": 1.0, "text": "ض", "hint": "!"},
          {"type": "letter", "weight": 1.0, "text": "ص", "hint": "!"},
          {"type": "letter", "weight": 1.0, "text": "ق", "hint": "!"},
          {"type": "letter", "weight": 1.0, "text": "ف", "hint": "!"},
          {"type": "letter", "weight": 1.0, "text": "غ", "hint": "!"},
          {"type": "letter", "weight": 1.0, "text": "ع", "hint": "!"},
          {"type": "letter", "weight": 1.0, "text": "ه", "hint": "!"},
          {"type": "letter", "weight": 1.0, "text": "خ", "hint": "!"},
          {"type": "letter", "weight": 1.0, "text": "ح", "hint": "!"},
          {"type": "letter", "weight": 1.0, "text": "ج", "hint": "!"}
        ]
      },
      "row4": {
        "height": 55,
        "keys": [
          {"type": "letter", "weight": 1.0, "text": "ش", "hint": "!"},
          {"type": "letter", "weight": 1.0, "text": "س", "hint": "!"},
          {"type": "letter", "weight": 1.0, "text": "ي", "hint": "ى ئ"},
          {"type": "letter", "weight": 1.0, "text": "ب", "hint": "!"},
          {"type": "letter", "weight": 1.0, "text": "ل", "hint": "!"},
          {"type": "letter", "weight": 1.0, "text": "ا", "hint": "ء أ إ آ"},
          {"type": "letter", "weight": 1.0, "text": "ت", "hint": "ـ"},
          {"type": "letter", "weight": 1.0, "text": "ن", "hint": "!"},
          {"type": "letter", "weight": 1.0, "text": "م", "hint": "!"},
          {"type": "letter", "weight": 1.0, "text": "ك", "hint": "؛"}
        ]
      },
      "row5": {
        "height": 55,
        "keys": [
          {"type": "letter", "weight": 1.0, "text": "ظ", "hint": "َ ِ ُ ً ٍ ٌ ّ ْ"},
          {"type": "letter", "weight": 1.0, "text": "ط", "hint": "!"},
          {"type": "letter", "weight": 1.0, "text": "ذ", "hint": "!"},
          {"type": "letter", "weight": 1.0, "text": "د", "hint": "!"},
          {"type": "letter", "weight": 1.0, "text": "ز", "hint": "!"},
          {"type": "letter", "weight": 1.0, "text": "ر", "hint": "!"},
          {"type": "letter", "weight": 1.0, "text": "و", "hint": "ؤ"},
          {"type": "letter", "weight": 1.0, "text": "ة", "hint": "!"},
          {"type": "letter", "weight": 1.0, "text": "ث", "hint": "!"},
          {"type": "delete", "weight": 1.5, "text": "⌫", "hint": ""}
        ]
      },
      "row6": {
        "height": 60,
        "keys": [
          {"type": "symbols", "weight": 1.5, "text": "123", "hint": ""},
          {"type": "emoji", "weight": 1.0, "text": "😀", "hint": ""},
          {"type": "letter", "weight": 1.0, "text": "،", "hint": ""},
          {"type": "space", "weight": 3.0, "text": "Space", "hint": ""},
          {"type": "letter", "weight": 1.0, "text": ".", "hint": ""},
          {"type": "clip", "weight": 1.0, "text": "📋", "hint": ""},
          {"type": "normal", "weight": 1.0, "text": "⏎", "hint": "", "click": "sendKeyPress", "longPress": ""}
        ]
      }
    }
    '''));
  }
}

class KeyboardRow {
  int height;
  List<KeyModel> keys;

  KeyboardRow({required this.height, required this.keys});

  factory KeyboardRow.fromJson(Map<String, dynamic> json) {
    return KeyboardRow(
      height: json['height'] ?? 55,
      keys: (json['keys'] as List)
          .map((k) => KeyModel.fromJson(k as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'height': height,
      'keys': keys.map((k) => k.toJson()).toList(),
    };
  }
}

class KeyModel {
  String type;
  double weight;
  String text;
  String hint;
  int? keyCode;
  String? click;
  String? longPress;

  KeyModel({
    required this.type,
    required this.weight,
    required this.text,
    required this.hint,
    this.keyCode,
    this.click,
    this.longPress,
  });

  factory KeyModel.fromJson(Map<String, dynamic> json) {
    return KeyModel(
      type: json['type'] ?? 'letter',
      weight: (json['weight'] ?? 1.0).toDouble(),
      text: json['text'] ?? '',
      hint: json['hint'] ?? '',
      keyCode: json['keyCode'],
      click: json['click'],
      longPress: json['longPress'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'type': type,
      'weight': weight,
      'text': text,
      'hint': hint,
    };
    
    if (keyCode != null) data['keyCode'] = keyCode;
    if (click != null && click!.isNotEmpty) data['click'] = click;
    if (longPress != null && longPress!.isNotEmpty) data['longPress'] = longPress;
    
    return data;
  }

  // نسخ المفتاح
  KeyModel copyWith({
    String? type,
    double? weight,
    String? text,
    String? hint,
    int? keyCode,
    String? click,
    String? longPress,
  }) {
    return KeyModel(
      type: type ?? this.type,
      weight: weight ?? this.weight,
      text: text ?? this.text,
      hint: hint ?? this.hint,
      keyCode: keyCode ?? this.keyCode,
      click: click ?? this.click,
      longPress: longPress ?? this.longPress,
    );
  }
}
