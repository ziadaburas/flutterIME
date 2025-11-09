
import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import './layoutEditor.dart';
import './addLangDialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> languages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLanguages();
  }

  Future<void> _loadLanguages() async {
    setState(() => isLoading = true);
    
    // إدراج التخطيطات الافتراضية
    await DatabaseHelper.instance.insertDefaultLayouts();
    
    final langs = await DatabaseHelper.instance.getAllLanguages();
    setState(() {
      languages = langs;
      isLoading = false;
    });
  }

  Future<void> _addLanguage() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const AddLanguageDialog(),
    );

    if (result != null) {
      final lang = result['lang']!;
      final name = result['name']!;
      
      // إنشاء تخطيط جديد بناءً على الإنجليزية
      final layout = await DatabaseHelper.instance.getOrCreateLayout(lang);
      await DatabaseHelper.instance.insertOrUpdateLayout(lang, layout);
      
      _loadLanguages();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم إضافة اللغة: $name')),
        );
      }
    }
  }

  Future<void> _deleteLanguage(String lang) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف تخطيط "$lang"؟'),
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
      await DatabaseHelper.instance.deleteLayout(lang);
      _loadLanguages();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم حذف تخطيط "$lang"')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('محرر تخطيطات لوحة المفاتيح'),
          centerTitle: true,
          elevation: 2,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : languages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.keyboard_outlined, 
                          size: 100, 
                          color: Colors.grey[400]
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'لا توجد تخطيطات',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: _addLanguage,
                          icon: const Icon(Icons.add),
                          label: const Text('إضافة لغة جديدة'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadLanguages,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: languages.length,
                      itemBuilder: (context, index) {
                        final lang = languages[index];
                        return _buildLanguageCard(lang);
                      },
                    ),
                  ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _addLanguage,
          icon: const Icon(Icons.add),
          label: const Text('إضافة لغة'),
        ),
      ),
    );
  }

  Widget _buildLanguageCard(String lang) {
    final languageNames = {
      'ar': 'العربية',
      'en': 'English',
      'fr': 'Français',
      'es': 'Español',
      'de': 'Deutsch',
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LayoutEditorScreen(language: lang),
            ),
          );
          
          if (result == true) {
            _loadLanguages();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getLanguageColor(lang),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    lang.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageNames[lang] ?? lang.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'رمز اللغة: $lang',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LayoutEditorScreen(language: lang),
                    ),
                  );
                  
                  if (result == true) {
                    _loadLanguages();
                  }
                },
                tooltip: 'تعديل',
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteLanguage(lang),
                tooltip: 'حذف',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getLanguageColor(String lang) {
    final colors = {
      'ar': Colors.green,
      'en': Colors.blue,
      'fr': Colors.purple,
      'es': Colors.orange,
      'de': Colors.red,
    };
    return colors[lang] ?? Colors.teal;
  }
}
