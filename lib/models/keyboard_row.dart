import 'keyboard_key.dart';

class KeyboardRow {
  final double height;
  final List<KeyboardKey> keys;

  KeyboardRow({
    required this.height,
    required this.keys,
  });

  factory KeyboardRow.fromJson(Map<String, dynamic> json) {
    return KeyboardRow(
      height: (json['height'] ?? 55.0).toDouble(),
      keys: (json['keys'] as List)
          .map((keyJson) => KeyboardKey.fromJson(keyJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'height': height,
      'keys': keys.map((key) => key.toJson()).toList(),
    };
  }

  KeyboardRow copyWith({
    double? height,
    List<KeyboardKey>? keys,
  }) {
    return KeyboardRow(
      height: height ?? this.height,
      keys: keys ?? this.keys,
    );
  }
}