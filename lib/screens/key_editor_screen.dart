import 'package:flutter/material.dart';
import '../models/keyboard_key.dart';

class KeyEditorScreen extends StatefulWidget {
  final KeyboardKey k;

  const KeyEditorScreen({
    super.key,
    required this.k,
  });

  @override
  State<KeyEditorScreen> createState() => _KeyEditorScreenState();
}

class _KeyEditorScreenState extends State<KeyEditorScreen> {
  late TextEditingController _typeController;
  late TextEditingController _weightController;
  late TextEditingController _textController;
  late TextEditingController _hintController;
  late TextEditingController _clickController;
  late TextEditingController _longPressController;
  late TextEditingController _textToSendController;
  late TextEditingController _codeToSendClickController;
  late TextEditingController _codeToSendLongPressController;

  final List<String> keyTypes = [
    'All',
    'space',
    'delete',
    'shift',
    'capslock',
    'ctrl',
    'alt',
    'symbols',
    'emoji',
    'clip',
  ];

  final List<String> clickActions = [
    'sendText',
    'sendCode',
    'showPopup',
    'loop',
  ];

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _typeController = TextEditingController(text: widget.k.type);
    _weightController = TextEditingController(text: widget.k.weight.toString());
    _textController = TextEditingController(text: widget.k.text);
    _hintController = TextEditingController(text: widget.k.hint);
    _clickController = TextEditingController(text: widget.k.click ?? '');
    _longPressController = TextEditingController(text: widget.k.longPress ?? '');
    _textToSendController = TextEditingController(text: widget.k.textToSend ?? '');
    _codeToSendClickController = TextEditingController(
      text: widget.k.codeToSendClick?.toString() ?? '',
    );
    _codeToSendLongPressController = TextEditingController(
      text: widget.k.codeToSendLongPress?.toString() ?? '',
    );
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
    super.dispose();
  }

  KeyboardKey _createUpdatedKey() {
    return KeyboardKey(
      type: _typeController.text.trim(),
      weight: double.tryParse(_weightController.text) ?? 1.0,
      text: _textController.text,
      hint: _hintController.text,
      click: _clickController.text.trim().isEmpty ? null : _clickController.text.trim(),
      longPress: _longPressController.text.trim().isEmpty ? null : _longPressController.text.trim(),
      textToSend: _textToSendController.text.trim().isEmpty ? null : _textToSendController.text.trim(),
      codeToSendClick: _codeToSendClickController.text.trim().isEmpty
          ? null
          : int.tryParse(_codeToSendClickController.text.trim()),
      codeToSendLongPress: _codeToSendLongPressController.text.trim().isEmpty
          ? null
          : int.tryParse(_codeToSendLongPressController.text.trim()),
    );
  }

  void _resetToDefault() {
    setState(() {
      _typeController.text = widget.k.type;
      _weightController.text = widget.k.weight.toString();
      _textController.text = widget.k.text;
      _hintController.text = widget.k.hint;
      _clickController.text = widget.k.click ?? '';
      _longPressController.text = widget.k.longPress ?? '';
      _textToSendController.text = widget.k.textToSend ?? '';
      _codeToSendClickController.text = widget.k.codeToSendClick?.toString() ?? '';
      _codeToSendLongPressController.text = widget.k.codeToSendLongPress?.toString() ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل المفتاح'),
        backgroundColor: Colors.purple.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: _resetToDefault,
            tooltip: 'استعادة القيم الأصلية',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => Navigator.pop(context, _createUpdatedKey()),
            tooltip: 'حفظ',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // معاينة المفتاح
            Card(
              color: Colors.grey.shade100,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'معاينة المفتاح',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: _getKeyColor(_typeController.text),
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            _textController.text.isNotEmpty
                                ? _textController.text
                                : _typeController.text,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // الخصائص الأساسية
            const Text(
              'الخصائص الأساسية',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            DropdownButtonFormField<String>(
              value: keyTypes.contains(_typeController.text) ? _typeController.text : 'All',
              decoration: const InputDecoration(
                labelText: 'نوع المفتاح',
                border: OutlineInputBorder(),
              ),
              items: keyTypes.map((type) => DropdownMenuItem(
                value: type,
                child: Text(type),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _typeController.text = value!;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(
                      labelText: 'العرض (Weight)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      labelText: 'نص المفتاح',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _hintController,
              decoration: const InputDecoration(
                labelText: 'النص المساعد (Hint)',
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // إعدادات الإجراءات
            const Text(
              'إعدادات الإجراءات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            DropdownButtonFormField<String>(
              value: clickActions.contains(_clickController.text) ? _clickController.text : null,
              decoration: const InputDecoration(
                labelText: 'إجراء النقر',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String>(value: null, child: Text('بدون إجراء')),
                ...clickActions.map((action) => DropdownMenuItem(
                  value: action,
                  child: Text(action),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _clickController.text = value ?? '';
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              value: clickActions.contains(_longPressController.text) ? _longPressController.text : null,
              decoration: const InputDecoration(
                labelText: 'إجراء الضغط المطول',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String>(value: null, child: Text('بدون إجراء')),
                ...clickActions.map((action) => DropdownMenuItem(
                  value: action,
                  child: Text(action),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _longPressController.text = value ?? '';
                });
              },
            ),
            
            const SizedBox(height: 24),
            
            // إعدادات الإرسال
            const Text(
              'إعدادات الإرسال',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            TextFormField(
              controller: _textToSendController,
              decoration: const InputDecoration(
                labelText: 'النص المُرسل',
                border: OutlineInputBorder(),
                hintText: 'النص الذي سيُرسل عند النقر',
              ),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _codeToSendClickController,
                    decoration: const InputDecoration(
                      labelText: 'كود النقر',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _codeToSendLongPressController,
                    decoration: const InputDecoration(
                      labelText: 'كود الضغط المطول',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // أزرار الإجراءات
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _resetToDefault,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'استعادة القيم الأصلية',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, _createUpdatedKey()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'حفظ التغييرات',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'إلغاء',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getKeyColor(String type) {
    switch (type.toLowerCase()) {
      case 'space':
        return Colors.blue.shade100;
      case 'delete':
        return Colors.red.shade100;
      case 'shift':
      case 'capslock':
        return Colors.orange.shade100;
      case 'ctrl':
      case 'alt':
        return Colors.purple.shade100;
      case 'symbols':
      case 'emoji':
        return Colors.green.shade100;
      default:
        return Colors.grey.shade200;
    }
  }
}