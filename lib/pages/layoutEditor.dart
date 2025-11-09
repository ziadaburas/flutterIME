
import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../models/layout.dart';
import './preview.dart';
import './editRow.dart';

class LayoutEditorScreen extends StatefulWidget {
  final String language;

  const LayoutEditorScreen({Key? key, required this.language}) : super(key: key);

  @override
  State<LayoutEditorScreen> createState() => _LayoutEditorScreenState();
}

class _LayoutEditorScreenState extends State<LayoutEditorScreen> {
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
    final loadedLayout = await DatabaseHelper.instance.getOrCreateLayout(widget.language);
    setState(() {
      layout = loadedLayout;
      isLoading = false;
    });
  }

  Future<void> _saveLayout() async {
    if (layout != null) {
      await DatabaseHelper.instance.insertOrUpdateLayout(widget.language, layout!);
      setState(() => hasChanges = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ التخطيط بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _addRow() async {
    if (layout == null) return;

    final rowNumber = layout!.rows.length + 1;
    final newRow = KeyboardRow(
      height: 55,
      keys: [
        KeyModel(
          type: 'letter',
          weight: 1.0,
          text: 'A',
          hint: '',
        ),
      ],
    );

    setState(() {
      layout!.rows['row$rowNumber'] = newRow;
      hasChanges = true;
    });
  }

  Future<void> _editRow(String rowKey) async {
    if (layout == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RowEditorScreen(
          rowKey: rowKey,
          row: layout!.rows[rowKey]!,
        ),
      ),
    );

    if (result != null && result is KeyboardRow) {
      setState(() {
        layout!.rows[rowKey] = result;
        hasChanges = true;
      });
    }
  }

  Future<void> _deleteRow(String rowKey) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف $rowKey؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        layout!.rows.remove(rowKey);
        hasChanges = true;
      });
    }
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
            title: Text('تحرير تخطيط ${widget.language.toUpperCase()}'),
            centerTitle: true,
            actions: [
              if (hasChanges)
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _saveLayout,
                  tooltip: 'حفظ',
                ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadLayout,
                tooltip: 'إعادة تحميل',
              ),
            ],
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : layout == null
                  ? const Center(child: Text('فشل تحميل التخطيط'))
                  : Column(
                      children: [
                        // معاينة لوحة المفاتيح
                        Container(
                          color: Colors.grey[200],
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'معاينة',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (hasChanges)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        'غير محفوظ',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              KeyboardPreview(layout: layout!),
                            ],
                          ),
                        ),
                        
                        // قائمة الصفوف
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: layout!.rows.length,
                            itemBuilder: (context, index) {
                              final rowKey = 'row${index + 1}';
                              final row = layout!.rows[rowKey];
                              
                              if (row == null) return const SizedBox.shrink();
                              
                              return _buildRowCard(rowKey, row);
                            },
                          ),
                        ),
                      ],
                    ),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (hasChanges)
                FloatingActionButton(
                  heroTag: 'save',
                  onPressed: _saveLayout,
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.save),
                ),
              const SizedBox(height: 10),
              FloatingActionButton(
                heroTag: 'add',
                onPressed: _addRow,
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRowCard(String rowKey, KeyboardRow row) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _editRow(rowKey),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    rowKey.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editRow(rowKey),
                        tooltip: 'تعديل',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteRow(rowKey),
                        tooltip: 'حذف',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.height, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'الارتفاع: ${row.height}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.keyboard, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'المفاتيح: ${row.keys.length}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // عرض المفاتيح
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: row.keys.map((key) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getKeyColor(key.type),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      key.text.isEmpty ? '␣' : key.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
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
