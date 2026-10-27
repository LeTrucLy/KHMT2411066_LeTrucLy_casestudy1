import 'package:flutter/material.dart';
import 'app_ui.dart';
import 'filter_screen.dart';

class TransactionListScreen extends StatefulWidget {
  final List<Map<String, Object?>> transactions;
  final Future<void> Function(int) onEdit;
  const TransactionListScreen({super.key, required this.transactions, required this.onEdit});
  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}
class _TransactionListScreenState extends State<TransactionListScreen> {
  String _search = '';
  String _quickType = 'Tất cả';
  TransactionFilter _filter = const TransactionFilter();
  @override
  Widget build(BuildContext context) {
    final filtered = widget.transactions.where((t) {
      if (_quickType != 'Tất cả' && t['type'] != _quickType) return false;
      if (!_filter.accepts(t)) return false;
      final q = _search.toLowerCase();
      return '${t['category_name']} ${t['note']} ${t['amount']}'.toLowerCase().contains(q);
    }).toList();
    return Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 9), child: Row(children: [
        Expanded(child: TextField(onChanged: (v) => setState(() => _search = v),
          decoration: InputDecoration(hintText: 'Tìm kiếm giao dịch...',
            prefixIcon: const Icon(Icons.search), filled: true, fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)))),
        const SizedBox(width: 8),
        IconButton.filledTonal(tooltip: 'Bộ lọc', icon: const Icon(Icons.tune),
          onPressed: () async {
            final result = await Navigator.push<TransactionFilter>(context,
              MaterialPageRoute(builder: (_) => FilterScreen(initial: _filter)));
            if (result != null && mounted) setState(() => _filter = result);
          }),
      ])),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [
        for (final t in ['Tất cả', 'Thu nhập', 'Chi tiêu'])
          Expanded(child: Padding(padding: const EdgeInsets.only(right: 5), child:
            ChoiceChip(label: Text(t, style: const TextStyle(fontSize: 12)),
              selected: _quickType == t, showCheckmark: false,
              selectedColor: const Color(0xFFE3EEFF),
              onSelected: (_) => setState(() => _quickType = t)))),
      ])),
      Expanded(child: filtered.isEmpty ? Center(child: emptyTransactions()) :
        ListView(padding: const EdgeInsets.fromLTRB(16, 10, 16, 90), children: [
          ClipRRect(borderRadius: BorderRadius.circular(14), child: Column(children: [
            for (var i = 0; i < filtered.length; i++) ...[
              TransactionTile(item: filtered[i],
                onTap: () => widget.onEdit((filtered[i]['id'] as num).toInt())),
              if (i < filtered.length - 1) const Divider(height: 1, indent: 62),
            ],
          ])),
        ])),
    ]);
  }
}
