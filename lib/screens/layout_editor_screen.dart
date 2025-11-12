
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../models/keyboard_layout.dart';
import '../models/keyboard_row.dart';
import '../database/layout_database.dart';
import 'row_editor_screen.dart';

class LayoutEditorScreen extends StatefulWidget {
  final KeyboardLayout layout;

  const LayoutEditorScreen({super.key, required this.layout});

  @override
  State<LayoutEditorScreen> createState() => _LayoutEditorScreenState();
}

class _LayoutEditorScreenState extends State<LayoutEditorScreen> {
  late KeyboardLayout _layout;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _layout = widget.layout.copy();
  }

  Future<void> _saveLayout() async {
    await LayoutDatabase.saveKeyboardLayout(_layout);
    setState(() => _hasChanges = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ التخطيط بنجاح')),
      );
    }
  }

  Future<void> _addNewRow() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('إضافة صف جديد'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'اسم الصف (مثل: row7, row8)',
              hintText: 'أدخل اسم الصف',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  Navigator.pop(context, controller.text.trim());
                }
              },
              child: const Text('إضافة'),
            ),
          ],
        );
      },
    );

    if (result != null && !_layout.rows.containsKey(result)) {
      setState(() {
        _layout.rows[result] = KeyboardRow(
          height: 55.0,
          keys: [],
        );
        _hasChanges = true;
      });
    }
  }

  Future<void> _deleteRow(String rowKey) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف الصف "$rowKey"؟'),
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
        _layout.rows.remove(rowKey);
        _hasChanges = true;
      });
    }
  }

  Future<void> _resetToDefault() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('العودة للتخطيط الافتراضي'),
        content: const Text('هل تريد استعادة التخطيط الافتراضي؟ سيتم فقدان جميع التغييرات الحالية.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('استعادة'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // حذف التخطيط الحالي وإعادة إنشاء الافتراضي
      await LayoutDatabase.deleteLayout(_layout.lang);
      await LayoutDatabase.resetToDefaults();
      
      final defaultLayout = await LayoutDatabase.getKeyboardLayout(_layout.lang);
      if (defaultLayout != null) {
        setState(() {
          _layout = defaultLayout.copy();
          _hasChanges = false;
        });
      }
    }
  }

  Future<void> _exportLayout() async {
    try {
      final jsonString = _layout.toJsonString();
      final prettyJson = const JsonEncoder.withIndent('  ').convert(jsonDecode(jsonString));
      
      await Share.shareXFiles([
        XFile.fromData(
          utf8.encode(prettyJson),
          name: 'layout_${_layout.lang}.json',
          mimeType: 'application/json',
        ),
      ], text: 'تصدير تخطيط ${_layout.lang}');
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في التصدير: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _importLayout() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.bytes != null) {
        final jsonString = utf8.decode(result.files.single.bytes!);
        final newLayout = KeyboardLayout.fromJson(_layout.lang, jsonString);
        
        setState(() {
          _layout = newLayout;
          _hasChanges = true;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم استيراد التخطيط بنجاح')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في الاستيراد: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_hasChanges) {
          final shouldSave = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('حفظ التغييرات؟'),
              content: const Text('لديك تغييرات غير محفوظة، هل تريد حفظها قبل المغادرة؟'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('المغادرة بدون حفظ'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('حفظ والمغادرة'),
                ),
              ],
            ),
          );
          
          if (shouldSave == true) {
            await _saveLayout();
          }
        }
        return true;
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: Text('تحرير تخطيط ${_layout.lang.toUpperCase()}'),
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                onPressed: _importLayout,
                icon: const Icon(Icons.file_upload),
                tooltip: 'استيراد',
              ),
              IconButton(
                onPressed: _exportLayout,
                icon: const Icon(Icons.file_download),
                tooltip: 'تصدير',
              ),
              IconButton(
                onPressed: _resetToDefault,
                icon: const Icon(Icons.restore),
                tooltip: 'العودة للافتراضي',
              ),
              IconButton(
                onPressed: _hasChanges ? _saveLayout : null,
                icon: const Icon(Icons.save),
                tooltip: 'حفظ',
              ),
            ],
          ),
          body: Column(
            children: [
              if (_hasChanges)
                Container(
                  width: double.infinity,
                  color: Colors.orange.shade100,
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'لديك تغييرات غير محفوظة',
                        style: TextStyle(color: Colors.orange.shade700),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _saveLayout,
                        child: const Text('حفظ الآن'),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: _layout.rows.isEmpty
                    ? const Center(
                        child: Text(
                          'لا توجد صفوف في التخطيط',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _layout.rowKeys.length,
                        itemBuilder: (context, index) {
                          final rowKey = _layout.rowKeys[index];
                          final row = _layout.rows[rowKey]!;
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue.shade700,
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                rowKey,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('الارتفاع: ${row.height}'),
                                  Text('عدد الأزرار: ${row.keys.length}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => RowEditorScreen(
                                            rowKey: rowKey,
                                            row: row,
                                          ),
                                        ),
                                      );
                                      
                                      if (result != null) {
                                        setState(() {
                                          _layout.rows[rowKey] = result;
                                          _hasChanges = true;
                                        });
                                      }
                                    },
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    tooltip: 'تحرير الصف',
                                  ),
                                  IconButton(
                                    onPressed: () => _deleteRow(rowKey),
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    tooltip: 'حذف الصف',
                                  ),
                                ],
                              ),
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RowEditorScreen(
                                      rowKey: rowKey,
                                      row: row,
                                    ),
                                  ),
                                );
                                
                                if (result != null) {
                                  setState(() {
                                    _layout.rows[rowKey] = result;
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
            onPressed: _addNewRow,
            backgroundColor: Colors.blue.shade700,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
