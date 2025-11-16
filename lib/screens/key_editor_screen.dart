import 'package:flutter/material.dart';
import '../models/keyboard_key.dart';

class KeyEditorScreen extends StatefulWidget {
  final int keyIndex;
  final KeyboardKey k;
  final bool isNewKey;

  const KeyEditorScreen({
    super.key,
    required this.keyIndex,
    required this.k,
    this.isNewKey = false,
  });

  @override
  State<KeyEditorScreen> createState() => _KeyEditorScreenState();
}

class _KeyEditorScreenState extends State<KeyEditorScreen> {
  late KeyboardKey _key;
  bool _hasChanges = false;

  // Controllers للحقول
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _hintController = TextEditingController();
  final TextEditingController _clickController = TextEditingController();
  final TextEditingController _longPressController = TextEditingController();
  final TextEditingController _textToSendController = TextEditingController();
  final TextEditingController _codeToSendClickController = TextEditingController();
  final TextEditingController _codeToSendLongPressController = TextEditingController();
  final TextEditingController _textToSendLongPressController = TextEditingController();

  // --- [ بداية الإضافة ] ---
  final TextEditingController _leftScrollController = TextEditingController();
  final TextEditingController _rightScrollController = TextEditingController();
  final TextEditingController _textToSendLeftScrollController = TextEditingController();
  final TextEditingController _textToSendRightScrollController = TextEditingController();
  final TextEditingController _codeToSendLeftScrollController = TextEditingController();
  final TextEditingController _codeToSendRightScrollController = TextEditingController();
  // --- [ نهاية الإضافة ] ---

  // قوائم الخيارات المحددة مسبقًا
  final List<String> _keyTypes = [
    'All', 'delete', 'space', 'shift', 'capslock',
    'ctrl', 'alt', 'symbols', 'emoji', 'clip'
  ];
  
  final List<String> _actionTypes = [
    'sendText', 'sendCode', 'showPopup', 'loop','sendSpecial','switchLang', ''
  ];

  @override
  void initState() {
    super.initState();
    _key = widget.k.copy();
    _initializeControllers();
  }

  void _initializeControllers() {
    _typeController.text = _key.type;
    _weightController.text = _key.weight.toString();
    _textController.text = _key.text;
    _hintController.text = _key.hint;
    _clickController.text = _key.click ?? '';
    _longPressController.text = _key.longPress ?? '';
    _textToSendController.text = _key.textToSend ?? '';
    _codeToSendClickController.text = _key.codeToSendClick?.toString() ?? '';
    _codeToSendLongPressController.text = _key.codeToSendLongPress?.toString() ?? '';
    _textToSendLongPressController.text = _key.textToSendLongPress?.toString() ?? '';

    // --- [ بداية الإضافة ] ---
    _leftScrollController.text = _key.leftScroll ?? '';
    _rightScrollController.text = _key.rightScroll ?? '';
    _textToSendLeftScrollController.text = _key.textToSendLeftScroll ?? '';
    _textToSendRightScrollController.text = _key.textToSendRightScroll ?? '';
    _codeToSendLeftScrollController.text = _key.codeToSendLeftScroll?.toString() ?? '';
    _codeToSendRightScrollController.text = _key.codeToSendRightScroll?.toString() ?? '';
    // --- [ نهاية الإضافة ] ---
  }

