
import 'package:flutter/material.dart';
import '../database/layout_database.dart';
import 'layout_editor_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<String> _languages = [];
  bool _isLoading = true;
  final TextEditingController _newLanguageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLanguages();
  }

  Future<void> _loadLanguages() async {
    setState(() => _isLoading = true);
    final languages = await LayoutDatabase.getAllLanguages();
    setState(() {
      _languages = languages;
      _isLoading = false;
    });
  }

  Future<void> _addNewLayout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة تخطيط جديد'),
        content: TextField(
          controller: _newLanguageController,
          decoration: const InputDecoration(
            labelText: 'اسم اللغة (مثل: fr, de, es)',
            hintText: 'أدخل رمز اللغة',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              if (_newLanguageController.text.trim().isNotEmpty) {
                // إنشاء تخطيط فارغ أساسي
                const basicLayout = '''
{
  "row1": {
    "height": 55,
    "keys": [
      {"type": "All", "weight": 1.0, "text": "1", "hint": "", "click": "sendText", "longPress": "", "textToSend": "1"},
      {"type": "All", "weight": 1.0, "text": "2", "hint": "", "click": "sendText", "longPress": "", "textToSend": "2"},
      {"type": "All", "weight": 1.0, "text": "3", "hint": "", "click": "sendText", "longPress": "", "textToSend": "3"}
    ]
  }
}
''';
                await LayoutDatabase.insertOrUpdate(
                  _newLanguageController.text.trim(),
                  basicLayout,
                );
                _newLanguageController.clear();
                Navigator.pop(context);
                _loadLanguages();
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteLayout(String lang) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف تخطيط "$lang"؟'),
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
      await LayoutDatabase.deleteLayout(lang);
      _loadLanguages();
    }
  }

  Future<void> _resetToDefaults() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('العودة للإعدادات الافتراضية'),
        content: const Text('هل تريد حذف جميع التخطيطات والعودة للتخطيطات الافتراضية (العربية والإنجليزية)؟'),
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
      await LayoutDatabase.resetToDefaults();
      _loadLanguages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('محرر تخطيطات لوحة المفاتيح'),
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: _resetToDefaults,
              icon: const Icon(Icons.restore),
              tooltip: 'العودة للإعدادات الافتراضية',
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _languages.isEmpty
                ? const Center(
                    child: Text(
                      'لا توجد تخطيطات متاحة',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _languages.length,
                    itemBuilder: (context, index) {
                      final lang = _languages[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getLanguageColor(lang),
                            child: Text(
                              lang.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            _getLanguageName(lang),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text('تخطيط لوحة المفاتيح $lang'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  final layout = await LayoutDatabase.getKeyboardLayout(lang);
                                  if (layout != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LayoutEditorScreen(layout: layout),
                                      ),
                                    ).then((_) => _loadLanguages());
                                  }
                                },
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                tooltip: 'تحرير التخطيط',
                              ),
                              if (!['ar', 'en'].contains(lang))
                                IconButton(
                                  onPressed: () => _deleteLayout(lang),
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  tooltip: 'حذف التخطيط',
                                ),
                            ],
                          ),
                          onTap: () async {
                            final layout = await LayoutDatabase.getKeyboardLayout(lang);
                            if (layout != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LayoutEditorScreen(layout: layout),
                                ),
                              ).then((_) => _loadLanguages());
                            }
                          },
                        ),
                      );
                    },
                  ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addNewLayout,
          backgroundColor: Colors.blue.shade700,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Color _getLanguageColor(String lang) {
    switch (lang) {
      case 'ar':
        return Colors.green;
      case 'en':
        return Colors.blue;
      case 'fr':
        return Colors.purple;
      case 'de':
        return Colors.orange;
      case 'es':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getLanguageName(String lang) {
    switch (lang) {
      case 'ar':
        return 'العربية';
      case 'en':
        return 'الإنجليزية';
      case 'fr':
        return 'الفرنسية';
      case 'de':
        return 'الألمانية';
      case 'es':
        return 'الإسبانية';
      default:
        return lang.toUpperCase();
    }
  }

  @override
  void dispose() {
    _newLanguageController.dispose();
    super.dispose();
  }
}
