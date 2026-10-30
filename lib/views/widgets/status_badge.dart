import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final int? statusCode;
  final String? statusPhrase;
  final bool isLoading;

  const StatusBadge({
    super.key,
    required this.statusCode,
    this.statusPhrase,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'IN FLIGHT...',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
          ],
        ),
      );
    }

    if (statusCode == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 14, color: Colors.grey.shade800),
            const SizedBox(width: 4),
            Text(
              'NO RESPONSE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      );
    }

    final code = statusCode!;
    final Color bgColor;
    final Color textColor;
    final Color borderColor;
    final IconData icon;

    if (code >= 200 && code < 300) {
      // 2xx Success: Emerald
      bgColor = const Color(0xFFE8F5E9);
      textColor = const Color(0xFF1B5E20);
      borderColor = const Color(0xFF81C784);
      icon = Icons.check_circle_outline;
    } else if (code >= 300 && code < 400) {
      // 3xx Redirection: Cyan / Blue
      bgColor = const Color(0xFFE0F7FA);
      textColor = const Color(0xFF006064);
      borderColor = const Color(0xFF4DD0E1);
      icon = Icons.alt_route;
    } else if (code >= 400 && code < 500) {
      // 4xx Client Error: Amber / Orange
      bgColor = const Color(0xFFFFF3E0);
      textColor = const Color(0xFFE65100);
      borderColor = const Color(0xFFFFB74D);
      icon = Icons.warning_amber_rounded;
    } else {
      // 5xx Server Error: Red
      bgColor = const Color(0xFFFFEBEE);
      textColor = const Color(0xFFB71C1C);
      borderColor = const Color(0xFFE57373);
      icon = Icons.error_outline;
    }

    final displayText = statusPhrase != null && statusPhrase!.isNotEmpty
        ? '$code $statusPhrase'
        : '$code';

    return Semantics(
      label: 'HTTP status $displayText',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 6),
            Text(
              displayText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
