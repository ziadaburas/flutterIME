
import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import './editRow.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  String _selectedLang = 'en';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    await _dbHelper.insertDefaultLayouts();
    setState(() {
      _isLoading = false;
    });
  }

  final List<RowInfo> _rows = [
    RowInfo(
      key: 'navRow',
      title: 'صف التنقل (Navigation Row)',
      icon: Icons.navigation,
      color: Colors.blue,
      description: 'مفاتيح الأسهم وTab وCtrl وAlt',
    ),
    RowInfo(
      key: 'numRow',
      title: 'صف الأرقام (Number Row)',
      icon: Icons.numbers,
      color: Colors.green,
      description: 'الأرقام من 0 إلى 9',
    ),
    RowInfo(
      key: 'row1',
      title: 'الصف الأول (Row 1)',
      icon: Icons.keyboard,
      color: Colors.orange,
      description: 'Q W E R T Y U I O P',
    ),
    RowInfo(
      key: 'row2',
      title: 'الصف الثاني (Row 2)',
      icon: Icons.keyboard_alt,
      color: Colors.purple,
      description: 'A S D F G H J K L',
    ),
    RowInfo(
      key: 'row3',
      title: 'الصف الثالث (Row 3)',
      icon: Icons.keyboard_outlined,
      color: Colors.teal,
      description: 'Z X C V B N M',
    ),
    RowInfo(
      key: 'bottomRow',
      title: 'الصف السفلي (Bottom Row)',
      icon: Icons.space_bar,
      color: Colors.red,
      description: 'مفتاح المسافة والنقطة والفاصلة',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('محرر تخطيطات لوحة المفاتيح'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButton<String>(
              value: _selectedLang,
              dropdownColor: Colors.white,
              underline: Container(),
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English 🇺🇸')),
                DropdownMenuItem(value: 'ar', child: Text('العربية 🇸🇦')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedLang = value;
                  });
                }
              },
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _rows.length,
          itemBuilder: (context, index) {
            final row = _rows[index];
            return _buildRowCard(row);
          },
        ),
      ),
    );
  }

  Widget _buildRowCard(RowInfo row) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditRowScreen(
                rowKey: row.key,
                rowTitle: row.title,
                lang: _selectedLang,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                row.color.withOpacity(0.1),
                row.color.withOpacity(0.05),
              ],
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: row.color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  row.icon,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      row.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: row.color,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RowInfo {
  final String key;
  final String title;
  final IconData icon;
  final Color color;
  final String description;

  RowInfo({
    required this.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
  });
}
