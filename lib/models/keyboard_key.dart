class KeyboardKey {
  String type;
  double weight;
  String text;
  String hint;
  String? click;
  String? longPress;
  String? textToSend;
  int? codeToSendClick;
  int? codeToSendLongPress;

  KeyboardKey({
    required this.type,
    required this.weight,
    required this.text,
    required this.hint,
    this.click,
    this.longPress,
    this.textToSend,
    this.codeToSendClick,
    this.codeToSendLongPress,
  });

  factory KeyboardKey.fromJson(Map<String, dynamic> json) {
    return KeyboardKey(
      type: json['type'] ?? '',
      weight: (json['weight'] ?? 1.0).toDouble(),
      text: json['text'] ?? '',
      hint: json['hint'] ?? '',
      click: json['click'],
      longPress: json['longPress'],
      textToSend: json['textToSend'],
      codeToSendClick: json['codeToSendClick'],
      codeToSendLongPress: json['codeToSendLongPress'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'type': type,
      'weight': weight,
      'text': text,
      'hint': hint,
    };
    
    if (click != null) json['click'] = click;
    if (longPress != null) json['longPress'] = longPress;
    if (textToSend != null) json['textToSend'] = textToSend;
    if (codeToSendClick != null) json['codeToSendClick'] = codeToSendClick;
    if (codeToSendLongPress != null) json['codeToSendLongPress'] = codeToSendLongPress;
    
    return json;
  }

  KeyboardKey copy() {
    return KeyboardKey(
      type: type,
      weight: weight,
      text: text,
      hint: hint,
      click: click,
      longPress: longPress,
      textToSend: textToSend,
      codeToSendClick: codeToSendClick,
      codeToSendLongPress: codeToSendLongPress,
    );
  }
}
