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
  String? textToSendLongPress;

  // --- [ بداية الإضافة ] ---
  String? leftScroll;
  String? rightScroll;
  String? textToSendLeftScroll;
  String? textToSendRightScroll;
  int? codeToSendLeftScroll;
  int? codeToSendRightScroll;
  // --- [ نهاية الإضافة ] ---

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
    this.textToSendLongPress,
    // --- [ بداية الإضافة ] ---
    this.leftScroll,
    this.rightScroll,
    this.textToSendLeftScroll,
    this.textToSendRightScroll,
    this.codeToSendLeftScroll,
    this.codeToSendRightScroll,
    // --- [ نهاية الإضافة ] ---
  });

  factory KeyboardKey.fromJson(Map<String, dynamic> json) {
    return KeyboardKey(
      type: json['type'] ?? '',
      weight: (json['weight'] ?? 1.0).toDouble(),
      text: json['text'] ?? '',
      hint: json['hint'] ?? '',
      click: json['click'] ?? '',
      longPress: json['longPress'] ?? '',
      textToSend: json['textToSend'] ?? '',
      textToSendLongPress: json['textToSendLongPress'] ?? '',
      codeToSendClick: json['codeToSendClick'] ?? 0,
      codeToSendLongPress: json['codeToSendLongPress'] ?? 0,
      
      // --- [ بداية الإضافة ] ---
      leftScroll: json['leftScroll'] ?? '',
      rightScroll: json['rightScroll'] ?? '',
      textToSendLeftScroll: json['textToSendLeftScroll'] ?? '',
      textToSendRightScroll: json['textToSendRightScroll'] ?? '',
      codeToSendLeftScroll: json['codeToSendLeftScroll'] ?? 0,
      codeToSendRightScroll: json['codeToSendRightScroll'] ?? 0,
      // --- [ نهاية الإضافة ] ---
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
    if (textToSendLongPress != null) json['textToSendLongPress'] = textToSendLongPress;

    // --- [ بداية الإضافة ] ---
    if (leftScroll != null) json['leftScroll'] = leftScroll;
    if (rightScroll != null) json['rightScroll'] = rightScroll;
    if (textToSendLeftScroll != null) json['textToSendLeftScroll'] = textToSendLeftScroll;
    if (textToSendRightScroll != null) json['textToSendRightScroll'] = textToSendRightScroll;
    if (codeToSendLeftScroll != null) json['codeToSendLeftScroll'] = codeToSendLeftScroll;
    if (codeToSendRightScroll != null) json['codeToSendRightScroll'] = codeToSendRightScroll;
    // --- [ نهاية الإضافة ] ---
    
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
      textToSendLongPress: textToSendLongPress,

      // --- [ بداية الإضافة ] ---
      leftScroll: leftScroll,
      rightScroll: rightScroll,
      textToSendLeftScroll: textToSendLeftScroll,
      textToSendRightScroll: textToSendRightScroll,
      codeToSendLeftScroll: codeToSendLeftScroll,
      codeToSendRightScroll: codeToSendRightScroll,
      // --- [ نهاية الإضافة ] ---
    );
  }
}