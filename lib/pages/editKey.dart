import 'package:flutter/material.dart';

class EditKeyScreen extends StatefulWidget {
  final String currentKey;
  final dynamic currentValue;
  final String rowKey;

  const EditKeyScreen({
    super.key,
    required this.currentKey,
    required this.currentValue,
    required this.rowKey,
  });

  @override
  State<EditKeyScreen> createState() => _EditKeyScreenState();
}

class _EditKeyScreenState extends State<EditKeyScreen> {
  late TextEditingController _keyController;
  late TextEditingController _valueController;
  late TextEditingController _hintController;
  late TextEditingController _funController;
  
  bool _isNavRow = false;
  bool _isComplexValue = false;

  @override
  void initState() {
    super.initState();
    _isNavRow = widget.rowKey == 'navRow';
    
    _keyController = TextEditingController(text: widget.currentKey);
    
    if (_isNavRow && widget.currentValue is Map) {
      _isComplexValue = true;
      Map<String, dynamic> valueMap = widget.currentValue;
      _valueController = TextEditingController();
      _hintController = TextEditingController(text: valueMap['hint'] ?? '');
      _funController = TextEditingController(text: valueMap['fun'] ?? '');
    } else {
      _isComplexValue = false;
      _valueController = TextEditingController(
        text: widget.currentValue?.toString() ?? '',
      );
      _hintController = TextEditingController();
      _funController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
    _hintController.dispose();
    _funController.dispose();
    super.dispose();
  }

  void _saveKey() {
    String key = _keyController.text.trim();
    
    if (key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء إدخال اسم المفتاح'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    dynamic value;
    if (_isComplexValue) {
      value = {
        'hint': _hintController.text.trim(),
        'fun': _funController.text.trim(),
      };
    } else {
      value = _valueController.text.trim();
    }

    Navigator.pop(context, {
      'key': key,
      'value': value,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.currentKey.isEmpty ? 'إضافة مفتاح جديد' : 'تعديل المفتاح'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveKey,
            tooltip: 'حفظ',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 20),
            _buildKeyField(),
            const SizedBox(height: 16),
            if (_isNavRow) ...[
              _buildSwitchCard(),
              const SizedBox(height: 16),
            ],
            if (_isComplexValue)
              ..._buildComplexFields()
            else
              _buildSimpleValueField(),
            const SizedBox(height: 24),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.blue.shade50,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _isNavRow
                    ? 'صف التنقل يدعم القيم البسيطة والمعقدة (hint, fun)'
                    : 'يمكنك تعديل اسم المفتاح والقيمة المرتبطة به',
                style: TextStyle(
                  color: Colors.blue.shade900,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'اسم المفتاح',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _keyController,
          decoration: InputDecoration(
            hintText: 'مثال: q, a, 1, Left',
            prefixIcon: const Icon(Icons.vpn_key),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchCard() {
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: SwitchListTile(
        title: const Text(
          'قيمة معقدة (Complex Value)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('تفعيل لاستخدام hint و fun'),
        value: _isComplexValue,
        onChanged: (value) {
          setState(() {
            _isComplexValue = value;
          });
        },
      ),
    );
  }

  Widget _buildSimpleValueField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'القيمة',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _valueController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'مثال: ( ) (), ! !=, ض',
            prefixIcon: const Icon(Icons.text_fields),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildComplexFields() {
    return [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hint (تلميح)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _hintController,
            decoration: InputDecoration(
              hintText: 'مثال: Home, End',
              prefixIcon: const Icon(Icons.lightbulb_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Function (الوظيفة)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _funController,
            decoration: InputDecoration(
              hintText: 'مثال: loop, sendHome, hold',
              prefixIcon: const Icon(Icons.functions),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
        ],
      ),
    ];
  }

  Widget _buildSaveButton() {
    return ElevatedButton.icon(
      onPressed: _saveKey,
      icon: const Icon(Icons.save),
      label: const Text(
        'حفظ التغييرات',
        style: TextStyle(fontSize: 16),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
