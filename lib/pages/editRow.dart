
import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import 'editKey.dart';

class EditRowScreen extends StatefulWidget {
  final String rowKey;
  final String rowTitle;
  final String lang;

  const EditRowScreen({
    super.key,
    required this.rowKey,
    required this.rowTitle,
    required this.lang,
  });

  @override
  State<EditRowScreen> createState() => _EditRowScreenState();
}

class _EditRowScreenState extends State<EditRowScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Map<String, dynamic> _rowData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRowData();
  }

  Future<void> _loadRowData() async {
    Map<String, dynamic> layout = await _dbHelper.getOrCreateLayout(widget.lang);
    setState(() {
      _rowData = layout[widget.rowKey] ?? {};
      _isLoading = false;
    });
  }

  Future<void> _saveRowData() async {
    Map<String, dynamic> layout = await _dbHelper.getOrCreateLayout(widget.lang);
    layout[widget.rowKey] = _rowData;
    await _dbHelper.insertOrUpdate(widget.lang, layout);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم الحفظ بنجاح ✓'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.rowTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveRowData,
            tooltip: 'حفظ التغييرات',
          ),
        ],
      ),
      body: _rowData.isEmpty
          ? const Center(child: Text('لا توجد بيانات'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _rowData.length,
              itemBuilder: (context, index) {
                String key = _rowData.keys.elementAt(index);
                dynamic value = _rowData[key];
                return _buildKeyCard(key, value);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewKey,
        icon: const Icon(Icons.add),
        label: const Text('إضافة مفتاح جديد'),
      ),
    );
  }

  Widget _buildKeyCard(String key, dynamic value) {
    String displayValue = _getDisplayValue(value);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              key,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
        ),
        title: Text(
          'المفتاح: $key',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'القيمة: $displayValue',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _editKey(key, value),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteKey(key),
            ),
          ],
        ),
        onTap: () => _editKey(key, value),
      ),
    );
  }

  String _getDisplayValue(dynamic value) {
    if (value is String) {
      return value.isEmpty ? '(فارغ)' : value;
    } else if (value is Map) {
      return value.toString();
    }
    return value.toString();
  }

  Future<void> _editKey(String oldKey, dynamic value) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditKeyScreen(
          currentKey: oldKey,
          currentValue: value,
          rowKey: widget.rowKey,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        // إذا تم تغيير اسم المفتاح، نحذف القديم
        if (result['key'] != oldKey) {
          _rowData.remove(oldKey);
        }
        _rowData[result['key']] = result['value'];
      });
      await _saveRowData();
    }
  }

  Future<void> _addNewKey() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditKeyScreen(
          currentKey: '',
          currentValue: '',
          rowKey: widget.rowKey,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _rowData[result['key']] = result['value'];
      });
      await _saveRowData();
    }
  }

  Future<void> _deleteKey(String key) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف المفتاح "$key"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _rowData.remove(key);
      });
      await _saveRowData();
    }
  }
}
