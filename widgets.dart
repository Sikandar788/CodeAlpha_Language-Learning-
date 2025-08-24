import 'package:flutter/material.dart';

class ProgressCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double percent;
  final int count;
  final int target;

  const ProgressCard({super.key, required this.title, required this.subtitle, required this.percent, required this.count, required this.target});

  @override
  Widget build(BuildContext context) {
    final percentText = (percent * 100).toInt();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white, Colors.teal.shade50]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 6))],
      ),
      child: Row(children: [
        SizedBox(
          width: 84,
          height: 84,
          child: Stack(alignment: Alignment.center, children: [
            CircularProgressIndicator(value: percent, strokeWidth: 8),
            Column(mainAxisSize: MainAxisSize.min, children: [Text('$percentText%', style: const TextStyle(fontWeight: FontWeight.bold)), Text('$count/$target', style: const TextStyle(fontSize: 12, color: Colors.grey))])
          ]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 6), Text(subtitle, style: const TextStyle(color: Colors.grey))]),
        )
      ]),
    );
  }
}
