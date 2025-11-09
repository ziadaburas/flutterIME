
import 'package:flutter/material.dart';

class AddLanguageDialog extends StatefulWidget {
  const AddLanguageDialog({Key? key}) : super(key: key);

  @override
  State<AddLanguageDialog> createState() => _AddLanguageDialogState();
}

class _AddLanguageDialogState extends State<AddLanguageDialog> {
  final _formKey = GlobalKey<FormState>();
  final _langController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _langController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text('إضافة لغة جديدة'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _langController,
                decoration: const InputDecoration(
                  labelText: 'رمز اللغة',
                  hintText: 'مثال: ar, en, fr',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.language),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال رمز اللغة';
                  }
                  if (value.length > 5) {
                    return 'رمز اللغة طويل جداً';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم اللغة',
                  hintText: 'مثال: العربية, English',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.text_fields),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال اسم اللغة';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Navigator.pop(context, {
                  'lang': _langController.text.trim().toLowerCase(),
                  'name': _nameController.text.trim(),
                });
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}