  void _updateKey() {
    setState(() {
      _key.type = _typeController.text;
      _key.weight = double.tryParse(_weightController.text) ?? 1.0;
      _key.text = _textController.text;
      _key.hint = _hintController.text;
      
      _key.click = _clickController.text.isEmpty ? null : _clickController.text;
      _key.longPress = _longPressController.text.isEmpty ? null : _longPressController.text;
      _key.textToSend = _textToSendController.text.isEmpty ? null : _textToSendController.text;
      _key.textToSendLongPress = _textToSendLongPressController.text.isEmpty ? null : _textToSendLongPressController.text;
      
      final clickCode = int.tryParse(_codeToSendClickController.text);
      _key.codeToSendClick = clickCode == 0 ? null : clickCode;
      
      final longPressCode = int.tryParse(_codeToSendLongPressController.text);
      _key.codeToSendLongPress = longPressCode == 0 ? null : longPressCode;
      
      // --- [ بداية الإضافة ] ---
      _key.leftScroll = _leftScrollController.text.isEmpty ? null : _leftScrollController.text;
      _key.rightScroll = _rightScrollController.text.isEmpty ? null : _rightScrollController.text;
      _key.textToSendLeftScroll = _textToSendLeftScrollController.text.isEmpty ? null : _textToSendLeftScrollController.text;
      _key.textToSendRightScroll = _textToSendRightScrollController.text.isEmpty ? null : _textToSendRightScrollController.text;

      final leftScrollCode = int.tryParse(_codeToSendLeftScrollController.text);
      _key.codeToSendLeftScroll = leftScrollCode == 0 ? null : leftScrollCode;

      final rightScrollCode = int.tryParse(_codeToSendRightScrollController.text);
      _key.codeToSendRightScroll = rightScrollCode == 0 ? null : rightScrollCode;
      // --- [ نهاية الإضافة ] ---
      
      _hasChanges = true;
    });
  }

