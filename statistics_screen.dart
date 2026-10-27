import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'app_ui.dart';

class StatisticsScreen extends StatefulWidget {
  final List<Map<String, Object?>> transactions;
  const StatisticsScreen({super.key, required this.transactions});
  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _period = 0;
  bool _income = false;
  bool _withinPeriod(Map<String, Object?> t) {
    final d = DateTime.tryParse(t['date']?.toString() ?? '');
    if (d == null) return false;
    final now = DateTime.now();
    if (_period == 0) return d.year == now.year && d.month == now.month;
    if (_period == 1) {
      final prev = DateTime(now.year, now.month - 1);
      return d.year == prev.year && d.month == prev.month;
    }
    return d.year == now.year;
  }
  @override
  Widget build(BuildContext context) {
    final amounts = <String, int>{};
    for (final t in widget.transactions) {
      if (!_withinPeriod(t) || t['type'] != (_income ? 'Thu nhập' : 'Chi tiêu')) continue;
      final category = (t['category_name'] as String?) ?? 'Khác';
      amounts[category] = (amounts[category] ?? 0) + (t['amount'] as num).toInt();
    }
    final entries = amounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold<int>(0, (sum, e) => sum + e.value);
    return ListView(padding: const EdgeInsets.fromLTRB(16, 17, 16, 100), children: [
      Row(children: [
        for (var i = 0; i < 3; i++) Expanded(child: Padding(
          padding: const EdgeInsets.only(right: 5), child: SizedBox(height: 37, child: ElevatedButton(
            onPressed: () => setState(() => _period = i),
            style: ElevatedButton.styleFrom(
              backgroundColor: _period == i ? appBlue : Colors.white,
              foregroundColor: _period == i ? Colors.white : appInk,
              elevation: _period == i ? 2 : 0,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text(['Tháng này', 'Tháng trước', 'Năm nay'][i],
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          )))),
      ]),
      const SizedBox(height: 22),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        ChoiceChip(label: const Text('Chi tiêu'), selected: !_income, showCheckmark: false,
          onSelected: (_) => setState(() => _income = false)),
        const SizedBox(width: 10),
        ChoiceChip(label: const Text('Thu nhập'), selected: _income, showCheckmark: false,
          onSelected: (_) => setState(() => _income = true)),
      ]),
      const SizedBox(height: 13),
      Center(child: SizedBox(width: 245, height: 245, child: Stack(alignment: Alignment.center, children: [
        CustomPaint(size: const Size(230, 230), painter: _DonutPainter(
          values: entries.map((e) => e.value.toDouble()).toList())),
        Column(mainAxisSize: MainAxisSize.min, children: [
          FittedBox(child: Text(money(total), style: const TextStyle(fontSize: 21,
            fontWeight: FontWeight.w800, color: appInk))),
          const SizedBox(height: 5),
          Text(_income ? 'Tổng thu nhập' : 'Tổng chi tiêu',
            style: const TextStyle(fontSize: 12, color: Color(0xFF9BA6B6))),
        ]),
      ]))),
      const SizedBox(height: 27),
      if (entries.isEmpty)
        const Center(child: Padding(padding: EdgeInsets.all(25),
          child: Text('Chưa có dữ liệu trong khoảng thời gian này',
            style: TextStyle(color: Color(0xFF8792A5)))))
      else
        Container(decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(14)), child: Column(children: [
          for (var i = 0; i < entries.length; i++) ...[
            Padding(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15), child: Row(children: [
              CircleAvatar(radius: 5, backgroundColor: chartColors[i % chartColors.length]),
              const SizedBox(width: 10),
              Expanded(child: Text(entries[i].key, style: const TextStyle(fontSize: 13,
                fontWeight: FontWeight.w600, color: appInk))),
              Text(money(entries[i].value), style: const TextStyle(fontSize: 12,
                fontWeight: FontWeight.bold, color: appInk)),
              const SizedBox(width: 15),
              SizedBox(width: 42, child: Text('${(entries[i].value * 100 / total).round()}%',
                textAlign: TextAlign.right, style: const TextStyle(fontSize: 11,
                  color: Color(0xFF8C98AB)))),
            ])),
            if (i != entries.length - 1) const Divider(height: 1, indent: 14, endIndent: 14),
          ],
        ])),
    ]);
  }
}

class _DonutPainter extends CustomPainter {
  final List<double> values;
  _DonutPainter({required this.values});
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(center: Offset(size.width / 2, size.height / 2),
      radius: math.min(size.width, size.height) / 2 - 14);
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 30;
    final total = values.fold<double>(0, (a, b) => a + b);
    if (total <= 0) {
      paint.color = const Color(0xFFE3EAF5);
      canvas.drawArc(rect, 0, math.pi * 2, false, paint);
      return;
    }
    var start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = values[i] / total * math.pi * 2;
      paint.color = chartColors[i % chartColors.length];
      canvas.drawArc(rect, start + 0.009, math.max(0.0, sweep - 0.018), false, paint);
      start += sweep;
    }
  }
  @override
  bool shouldRepaint(covariant _DonutPainter old) => true;
}
