
import 'package:flutter/material.dart';
import '../models/layout.dart';

class KeyboardPreview extends StatelessWidget {
  final KeyboardLayout layout;
  final double scale;

  const KeyboardPreview({
    Key? key,
    required this.layout,
    this.scale = 0.6,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _buildRows(),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRows() {
    final rows = <Widget>[];
    
    for (var i = 1; i <= layout.rows.length; i++) {
      final rowKey = 'row$i';
      final row = layout.rows[rowKey];
      
      if (row != null) {
        rows.add(_buildRow(row));
        if (i < layout.rows.length) {
          rows.add(const SizedBox(height: 4));
        }
      }
    }
    
    return rows;
  }

  Widget _buildRow(KeyboardRow row) {
    return SizedBox(
      height: row.height.toDouble(),
      child: Row(
        children: row.keys.map((key) => _buildKey(key)).toList(),
      ),
    );
  }

  Widget _buildKey(KeyModel key) {
    return Expanded(
      flex: (key.weight * 10).toInt(),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: _getKeyColor(key.type),
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            _getKeyDisplayText(key),
            style: TextStyle(
              color: Colors.white,
              fontSize: _getKeyFontSize(key),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  String _getKeyDisplayText(KeyModel key) {
    if (key.text.isEmpty) {
      switch (key.type) {
        case 'space':
          return '␣';
        case 'delete':
          return '⌫';
        case 'emoji':
          return '😀';
        case 'clip':
          return '📋';
        default:
          return '?';
      }
    }
    return key.text;
  }

  double _getKeyFontSize(KeyModel key) {
    if (key.type == 'space') return 10;
    if (key.text.length > 5) return 8;
    if (key.text.length > 3) return 10;
    return 12;
  }

  Color _getKeyColor(String type) {
    final colors = {
      'letter': Colors.blue[400]!,
      'specialKey': Colors.purple[400]!,
      'normal': Colors.teal[400]!,
      'loopKey': Colors.orange[400]!,
      'space': Colors.green[400]!,
      'delete': Colors.red[400]!,
      'emoji': Colors.pink[400]!,
      'symbols': Colors.indigo[400]!,
      'clip': Colors.brown[400]!,
    };
    return colors[type] ?? Colors.grey[400]!;
  }
}
