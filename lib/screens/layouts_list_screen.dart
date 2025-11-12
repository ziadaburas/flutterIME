// import 'package:flutter/material.dart';
// import '../database/database_helper.dart';
// import '../models/keyboard_layout.dart';
// import 'layout_editor_screen.dart';

// class LayoutsListScreen extends StatefulWidget {
//   const LayoutsListScreen({super.key});

//   @override
//   State<LayoutsListScreen> createState() => _LayoutsListScreenState();
// }

// class _LayoutsListScreenState extends State<LayoutsListScreen> {
//   final DatabaseHelper _dbHelper = DatabaseHelper();
//   Map<String, String> layouts = {};
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadLayouts();
//   }

//   Future<void> _loadLayouts() async {
//     setState(() => isLoading = true);
//     try {
//       // إدراج التخطيطات الافتراضية إذا لم تكن موجودة
//       await _dbHelper.insertDefaultLayouts();
//       final allLayouts = await _dbHelper.getAllLayouts();
//       setState(() {
//         layouts = allLayouts;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() => isLoading = false);
//       _showErrorDialog('خطأ في تحميل التخطيطات: $e');
//     }
//   }

//   Future<void> _createNewLayout() async {
//     String? langCode = await _showCreateLayoutDialog();
//     if (langCode != null && langCode.isNotEmpty) {
//       try {
//         // إنشاء تخطيط افتراضي جديد
//         // استخدام دالة getOrCreateLayout لإنشاء تخطيط جديد
//         await _dbHelper.getOrCreateLayout(langCode);
//         _loadLayouts();
//       } catch (e) {
//         _showErrorDialog('خطأ في إنشاء التخطيط: $e');
//       }
//     }
//   }

//   Future<String?> _showCreateLayoutDialog() async {
//     final TextEditingController controller = TextEditingController();
//     return showDialog<String>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('إنشاء تخطيط جديد'),
//         content: TextField(
//           controller: controller,
//           decoration: const InputDecoration(
//             labelText: 'رمز اللغة (مثل: en, ar, fr)',
//             hintText: 'أدخل رمز اللغة',
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('إلغاء'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, controller.text.trim()),
//             child: const Text('إنشاء'),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _deleteLayout(String lang) async {
//     bool? confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('تأكيد الحذف'),
//         content: Text('هل تريد حذف تخطيط "$lang"؟'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('إلغاء'),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('حذف'),
//           ),
//         ],
//       ),
//     );

//     if (confirm == true) {
//       try {
//         await _dbHelper.deleteLayout(lang);
//         _loadLayouts();
//       } catch (e) {
//         _showErrorDialog('خطأ في حذف التخطيط: $e');
//       }
//     }
//   }

//   Future<void> _resetToDefaults() async {
//     bool? confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('استعادة الإعدادات الافتراضية'),
//         content: const Text('هل تريد حذف جميع التخطيطات واستعادة الإعدادات الافتراضية؟'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('إلغاء'),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('استعادة'),
//           ),
//         ],
//       ),
//     );

//     if (confirm == true) {
//       try {
//         await _dbHelper.deleteAllLayouts();
//         await _dbHelper.insertDefaultLayouts();
//         _loadLayouts();
//       } catch (e) {
//         _showErrorDialog('خطأ في استعادة الإعدادات: $e');
//       }
//     }
//   }

//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('خطأ'),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('موافق'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('مدير تخطيطات لوحة المفاتيح'),
//         backgroundColor: Colors.blue.shade800,
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _loadLayouts,
//             tooltip: 'إعادة تحميل',
//           ),
//           IconButton(
//             icon: const Icon(Icons.restore),
//             onPressed: _resetToDefaults,
//             tooltip: 'استعادة الافتراضي',
//           ),
//         ],
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : layouts.isEmpty
//               ? const Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.keyboard, size: 64, color: Colors.grey),
//                       SizedBox(height: 16),
//                       Text(
//                         'لا توجد تخطيطات',
//                         style: TextStyle(fontSize: 18, color: Colors.grey),
//                       ),
//                     ],
//                   ),
//                 )
//               : ListView.builder(
//                   padding: const EdgeInsets.all(8),
//                   itemCount: layouts.length,
//                   itemBuilder: (context, index) {
//                     final entry = layouts.entries.elementAt(index);
//                     final lang = entry.key;
                    
//                     return Card(
//                       margin: const EdgeInsets.symmetric(vertical: 4),
//                       child: ListTile(
//                         leading: CircleAvatar(
//                           backgroundColor: Colors.blue.shade100,
//                           child: Text(
//                             lang.toUpperCase(),
//                             style: TextStyle(
//                               color: Colors.blue.shade800,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                         title: Text(
//                           'تخطيط $lang',
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         subtitle: Text(_getLayoutDescription(lang)),
//                         trailing: PopupMenuButton<String>(
//                           onSelected: (value) {
//                             switch (value) {
//                               case 'edit':
//                                 _editLayout(lang);
//                                 break;
//                               case 'delete':
//                                 _deleteLayout(lang);
//                                 break;
//                             }
//                           },
//                           itemBuilder: (context) => [
//                             const PopupMenuItem(
//                               value: 'edit',
//                               child: Row(
//                                 children: [
//                                   Icon(Icons.edit, color: Colors.blue),
//                                   SizedBox(width: 8),
//                                   Text('تعديل'),
//                                 ],
//                               ),
//                             ),
//                             const PopupMenuItem(
//                               value: 'delete',
//                               child: Row(
//                                 children: [
//                                   Icon(Icons.delete, color: Colors.red),
//                                   SizedBox(width: 8),
//                                   Text('حذف'),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                         onTap: () => _editLayout(lang),
//                       ),
//                     );
//                   },
//                 ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _createNewLayout,
//         backgroundColor: Colors.blue.shade800,
//         child: const Icon(Icons.add, color: Colors.white),
//       ),
//     );
//   }

//   void _editLayout(String lang) async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => LayoutEditorScreen(languageCode: lang),
//       ),
//     );
    
//     if (result == true) {
//       _loadLayouts();
//     }
//   }

//   String _getLayoutDescription(String lang) {
//     switch (lang.toLowerCase()) {
//       case 'en':
//         return 'تخطيط الإنجليزية';
//       case 'ar':
//         return 'تخطيط العربية';
//       case 'fr':
//         return 'تخطيط الفرنسية';
//       case 'es':
//         return 'تخطيط الإسبانية';
//       default:
//         return 'تخطيط مخصص';
//     }
//   }
// }