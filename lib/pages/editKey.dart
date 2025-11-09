 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/layout.dart';

class KeyEditorDialog extends StatefulWidget {
  final KeyModel? key1;

  const KeyEditorDialog({Key? key, this.key1}) : super(key: key);

  @override
  State<KeyEditorDialog> createState() => _KeyEditorDialogState();
}

class _KeyEditorDialogState extends State<KeyEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  
  late String _type;
  late double _weight;
  late TextEditingController _textController;
  late TextEditingController _hintController;
  late TextEditingController _keyCodeController;
  late TextEditingController _clickController;
  late TextEditingController _longPressController;

  final List<String> _keyTypes = [
    'letter',
    'specialKey',
    'normal',
    'loopKey',
    'space',
    'delete',
    'emoji',
    'symbols',
    'clip',
  ];

  @override
  void initState() {
    super.initState();
    
    if (widget.key != null) {
      _type = widget.key1!.type;
      _weight = widget.key1!.weight;
      _textController = TextEditingController(text: widget.key1!.text);
      _hintController = TextEditingController(text: widget.key1!.hint);
      _keyCodeController = TextEditingController(
        text: widget.key1!.keyCode?.toString() ?? ''
      );
      _clickController = TextEditingController(text: widget.key1!.click ?? '');
      _longPressController = TextEditingController(text: widget.key1!.longPress ?? '');
    } else {
      _type = 'letter';
      _weight = 1.0;
      _textController = TextEditingController();
      _hintController = TextEditingController();
      _keyCodeController = TextEditingController();
      _clickController = TextEditingController();
      _longPressController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _hintController.dispose();
    _keyCodeController.dispose();
    _clickController.dispose();
    _longPressController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final newKey = KeyModel(
        type: _type,
        weight: _weight,
        text: _textController.text,
        hint: _hintController.text,
        keyCode: _keyCodeController.text.isEmpty 
            ? null 
            : int.tryParse(_keyCodeController.text),
        click: _clickController.text.isEmpty ? null : _clickController.text,
        longPress: _longPressController.text.isEmpty 
            ? null 
            : _longPressController.text,
      );
      
      Navigator.pop(context, newKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: Text(widget.key == null ? 'إضافة مفتاح جديد' : 'تعديل المفتاح'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // نوع المفتاح
                DropdownButtonFormField<String>(
                  value: _type,
                  decoration: const InputDecoration(
                    labelText: 'نوع المفتاح',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: _keyTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _getKeyColor(type),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(type),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _type = value!);
                  },
                ),
                
                const SizedBox(height: 16),
                
                // النص
                TextFormField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    labelText: 'النص',
                    hintText: 'النص الظاهر على المفتاح',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.text_fields),
                  ),
                  validator: (value) {
                    if (_type == 'letter' && (value == null || value.isEmpty)) {
                      return 'الرجاء إدخال النص';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // التلميح
                TextFormField(
                  controller: _hintController,
                  decoration: const InputDecoration(
                    labelText: 'التلميح (اختياري)',
                    hintText: 'النص عند الضغط المطول',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.comment),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // الوزن
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الوزن: ${_weight.toStringAsFixed(1)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Slider(
                      value: _weight,
                      min: 0.5,
                      max: 5.0,
                      divisions: 45,
                      label: _weight.toStringAsFixed(1),
                      onChanged: (value) {
                        setState(() => _weight = value);
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // حقول متقدمة
                ExpansionTile(
                  title: const Text('إعدادات متقدمة'),
                  initiallyExpanded: widget.key1?.keyCode != null ||
                      widget.key1?.click != null ||
                      widget.key1?.longPress != null,
                  children: [
                    const SizedBox(height: 8),
                    
                    // KeyCode
                    if (_type == 'specialKey')
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: TextFormField(
                          controller: _keyCodeController,
                          decoration: const InputDecoration(
                            labelText: 'KeyCode (للمفاتيح الخاصة)',
                            hintText: 'مثال: 113',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.code),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                    
                    // Click
                    if (_type == 'normal' || _type == 'loopKey')
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: TextFormField(
                          controller: _clickController,
                          decoration: const InputDecoration(
                            labelText: 'وظيفة النقر',
                            hintText: 'مثال: sendHome, loop',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.touch_app),
                          ),
                        ),
                      ),
                    
                    // LongPress
                    if (_type == 'normal')
                      TextFormField(
                        controller: _longPressController,
                        decoration: const InputDecoration(
                          labelText: 'وظيفة الضغط المطول',
                          hintText: 'مثال: sendEnd',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.ads_click),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // معاينة المفتاح
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'معاينة:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: _getKeyColor(_type),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            _textController.text.isEmpty 
                                ? '␣' 
                                : _textController.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: _save,
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  Color _getKeyColor(String type) {
    final colors = {
      'letter': Colors.blue,
      'specialKey': Colors.purple,
      'normal': Colors.teal,
      'loopKey': Colors.orange,
      'space': Colors.green,
      'delete': Colors.red,
      'emoji': Colors.pink,
      'symbols': Colors.indigo,
      'clip': Colors.brown,
    };
    return colors[type] ?? Colors.grey;
  }
}
