
import 'package:flutter/material.dart';
import '../models/layout.dart';
import './editKey.dart';

class RowEditorScreen extends StatefulWidget {
  final String rowKey;
  final KeyboardRow row;

  const RowEditorScreen({
    Key? key,
    required this.rowKey,
    required this.row,
  }) : super(key: key);

  @override
  State<RowEditorScreen> createState() => _RowEditorScreenState();
}

class _RowEditorScreenState extends State<RowEditorScreen> {
  late KeyboardRow editedRow;
  bool hasChanges = false;

  @override
  void initState() {
    super.initState();
    // نسخ الصف للتعديل
    editedRow = KeyboardRow(
      height: widget.row.height,
      keys: widget.row.keys.map((k) => k.copyWith()).toList(),
    );
  }

  void _updateHeight(int newHeight) {
    setState(() {
      editedRow.height = newHeight;
      hasChanges = true;
    });
  }

  Future<void> _addKey() async {
    final result = await showDialog<KeyModel>(
      context: context,
      builder: (context) => const KeyEditorDialog(),
    );

    if (result != null) {
      setState(() {
        editedRow.keys.add(result);
        hasChanges = true;
      });
    }
  }

  Future<void> _editKey(int index) async {
    final result = await showDialog<KeyModel>(
      context: context,
      builder: (context) => KeyEditorDialog(key1: editedRow.keys[index]),
    );

    if (result != null) {
      setState(() {
        editedRow.keys[index] = result;
        hasChanges = true;
      });
    }
  }

  void _deleteKey(int index) {
    setState(() {
      editedRow.keys.removeAt(index);
      hasChanges = true;
    });
  }

  void _moveKey(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final key = editedRow.keys.removeAt(oldIndex);
      editedRow.keys.insert(newIndex, key);
      hasChanges = true;
    });
  }

  void _duplicateKey(int index) {
    setState(() {
      final duplicatedKey = editedRow.keys[index].copyWith();
      editedRow.keys.insert(index + 1, duplicatedKey);
      hasChanges = true;
    });
  }

  Future<bool> _onWillPop() async {
    if (!hasChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تحذير'),
        content: const Text('لديك تغييرات غير محفوظة. هل تريد الخروج دون حفظ؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('خروج دون حفظ'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: Text('تحرير ${widget.rowKey.toUpperCase()}'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: () => Navigator.pop(context, editedRow),
                tooltip: 'حفظ',
              ),
            ],
          ),
          body: Column(
            children: [
              // إعدادات الصف
              Container(
                color: Colors.grey[200],
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'إعدادات الصف',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('الارتفاع: '),
                        Expanded(
                          child: Slider(
                            value: editedRow.height.toDouble(),
                            min: 30,
                            max: 100,
                            divisions: 14,
                            label: editedRow.height.toString(),
                            onChanged: (value) => _updateHeight(value.toInt()),
                          ),
                        ),
                        SizedBox(
                          width: 60,
                          child: Text(
                            '${editedRow.height}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'عدد المفاتيح: ${editedRow.keys.length}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),

              // قائمة المفاتيح
              Expanded(
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: editedRow.keys.length,
                  onReorder: _moveKey,
                  itemBuilder: (context, index) {
                    final key = editedRow.keys[index];
                    return _buildKeyCard(key, index);
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _addKey,
            icon: const Icon(Icons.add),
            label: const Text('إضافة مفتاح'),
          ),
        ),
      ),
    );
  }

  Widget _buildKeyCard(KeyModel key, int index) {
    return Card(
      key: ValueKey('key_$index'),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _editKey(index),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // أيقونة السحب
                  const Icon(Icons.drag_handle, color: Colors.grey),
                  const SizedBox(width: 12),
                  
                  // نوع المفتاح
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getKeyColor(key.type),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      key.type,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // النص
                  Expanded(
                    child: Text(
                      key.text.isEmpty ? '(فارغ)' : key.text,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  // الأزرار
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _editKey(index);
                          break;
                        case 'duplicate':
                          _duplicateKey(index);
                          break;
                        case 'delete':
                          _deleteKey(index);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('تعديل'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.copy, color: Colors.green),
                            SizedBox(width: 8),
                            Text('نسخ'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('حذف'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // معلومات إضافية
              Wrap(
                spacing: 16,
                children: [
                  _buildInfoChip(Icons.line_weight, 'الوزن: ${key.weight}'),
                  if (key.hint.isNotEmpty)
                    _buildInfoChip(Icons.comment, 'تلميح: ${key.hint}'),
                  if (key.keyCode != null)
                    _buildInfoChip(Icons.code, 'كود: ${key.keyCode}'),
                  if (key.click != null && key.click!.isNotEmpty)
                    _buildInfoChip(Icons.touch_app, 'نقر: ${key.click}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
      ],
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