  Future<void> _resetToBasicKey() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعادة تعيين الزر'),
        content: const Text('هل تريد إعادة تعيين هذا الزر إلى الإعدادات الأساسية؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('إعادة تعيين'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _key = KeyboardKey(
          type: 'All',
          weight: 1.0,
          text: 'أ',
          hint: '',
          click: 'sendText',
          longPress: '',
          textToSend: 'أ',
          // سيتم تعيين المتغيرات الجديدة إلى null افتراضيًا
        );
        _initializeControllers();
        _hasChanges = true;
      });
    }
  }

  Widget _buildDropdownField(
    String label,
    TextEditingController controller,
    List<String> options,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: options.contains(controller.text) ? controller.text : null,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: options.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value.isEmpty ? 'فارغ' : value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            controller.text = newValue ?? '';
            _updateKey();
          },
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: hint,
          ),
          onChanged: (_) => _updateKey(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_hasChanges || widget.isNewKey) {
          Navigator.pop(context, _key);
        } else {
          Navigator.pop(context);
        }
        return false;
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.isNewKey ? 'إضافة زر جديد' : 'تحرير الزر ${widget.keyIndex + 1}'),
            backgroundColor: Colors.purple.shade700,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                onPressed: _resetToBasicKey,
                icon: const Icon(Icons.restore),
                tooltip: 'إعادة تعيين',
              ),
              IconButton(
                onPressed: () => Navigator.pop(context, _key),
                icon: const Icon(Icons.save),
                tooltip: 'حفظ',
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // معاينة الزر
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'معاينة الزر',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: 60,
                        height: _key.type == 'space' ? 40 : 50,
                        decoration: BoxDecoration(
                          color: _getKeyTypeColor(_key.type),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _key.text.isEmpty ? '؟' : _key.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      if (_key.hint.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'التلميح: ${_key.hint}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // الحقول الأساسية
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'الإعدادات الأساسية',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        _buildDropdownField('نوع الزر', _typeController, _keyTypes),
                        const SizedBox(height: 16),
                        
                        _buildTextField(
                          'الوزن (العرض النسبي)',
                          _weightController,
                          keyboardType: TextInputType.number,
                          hint: '1.0',
                        ),
                        const SizedBox(height: 16),
                        
                        _buildTextField(
                          'النص المعروض',
                          _textController,
                          hint: 'النص الذي يظهر على الزر',
                        ),
                        
                        const SizedBox(height: 16),
                        
                        _buildTextField(
                          'التلميح',
                          _hintController,
                          hint: 'نص التلميح (اختياري)',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // إعدادات الإجراءات
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'إعدادات الإجراءات',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        _buildDropdownField('إجراء النقر', _clickController, _actionTypes),
                        const SizedBox(height: 16),
                        
                        _buildDropdownField('إجراء الضغط المطول', _longPressController, _actionTypes),
                        const SizedBox(height: 16),
                        
                        _buildTextField(
                          'النص المرسل',
                          _textToSendController,
                          hint: 'النص الذي يتم إرساله عند النقر',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // إعدادات الرموز
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'إعدادات رموز المفاتيح',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'هذه الرموز تُستخدم لإرسال مفاتيح خاصة (مثل Enter = 66, Backspace = 67)',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        _buildTextField(
                          'رمز النقر',
                          _codeToSendClickController,
                          keyboardType: TextInputType.number,
                          hint: 'رمز المفتاح للنقر (اختياري)',
                        ),
                        const SizedBox(height: 16),
                        
                        _buildTextField(
                          'رمز الضغط المطول',
                          _codeToSendLongPressController,
                          keyboardType: TextInputType.number,
                          hint: 'رمز المفتاح للضغط المطول (اختياري)',
                        ),
                        const SizedBox(height: 16),
                        
                        _buildTextField(
                          'رمز الضغط المطول',
                          _textToSendLongPressController,
                          keyboardType: TextInputType.text,
                          hint: 'نص المفتاح للضغط المطول (اختياري)',
                        ),

                      ],
                    ),
                  ),
                ),

                // --- [ بداية الإضافة ] ---
                const SizedBox(height: 16),

                // إعدادات التمرير
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'إعدادات التمرير (Scroll)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        _buildDropdownField('إجراء التمرير لليسار', _leftScrollController, _actionTypes),
                        const SizedBox(height: 16),
                        
                        _buildDropdownField('إجراء التمرير لليمين', _rightScrollController, _actionTypes),
                        const SizedBox(height: 16),

                        _buildTextField(
                          'النص المرسل (تمرير يسار)',
                          _textToSendLeftScrollController,
                          hint: 'النص عند التمرير لليسار',
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          'النص المرسل (تمرير يمين)',
                          _textToSendRightScrollController,
                          hint: 'النص عند التمرير لليمين',
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          'رمز التمرير (يسار)',
                          _codeToSendLeftScrollController,
                          keyboardType: TextInputType.number,
                          hint: 'رمز المفتاح للتمرير يسار (اختياري)',
                        ),
                        const SizedBox(height: 16),
                        
                        _buildTextField(
                          'رمز التمرير (يمين)',
                          _codeToSendRightScrollController,
                          keyboardType: TextInputType.number,
                          hint: 'رمز المفتاح للتمرير يمين (اختياري)',
                        ),
                      ],
                    ),
                  ),
                ),
                // --- [ نهاية الإضافة ] ---

                const SizedBox(height: 24),

                // معلومات إضافية
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'معلومات مفيدة:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• رموز المفاتيح الشائعة: Enter=66, Backspace=67, Space=62\n'
                        '• أنواع الأزرار: All (عادي), space (مسطرة), delete (حذف)\n'
                        '• الوزن يحدد العرض النسبي للزر (1.0 = عرض عادي)',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getKeyTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'all':
        return Colors.blue;
      case 'delete':
        return Colors.red;
      case 'space':
        return Colors.green;
      case 'shift':
      case 'capslock':
        return Colors.orange;
      case 'ctrl':
      case 'alt':
        return Colors.purple;
      case 'symbols':
        return Colors.teal;
      case 'emoji':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _typeController.dispose();
    _weightController.dispose();
    _textController.dispose();
    _hintController.dispose();
    _clickController.dispose();
    _longPressController.dispose();
    _textToSendController.dispose();
    _codeToSendClickController.dispose();
    _codeToSendLongPressController.dispose();
    _textToSendLongPressController.dispose();

    // --- [ بداية الإضافة ] ---
    _leftScrollController.dispose();
    _rightScrollController.dispose();
    _textToSendLeftScrollController.dispose();
    _textToSendRightScrollController.dispose();
    _codeToSendLeftScrollController.dispose();
    _codeToSendRightScrollController.dispose();
    // --- [ نهاية الإضافة ] ---
    
    super.dispose();
  }
}