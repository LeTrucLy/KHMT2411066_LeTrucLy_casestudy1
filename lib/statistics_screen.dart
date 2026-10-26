
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'database/database_helper.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String selectedPeriod = 'Tháng này';

  final List<Color> chartColors = [
    const Color(0xFFE90062),
    const Color(0xFF6444F5),
    const Color(0xFF0865F5),
    const Color(0xFF08B69B),
    const Color(0xFF8295CE),
    const Color(0xFFFF9D94),
    Colors.orange,
    Colors.brown,
  ];

  late Future<List<Map<String, Object?>>> transactionsFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    transactionsFuture = DatabaseHelper.instance.getTransactions();
  }

  String money(num value) {
    return value.toInt().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => '.',
    );
  }

  bool isInPeriod(DateTime date) {
    final now = DateTime.now();

    if (selectedPeriod == 'Tháng này') {
      return date.month == now.month && date.year == now.year;
    }

    if (selectedPeriod == 'Tháng trước') {
      final previous = DateTime(now.year, now.month - 1);
      return date.month == previous.month &&
          date.year == previous.year;
    }

    return date.year == now.year;
  }

  Widget periodButton(String title) {
    final selected = selectedPeriod == title;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: ElevatedButton(
          onPressed: () {
            setState(() => selectedPeriod = title);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor:
            selected ? const Color(0xFF1265F2) : Colors.white,
            foregroundColor:
            selected ? Colors.white : const Color(0xFF253653),
            elevation: selected ? 2 : 0,
            padding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        title: const Text(
          'Thống kê',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF172B50),
          ),
        ),
        centerTitle: false,
        backgroundColor: const Color(0xFFF5F7FF),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(_refresh);
          await transactionsFuture;
        },
        child: FutureBuilder<List<Map<String, Object?>>>(
          future: transactionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Lỗi tải dữ liệu: ${snapshot.error}'),
              );
            }

            final transactions = snapshot.data ?? [];
            final Map<String, double> totals = {};

            for (final transaction in transactions) {
              if (transaction['type'] != 'Chi tiêu') continue;

              final date = DateTime.tryParse(
                transaction['date'].toString(),
              );

              if (date == null || !isInPeriod(date)) continue;

              final name =
                  transaction['category_name']?.toString() ?? 'Khác';

              final amount =
              (transaction['amount'] as num).toDouble();

              totals[name] = (totals[name] ?? 0) + amount;
            }

            final entries = totals.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

            final total = entries.fold<double>(
              0,
                  (sum, item) => sum + item.value,
            );

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  children: [
                    periodButton('Tháng này'),
                    periodButton('Tháng trước'),
                    periodButton('Năm nay'),
                  ],
                ),

                const SizedBox(height: 28),

                // BIỂU ĐỒ TRÒN
                SizedBox(
                  height: 300,
                  child: total == 0
                      ? const Center(
                    child: Text(
                      'Chưa có dữ liệu chi tiêu',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                      : Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          startDegreeOffset: -90,
                          centerSpaceRadius: 82,
                          sectionsSpace: 2,
                          sections: List.generate(
                            entries.length,
                                (index) {
                              final item = entries[index];

                              return PieChartSectionData(
                                value: item.value,
                                color: chartColors[
                                index % chartColors.length],
                                radius: 42,
                                showTitle: false,
                              );
                            },
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${money(total)} đ',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF172B50),
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Tổng chi tiêu',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // DANH SÁCH DANH MỤC
                ...List.generate(entries.length, (index) {
                  final item = entries[index];
                  final percent = item.value / total * 100;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 13,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 13,
                          height: 13,
                          decoration: BoxDecoration(
                            color: chartColors[
                            index % chartColors.length],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.key,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          '${money(item.value)} đ',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF172B50),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 45,
                          child: Text(
                            '${percent.toStringAsFixed(0)}%',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}
