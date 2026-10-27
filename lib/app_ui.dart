import 'package:flutter/material.dart';

const appBlue = Color(0xFF1769EA);
const appInk = Color(0xFF192849);
const appGreen = Color(0xFF27B24C);
const appRed = Color(0xFFFF4F63);
const appBg = Color(0xFFF6F8FD);
const chartColors = [Color(0xFFFF405C), Color(0xFF8848FF), Color(0xFF1EAAEF),
  Color(0xFF25BFA6), Color(0xFFF7A83E), Color(0xFF4F65FF), Color(0xFFE948B7)];

String money(num value) {
  final n = value.toInt();
  final digits = n.abs().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.');
  return '${n < 0 ? '-' : ''}$digits đ';
}
String prettyDate(Object? value) {
  final d = DateTime.tryParse(value?.toString() ?? '');
  if (d == null) return value?.toString() ?? '';
  return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
IconData categoryIcon(String name) {
  switch (name) {
    case 'Ăn uống': return Icons.restaurant;
    case 'Mua sắm': return Icons.shopping_cart;
    case 'Di chuyển': return Icons.directions_car;
    case 'Giải trí': return Icons.movie;
    case 'Học phí': return Icons.school;
    case 'Lương': return Icons.savings;
    case 'Thưởng': return Icons.workspace_premium;
    case 'Làm thêm': return Icons.work_outline;
    case 'Hóa đơn': return Icons.receipt_long;
    default: return Icons.category;
  }
}
Color categoryColor(String name) {
  switch (name) {
    case 'Ăn uống': return const Color(0xFFFF792D);
    case 'Di chuyển': return const Color(0xFF2196F3);
    case 'Mua sắm': return const Color(0xFF9D48E9);
    case 'Học phí': return const Color(0xFF009C93);
    case 'Lương': return const Color(0xFF28A745);
    case 'Làm thêm': return const Color(0xFF2FAE70);
    default: return appBlue;
  }
}

class TransactionTile extends StatelessWidget {
  final Map<String, Object?> item;
  final VoidCallback onTap;
  const TransactionTile({super.key, required this.item, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final income = item['type'] == 'Thu nhập';
    final category = (item['category_name'] as String?) ?? 'Khác';
    final note = (item['note'] as String?)?.trim() ?? '';
    final amount = (item['amount'] as num).toInt();
    return Material(color: Colors.white, child: InkWell(
      onTap: onTap,
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13), child: Row(children: [
        CircleAvatar(radius: 21, backgroundColor: categoryColor(category),
          child: Icon(categoryIcon(category), color: Colors.white, size: 22)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(note.isEmpty ? category : note, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: appInk)),
          const SizedBox(height: 5),
          Text('$category  ·  ${prettyDate(item['date'])}', maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF9AA5B6), fontSize: 10)),
        ])),
        const SizedBox(width: 5),
        Text('${income ? '+' : '-'}${money(amount)}',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
            color: income ? appGreen : appRed)),
      ])),
    ));
  }
}

Widget emptyTransactions() => const Padding(
  padding: EdgeInsets.symmetric(vertical: 48),
  child: Column(children: [Icon(Icons.receipt_long_outlined, size: 52, color: Color(0xFFAAB7CB)),
    SizedBox(height: 10), Text('Chưa có giao dịch nào', style: TextStyle(color: Color(0xFF8492A7)))]),
);
