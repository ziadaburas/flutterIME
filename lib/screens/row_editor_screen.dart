
import 'package:flutter/material.dart';
import '../models/keyboard_row.dart';
import '../models/keyboard_key.dart';
import 'key_editor_screen.dart';

class RowEditorScreen extends StatefulWidget {
  final String rowKey;
  final KeyboardRow row;

  const RowEditorScreen({
    super.key,
    required this.rowKey,
    required this.row,
  });

  @override
  State<RowEditorScreen> createState() => _RowEditorScreenState();
}

class _RowEditorScreenState extends State<RowEditorScreen> {
  late KeyboardRow _row;
  bool _hasChanges = false;
  final TextEditingController _heightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _row = widget.row.copy();
    _heightController.text = _row.height.toString();
  }

  void _updateHeight() {
    final newHeight = double.tryParse(_heightController.text);
    if (newHeight != null && newHeight > 0) {
      setState(() {
        _row.height = newHeight;
        _hasChanges = true;
      });
    }
  }

  Future<void> _addNewKey() async {
    final newKey = KeyboardKey(
      type: 'All',
      weight: 1.0,
      text: '',
      hint: '',
      click: 'sendText',
      longPress: '',
      textToSend: '',
    );

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KeyEditorScreen(
          keyIndex: _row.keys.length,
          k: newKey,
          isNewKey: true,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _row.keys.add(result);
        _hasChanges = true;
      });
    }
  }

  Future<void> _deleteKey(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف الزر "${_row.keys[index].text}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _row.keys.removeAt(index);
        _hasChanges = true;
      });
    }
  }

  Future<void> _moveKey(int oldIndex, int newIndex) async {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final key = _row.keys.removeAt(oldIndex);
      _row.keys.insert(newIndex, key);
      _hasChanges = true;
    });
  }

  Future<void> _resetRowToDefault() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعادة تعيين الصف'),
        content: const Text('هل تريد إعادة تعيين هذا الصف إلى حالة أساسية؟'),
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
        _row = KeyboardRow(
          height: 55.0,
          keys: [
            KeyboardKey(
              type: 'All',
              weight: 1.0,
              text: 'أ',
              hint: '',
              click: 'sendText',
              longPress: '',
              textToSend: 'أ',
            ),
            KeyboardKey(
              type: 'All',
              weight: 1.0,
              text: 'ب',
              hint: '',
              click: 'sendText',
              longPress: '',
              textToSend: 'ب',
            ),
          ],
        );
        _heightController.text = _row.height.toString();
        _hasChanges = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_hasChanges) {
          Navigator.pop(context, _row);
        } else {
          Navigator.pop(context);
        }
        return false;
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: Text('تحرير ${widget.rowKey}'),
            backgroundColor: Colors.green.shade700,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                onPressed: _resetRowToDefault,
                icon: const Icon(Icons.restore),
                tooltip: 'إعادة تعيين',
              ),
              IconButton(
                onPressed: _hasChanges
                    ? () => Navigator.pop(context, _row)
                    : null,
                icon: const Icon(Icons.save),
                tooltip: 'حفظ',
              ),
            ],
          ),
          body: Column(
            children: [
              // معلومات الصف
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'معلومات الصف: ${widget.rowKey}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('الارتفاع: '),
                        SizedBox(
                          width: 100,
                          child: TextField(
                            controller: _heightController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (_) => _updateHeight(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text('عدد الأزرار: ${_row.keys.length}'),
                      ],
                    ),
                  ],
                ),
              ),
              
              // قائمة الأزرار
              Expanded(
                child: _row.keys.isEmpty
                    ? const Center(
                        child: Text(
                          'لا توجد أزرار في هذا الصف',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _row.keys.length,
                        onReorder: _moveKey,
                        itemBuilder: (context, index) {
                          final key = _row.keys[index];
                          return Card(
                            key: ValueKey(index),
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _getKeyTypeColor(key.type),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    key.text.isEmpty ? '؟' : key.text,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                key.text.isEmpty ? 'زر فارغ' : key.text,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('النوع: ${key.type}'),
                                  Text('الوزن: ${key.weight}'),
                                  if (key.hint.isNotEmpty) Text('التلميح: ${key.hint}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.drag_handle, color: Colors.grey.shade600),
                                  IconButton(
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => KeyEditorScreen(
                                            keyIndex: index,
                                            k: key,
                                          ),
                                        ),
                                      );
                                      
                                      if (result != null) {
                                        setState(() {
                                          _row.keys[index] = result;
                                          _hasChanges = true;
                                        });
                                      }
                                    },
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    tooltip: 'تحرير الزر',
                                  ),
                                  IconButton(
                                    onPressed: () => _deleteKey(index),
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    tooltip: 'حذف الزر',
                                  ),
                                ],
                              ),
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => KeyEditorScreen(
                                      keyIndex: index,
                                      k: key,
                                    ),
                                  ),
                                );
                                
                                if (result != null) {
                                  setState(() {
                                    _row.keys[index] = result;
                                    _hasChanges = true;
                                  });
                                }
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _addNewKey,
            backgroundColor: Colors.green.shade700,
            child: const Icon(Icons.add, color: Colors.white),
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
    _heightController.dispose();
    super.dispose();
  }
}
