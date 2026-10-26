
import 'package:flutter/material.dart';

class TransactionScreen extends StatefulWidget {
  final bool isEdit;

  const TransactionScreen({
    super.key,
    this.isEdit = false,
  });

  @override
  State<TransactionScreen> createState() =>
      _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  bool isExpense = true;
  String category = 'Ăn uống';

  late TextEditingController amountController;
  late TextEditingController noteController;

  DateTime selectedDate = DateTime(2025, 4, 12);

  final Color blue = const Color(0xFF2167E8);
  final Color red = const Color(0xFFFF626A);

  final categories = [
    'Ăn uống',
    'Mua sắm',
    'Di chuyển',
    'Giải trí',
    'Khác',
  ];

  @override
  void initState() {
    super.initState();

    amountController = TextEditingController(
      text: widget.isEdit ? '100000' : '',
    );

    noteController = TextEditingController(
      text: widget.isEdit ? 'Ăn trưa' : '',
    );
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> chooseDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() => selectedDate = date);
    }
  }

  String get formattedDate {
    return '${selectedDate.day.toString().padLeft(2, '0')}/'
        '${selectedDate.month.toString().padLeft(2, '0')}/'
        '${selectedDate.year}';
  }

  Widget fieldTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 20,
        bottom: 9,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF172747),
        ),
      ),
    );
  }

  InputDecoration inputDecoration({
    String? hint,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      suffixIcon: suffix,
      hintStyle: const TextStyle(
        color: Colors.grey,
        fontSize: 14,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 15,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: Color(0xFFD5DDEB),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: BorderSide(color: blue),
      ),
    );
  }

  Widget typeButton(String text, bool selected) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            isExpense = text == 'Chi tiêu';
          });
        },
        child: Container(
          height: 45,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? red : Colors.white,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: selected
                  ? red
                  : const Color(0xFFD5DDEB),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: selected
                  ? Colors.white
                  : const Color(0xFF172747),
            ),
          ),
        ),
      ),
    );
  }

  void saveTransaction() {
    final amount = double.tryParse(
      amountController.text
          .replaceAll('.', '')
          .replaceAll(',', ''),
    );

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập số tiền hợp lệ'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isEdit
              ? 'Cập nhật giao dịch thành công!'
              : 'Thêm giao dịch thành công!',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.isEdit
              ? 'Sửa giao dịch'
              : 'Thêm giao dịch',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF172747),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          typeButton(
                            'Chi tiêu',
                            isExpense,
                          ),
                          const SizedBox(width: 8),
                          typeButton(
                            'Thu nhập',
                            !isExpense,
                          ),
                        ],
                      ),

                      fieldTitle('Danh mục'),
                      DropdownButtonFormField<String>(
                        initialValue: category,
                        decoration: inputDecoration(),
                        items: categories.map((item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.restaurant,
                                  color: Color(0xFFFF626A),
                                  size: 19,
                                ),
                                const SizedBox(width: 10),
                                Text(item),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => category = value);
                          }
                        },
                      ),

                      fieldTitle('Số tiền'),
                      TextField(
                        controller: amountController,
                        keyboardType:
                        TextInputType.number,
                        decoration: inputDecoration(
                          hint: 'Nhập số tiền',
                          suffix: const Padding(
                            padding: EdgeInsets.all(14),
                            child: Text('đ'),
                          ),
                        ),
                      ),

                      fieldTitle('Ngày giao dịch'),
                      InkWell(
                        onTap: chooseDate,
                        child: InputDecorator(
                          decoration: inputDecoration(
                            suffix: const Icon(
                              Icons.calendar_month_outlined,
                            ),
                          ),
                          child: Text(
                            formattedDate,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      fieldTitle('Ghi chú'),
                      TextField(
                        controller: noteController,
                        maxLines: 3,
                        decoration: inputDecoration(
                          hint: 'Nhập ghi chú (tùy chọn)',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: saveTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(9),
                    ),
                  ),
                  child: const Text(
                    'Lưu',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
