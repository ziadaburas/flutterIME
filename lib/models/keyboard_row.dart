import 'keyboard_key.dart';

class KeyboardRow {
  double height;
  List<KeyboardKey> keys;

  KeyboardRow({
    required this.height,
    required this.keys,
  });

  factory KeyboardRow.fromJson(Map<String, dynamic> json) {
    return KeyboardRow(
      height: (json['height'] ?? 55.0).toDouble(),
      keys: (json['keys'] as List?)
          ?.map((keyJson) => KeyboardKey.fromJson(keyJson))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'height': height,
      'keys': keys.map((key) => key.toJson()).toList(),
    };
  }

  KeyboardRow copy() {
    return KeyboardRow(
      height: height,
      keys: keys.map((key) => key.copy()).toList(),
    );
  }
}
