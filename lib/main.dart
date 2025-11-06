/*import 'package:flutter/material.dart';
import './pages/home.dart';

void main() {
  runApp(const KeyboardLayoutApp());
}

class KeyboardLayoutApp extends StatelessWidget {
  const KeyboardLayoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'محرر تخطيطات لوحة المفاتيح',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 2,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'db/db1.dart';
import 'models.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تهيئة قاعدة البيانات بالتخطيطات الافتراضية
  await DatabaseHelper.instance.insertDefaultLayouts();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'محرر تخطيط لوحة المفاتيح',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Arial',
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedLang = 'en';

  final List<RowOption> rowOptions = [
    RowOption(
      name: 'navRow',
      title: 'صف التنقل (Navigation Row)',
      icon: Icons.navigation,
      color: Colors.purple,
    ),
    RowOption(
      name: 'numRow',
      title: 'صف الأرقام (Number Row)',
      icon: Icons.numbers,
      color: Colors.blue,
    ),
    RowOption(
      name: 'row1',
      title: 'الصف الأول (Row 1)',
      icon: Icons.keyboard,
      color: Colors.green,
    ),
    RowOption(
      name: 'row2',
      title: 'الصف الثاني (Row 2)',
      icon: Icons.keyboard_outlined,
      color: Colors.orange,
    ),
    RowOption(
      name: 'row3',
      title: 'الصف الثالث (Row 3)',
      icon: Icons.keyboard_alt_outlined,
      color: Colors.red,
    ),
    RowOption(
      name: 'bottomRow',
      title: 'الصف السفلي (Bottom Row)',
      icon: Icons.space_bar,
      color: Colors.teal,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('محرر تخطيط لوحة المفاتيح'),
          centerTitle: true,
          elevation: 2,
        ),
        body: Column(
          children: [
            // اختيار اللغة
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'اختر اللغة: ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 16),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'en',
                        label: Text('English'),
                        icon: Icon(Icons.language),
                      ),
                      ButtonSegment(
                        value: 'ar',
                        label: Text('العربية'),
                        icon: Icon(Icons.language),
                      ),
                    ],
                    selected: {selectedLang},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        selectedLang = newSelection.first;
                      });
                    },
                  ),
                ],
              ),
            ),

            // قائمة الصفوف
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: rowOptions.length,
                itemBuilder: (context, index) {
                  final option = rowOptions[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditRowScreen(
                              lang: selectedLang,
                              rowName: option.name,
                              rowTitle: option.title,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: option.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                option.icon,
                                size: 32,
                                color: option.color,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                option.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_back_ios,
                              color: Colors.grey[400],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditRowScreen extends StatefulWidget {
  final String lang;
  final String rowName;
  final String rowTitle;

  const EditRowScreen({
    Key? key,
    required this.lang,
    required this.rowName,
    required this.rowTitle,
  }) : super(key: key);

  @override
  State<EditRowScreen> createState() => _EditRowScreenState();
}

class _EditRowScreenState extends State<EditRowScreen> {
  KeyboardLayout? layout;
  Map<String, dynamic> rowData = {};
  bool isLoading = true;
  Map<String, TextEditingController> controllers = {};

  @override
  void initState() {
    super.initState();
    _loadLayout();
  }

  Future<void> _loadLayout() async {
    final jsonString = await DatabaseHelper.instance.getOrCreateLayout(widget.lang);
    final loadedLayout = KeyboardLayout.fromJson(jsonString);
    
    setState(() {
      layout = loadedLayout;
      rowData = Map<String, dynamic>.from(loadedLayout.getRow(widget.rowName));
      
      // إنشاء controllers لكل مفتاح
      rowData.forEach((key, value) {
        if (value is String) {
          controllers[key] = TextEditingController(text: value);
        } else if (value is Map) {
          // للمفاتيح المعقدة مثل navRow
          controllers[key] = TextEditingController(text: value.toString());
        }
      });
      
      isLoading = false;
    });
  }

  Future<void> _saveLayout() async {
    if (layout == null) return;

    // تحديث البيانات من controllers
    rowData.forEach((key, value) {
      if (controllers.containsKey(key)) {
        if (value is String) {
          rowData[key] = controllers[key]!.text;
        }
      }
    });

    layout!.updateRow(widget.rowName, rowData);
    await DatabaseHelper.instance.insertOrUpdateLayout(widget.lang, layout!.toJson());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم الحفظ بنجاح! ✓'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildKeyEditor(String key, dynamic value) {
    if (value is Map) {
      // للمفاتيح المعقدة مثل navRow
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ExpansionTile(
          title: Text(
            key,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          children: (value as Map<String, dynamic>).entries.map((entry) {
            final subController = TextEditingController(text: entry.value.toString());
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: subController,
                decoration: InputDecoration(
                  labelText: entry.key,
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                onChanged: (newValue) {
                  rowData[key][entry.key] = newValue;
                },
              ),
            );
          }).toList(),
        ),
      );
    }

    // للمفاتيح البسيطة
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    key,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controllers[key],
              decoration: InputDecoration(
                labelText: 'القيمة / الرموز المتعددة',
                hintText: 'أدخل القيمة أو الرموز مفصولة بمسافات',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.edit),
              ),
              maxLines: 2,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.rowTitle),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveLayout,
              tooltip: 'حفظ التغييرات',
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.blue[50],
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'قم بتعديل المفاتيح والرموز، ثم اضغط على حفظ',
                            style: TextStyle(
                              color: Colors.blue[900],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: rowData.entries
                          .map((entry) => _buildKeyEditor(entry.key, entry.value))
                          .toList(),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 5,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveLayout,
                        icon: const Icon(Icons.save),
                        label: const Text(
                          'حفظ التغييرات',
                          style: TextStyle(fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    controllers.forEach((key, controller) {
      controller.dispose();
    });
    super.dispose();
  }
}

class RowOption {
  final String name;
  final String title;
  final IconData icon;
  final Color color;

  RowOption({
    required this.name,
    required this.title,
    required this.icon,
    required this.color,
  });
}