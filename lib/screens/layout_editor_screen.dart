import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/keyboard_layout.dart';
import '../models/keyboard_row.dart';
import '../models/keyboard_key.dart';
import 'key_editor_screen.dart';

class LayoutEditorScreen extends StatefulWidget {
  final String languageCode;

  const LayoutEditorScreen({
    super.key,
    required this.languageCode,
  });

  @override
  State<LayoutEditorScreen> createState() => _LayoutEditorScreenState();
}

class _LayoutEditorScreenState extends State<LayoutEditorScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  KeyboardLayout? layout;
  bool isLoading = true;
  bool hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadLayout();
  }

  Future<void> _loadLayout() async {
    setState(() => isLoading = true);
    try {
      final jsonString = await _dbHelper.getOrCreateLayout(widget.languageCode);
      setState(() {
        layout = KeyboardLayout.fromJson(widget.languageCode, jsonString);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorDialog('خطأ في تحميل التخطيط: $e');
    }
  }

  Future<void> _saveLayout() async {
    if (layout == null) return;

    try {
      await _dbHelper.insertOrUpdate(layout!.lang, layout!.toJsonString());
      setState(() => hasChanges = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ التخطيط بنجاح')),
      );
    } catch (e) {
      _showErrorDialog('خطأ في حفظ التخطيط: $e');
    }
  }

  Future<void> _resetToDefault() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('استعادة التخطيط الافتراضي'),
        content: const Text('هل تريد استعادة التخطيط الافتراضي؟ سيتم فقدان التغييرات الحالية.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('استعادة'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _dbHelper.deleteLayout(widget.languageCode);
        _loadLayout();
        setState(() => hasChanges = false);
      } catch (e) {
        _showErrorDialog('خطأ في استعادة التخطيط: $e');
      }
    }
  }

  void _addNewRow() async {
    final TextEditingController controller = TextEditingController();
    String? rowKey = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة صف جديد'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'اسم الصف (مثل: row7)',
            hintText: 'أدخل اسم الصف',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );

    if (rowKey != null && rowKey.isNotEmpty && layout != null) {
      setState(() {
        layout!.addRow(rowKey, KeyboardRow(height: 55, keys: []));
        hasChanges = true;
      });
    }
  }

  void _deleteRow(String rowKey) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الصف'),
        content: Text('هل تريد حذف الصف "$rowKey"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true && layout != null) {
      setState(() {
        layout!.removeRow(rowKey);
        hasChanges = true;
      });
    }
  }

  void _editRow(String rowKey, KeyboardRow row) async {
    final result = await showDialog<KeyboardRow>(
      context: context,
      builder: (context) => _RowEditDialog(row: row),
    );

    if (result != null && layout != null) {
      setState(() {
        layout!.addRow(rowKey, result);
        hasChanges = true;
      });
    }
  }

  void _editKey(String rowKey, int keyIndex, KeyboardKey key) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KeyEditorScreen(k: key),
      ),
    );

    if (result != null && layout != null) {
      setState(() {
        final row = layout!.rows[rowKey]!;
        final newKeys = List<KeyboardKey>.from(row.keys);
        newKeys[keyIndex] = result;
        layout!.addRow(rowKey, row.copyWith(keys: newKeys));
        hasChanges = true;
      });
    }
  }

  void _addKeyToRow(String rowKey) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KeyEditorScreen(
          k: KeyboardKey(
            type: 'All',
            weight: 1.0,
            text: '',
            hint: '',
          ),
        ),
      ),
    );

    if (result != null && layout != null) {
      setState(() {
        final row = layout!.rows[rowKey]!;
        final newKeys = List<KeyboardKey>.from(row.keys)..add(result);
        layout!.addRow(rowKey, row.copyWith(keys: newKeys));
        hasChanges = true;
      });
    }
  }

  void _deleteKey(String rowKey, int keyIndex) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المفتاح'),
        content: const Text('هل تريد حذف هذا المفتاح؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true && layout != null) {
      setState(() {
        final row = layout!.rows[rowKey]!;
        final newKeys = List<KeyboardKey>.from(row.keys)..removeAt(keyIndex);
        layout!.addRow(rowKey, row.copyWith(keys: newKeys));
        hasChanges = true;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('خطأ'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تعديل تخطيط ${widget.languageCode}'),
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
        actions: [
          if (hasChanges)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveLayout,
              tooltip: 'حفظ',
            ),
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: _resetToDefault,
            tooltip: 'استعادة الافتراضي',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : layout == null
              ? const Center(child: Text('خطأ في تحميل التخطيط'))
              : Column(
                  children: [
                    if (hasChanges)
                      Container(
                        color: Colors.orange.shade100,
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            const Icon(Icons.warning, color: Colors.orange),
                            const SizedBox(width: 8),
                            const Text('يوجد تغييرات غير محفوظة'),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: _saveLayout,
                              child: const Text('حفظ'),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: layout!.getSortedRows().length,
                        itemBuilder: (context, index) {
                          final rowEntry = layout!.getSortedRows()[index];
                          final rowKey = rowEntry.key;
                          final row = rowEntry.value;

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text(
                                    'الصف: $rowKey',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text('الارتفاع: ${row.height} | المفاتيح: ${row.keys.length}'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.add, color: Colors.blue),
                                        onPressed: () => _addKeyToRow(rowKey),
                                        tooltip: 'إضافة مفتاح',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.green),
                                        onPressed: () => _editRow(rowKey, row),
                                        tooltip: 'تعديل الصف',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deleteRow(rowKey),
                                        tooltip: 'حذف الصف',
                                      ),
                                    ],
                                  ),
                                ),
                                if (row.keys.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: GridView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent: 80,
                                        childAspectRatio: 1,
                                        crossAxisSpacing: 4,
                                        mainAxisSpacing: 4,
                                      ),
                                      itemCount: row.keys.length,
                                      itemBuilder: (context, keyIndex) {
                                        final key = row.keys[keyIndex];
                                        return GestureDetector(
                                          onTap: () => _editKey(rowKey, keyIndex, key),
                                          onLongPress: () => _deleteKey(rowKey, keyIndex),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: _getKeyColor(key.type),
                                              border: Border.all(color: Colors.grey),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Center(
                                              child: Text(
                                                key.text.isNotEmpty ? key.text : key.type,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewRow,
        backgroundColor: Colors.green.shade800,
        child: const Icon(Icons.add, color: Colors.white),
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
        return Colors.grey.shade100;
    }
  }
}

class _RowEditDialog extends StatefulWidget {
  final KeyboardRow row;

  const _RowEditDialog({required this.row});

  @override
  State<_RowEditDialog> createState() => _RowEditDialogState();
}

class _RowEditDialogState extends State<_RowEditDialog> {
  late TextEditingController _heightController;

  @override
  void initState() {
    super.initState();
    _heightController = TextEditingController(text: widget.row.height.toString());
  }

  @override
  void dispose() {
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تعديل الصف'),
      content: TextField(
        controller: _heightController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'الارتفاع',
          hintText: 'أدخل ارتفاع الصف',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            final height = double.tryParse(_heightController.text) ?? widget.row.height;
            Navigator.pop(context, widget.row.copyWith(height: height));
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}