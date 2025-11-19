import 'package:flutter/material.dart';

class ApplicationStatsCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const ApplicationStatsCard({
    Key? key,
    required this.title,
    required this.count,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getIcon(),
                    color: color,
                    size: 20,
                  ),
                ),
                const Spacer(),
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon() {
    if (title.toLowerCase().contains('total')) {
      return Icons.assignment;
    } else if (title.toLowerCase().contains('pending')) {
      return Icons.pending;
    } else if (title.toLowerCase().contains('accepted')) {
      return Icons.check_circle;
    } else if (title.toLowerCase().contains('rejected')) {
      return Icons.cancel;
    } else if (title.toLowerCase().contains('review')) {
      return Icons.visibility;
    }
    return Icons.assignment;
  }
}