import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class JsonViewer extends StatelessWidget {
  final String jsonString;
  final String title;

  const JsonViewer({
    super.key,
    required this.jsonString,
    this.title = 'Payload / Body',
  });

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: jsonString));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('JSON copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E), // Modern dark code background
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueGrey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF181825),
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.code, size: 16, color: Color(0xFF89B4FA)),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFFCDD6F4),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 16, color: Color(0xFFA6ADC8)),
                  tooltip: 'Copy JSON',
                  onPressed: () => _copyToClipboard(context),
                  constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableText(
                jsonString,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Color(0xFFA6E3A1), // soft code green
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
