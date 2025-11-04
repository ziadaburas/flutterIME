// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// تعريف الـ MethodChannel للتواصل مع الكود الأصلي
const platform = MethodChannel('com.example.flutter_keyboard/keyboard');

void main() {
  runApp(const KeyboardApp());
}

class KeyboardApp extends StatelessWidget {
  const KeyboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: KeyboardView(),
    );
  }
}

class KeyboardView extends StatelessWidget {
  const KeyboardView({super.key});
  
  // دالة لإرسال النص إلى خدمة Kotlin
  void sendTextToNative(String text) {
    try {
    
      platform.invokeMethod('handleInput', {'text': text});
    } on PlatformException catch (e) {
      print("Failed to send text: '${e.message}'.");
    }
  }

  // دالة لإرسال أمر الحذف إلى خدمة Kotlin
  void sendDeleteToNative() {
    try {
      platform.invokeMethod('handleDelete');
    } on PlatformException catch (e) {
      print("Failed to send delete command: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Expanded(
              flex: 2,
              child: GridView.count(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                padding: const EdgeInsets.all(8),
                children: [
                  _buildKey('أ'),
                  _buildKey('ب'),
                  _buildKey('ت'),
                  _buildKey('ث'),
                  _buildKey('ج'),
                  _buildKey('ح'),
                  _buildKey('خ'),
                  _buildKey('د'),
                  _buildKey('ذ'),
                  _buildKey('ر'),
                  _buildKey('ز'),
                  _buildKey('س'),
                  _buildKey('ش'),
                  _buildKey('ص'),
                  _buildKey('ض'),
                  _buildKey('ط'),
                  _buildKey('ظ'),
                  _buildKey('ع'),
                  _buildKey('غ'),
                  _buildKey('ف'),
                  _buildKey('ق'),
                  _buildKey('ك'),
                  _buildKey('ل'),
                  _buildKey('م'),
                  _buildKey('ن'),
                  _buildKey('ه'),
                  _buildKey('و'),
                  _buildKey('ي'),
                  _buildKey(' '),
                  _buildDeleteKey(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKey(String text) {
    return ElevatedButton(
      onPressed: () => sendTextToNative(text),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white,
      ),
      child: Text(text, style: const TextStyle(fontSize: 24, color: Colors.black)),
    );
  }

  Widget _buildDeleteKey() {
    return ElevatedButton(
      onPressed: sendDeleteToNative,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.red[400],
      ),
      child: const Icon(Icons.backspace, color: Colors.white),
    );
  }
}
