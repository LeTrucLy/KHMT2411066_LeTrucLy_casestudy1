
import 'package:flutter/material.dart';
import 'transaction_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const blue = Color(0xFF2167E8);
  static const navy = Color(0xFF172747);
  static const red = Color(0xFFFF626A);
  static const green = Color(0xFF28A66A);

  String formatMoney(int amount) {
    final digits = amount.abs().toString();
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[i]);
    }

    return '${buffer.toString()} đ';
  }

  void openTransaction(BuildContext context, bool isEdit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionScreen(isEdit: isEdit),
      ),
    );
  }

  Widget summaryCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5EAF2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 25),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 7),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                amount,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget transactionItem({
    required String name,
    required String category,
    required int amount,
    required bool isExpense,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isExpense
                  ? const Color(0xFFFFEEF0)
                  : const Color(0xFFE9F8EF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isExpense ? red : green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: navy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isExpense ? '-' : '+'}${formatMoney(amount)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isExpense ? red : green,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dữ liệu minh họa cho buổi 4.
    const income = 2500000;
    const expense = 180000;
    const balance = income - expense;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: navy,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tổng quan tài chính',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: navy,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Theo dõi thu nhập và chi tiêu cá nhân',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 22),

              // Tổng số dư
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(23),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF1976D2),
                      Color(0xFF173F85),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tổng số dư',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      formatMoney(balance),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 29,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Dữ liệu minh họa - Buổi 4',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Tổng thu và tổng chi
              Row(
                children: [
                  summaryCard(
                    title: 'Thu nhập',
                    amount: formatMoney(income),
                    icon: Icons.arrow_downward,
                    color: green,
                  ),
                  const SizedBox(width: 12),
                  summaryCard(
                    title: 'Chi tiêu',
                    amount: formatMoney(expense),
                    icon: Icons.arrow_upward,
                    color: red,
                  ),
                ],
              ),

              const SizedBox(height: 28),

              const Text(
                'Giao dịch gần đây',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: navy,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Danh sách giao dịch mẫu',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    transactionItem(
                      name: 'Ăn trưa',
                      category: 'Ăn uống',
                      amount: 100000,
                      isExpense: true,
                      icon: Icons.restaurant,
                    ),
                    const Divider(),
                    transactionItem(
                      name: 'Lương làm thêm',
                      category: 'Thu nhập',
                      amount: 2500000,
                      isExpense: false,
                      icon: Icons.work_outline,
                    ),
                    const Divider(),
                    transactionItem(
                      name: 'Cà phê',
                      category: 'Ăn uống',
                      amount: 80000,
                      isExpense: true,
                      icon: Icons.local_cafe,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Mở màn hình thêm giao dịch
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => openTransaction(context, false),
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm giao dịch'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Mở màn hình sửa mẫu của buổi 3
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () => openTransaction(context, true),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: blue,
                    side: const BorderSide(color: blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Xem màn hình sửa giao dịch'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
