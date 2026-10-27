import 'package:flutter/material.dart';
import 'app_ui.dart';
import 'database/database_helper.dart';

class TransactionFilter {
  final String type;
  final int? categoryId;
  final String period;
  const TransactionFilter({this.type = 'Tất cả', this.categoryId, this.period = 'Tất cả'});
  bool accepts(Map<String, Object?> t) {
    if (type != 'Tất cả' && t['type'] != type) return false;
    if (categoryId != null && (t['category_id'] as num).toInt() != categoryId) return false;
    final date = DateTime.tryParse(t['date']?.toString() ?? '');
    if (date == null) return false;
    final now = DateTime.now();
    switch (period) {
      case 'Hôm nay': return date.year == now.year && date.month == now.month && date.day == now.day;
      case '7 ngày qua':
        final start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
        return !date.isBefore(start) && !date.isAfter(now);
      case 'Tháng này': return date.year == now.year && date.month == now.month;
      case 'Tháng trước':
        final prev = DateTime(now.year, now.month - 1);
        return date.year == prev.year && date.month == prev.month;
      default: return true;
    }
  }
}

class FilterScreen extends StatefulWidget {
  final TransactionFilter initial;
  const FilterScreen({super.key, required this.initial});
  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late String _type;
  late String _period;
  int? _categoryId;
  List<Map<String, Object?>> _categories = [];
  @override
  void initState() {
    super.initState();
    _type = widget.initial.type;
    _period = widget.initial.period;
    _categoryId = widget.initial.categoryId;
    _load();
  }
  Future<void> _load() async {
    final db = DatabaseHelper.instance;
    final all = <Map<String, Object?>>[
      ...await db.getCategories('Chi tiêu'), ...await db.getCategories('Thu nhập')];
    if (mounted) setState(() => _categories = all);
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Bộ lọc', style: TextStyle(fontWeight: FontWeight.bold)), centerTitle: true),
    body: SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: ListView(children: [
        const Text('Loại giao dịch', style: TextStyle(fontWeight: FontWeight.bold, color: appInk)),
        for (final t in ['Tất cả', 'Thu nhập', 'Chi tiêu'])
          RadioListTile<String>(title: Text(t), value: t, groupValue: _type,
            activeColor: appBlue, contentPadding: EdgeInsets.zero,
            onChanged: (v) => setState(() { _type = v!; _categoryId = null; })),
        const SizedBox(height: 8),
        const Text('Danh mục', style: TextStyle(fontWeight: FontWeight.bold, color: appInk)),
        const SizedBox(height: 9),
        DropdownButtonFormField<int?>(
          value: _categoryId,
          isExpanded: true,
          decoration: const InputDecoration(border: OutlineInputBorder(), filled: true,
            fillColor: Colors.white),
          items: [const DropdownMenuItem<int?>(value: null, child: Text('Tất cả danh mục')),
            ..._categories.where((c) => _type == 'Tất cả' || c['type'] == _type).map((c) =>
              DropdownMenuItem<int?>(value: (c['id'] as num).toInt(),
                child: Text('${c['name']} (${c['type']})')))],
          onChanged: (v) => setState(() => _categoryId = v),
        ),
        const SizedBox(height: 19),
        const Text('Khoảng thời gian', style: TextStyle(fontWeight: FontWeight.bold, color: appInk)),
        for (final p in ['Hôm nay', '7 ngày qua', 'Tháng này', 'Tháng trước', 'Tất cả'])
          RadioListTile<String>(title: Text(p), value: p, groupValue: _period,
            activeColor: appBlue, contentPadding: EdgeInsets.zero,
            onChanged: (v) => setState(() => _period = v!)),
        ])),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, height: 50, child: ElevatedButton(
          onPressed: () => Navigator.pop(context,
            TransactionFilter(type: _type, categoryId: _categoryId, period: _period)),
          style: ElevatedButton.styleFrom(backgroundColor: appBlue, foregroundColor: Colors.white),
          child: const Text('Áp dụng', style: TextStyle(fontWeight: FontWeight.bold)),
        )),
      ],
    ))),
  );
}
