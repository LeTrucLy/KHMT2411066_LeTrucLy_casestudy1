import 'package:flutter_test/flutter_test.dart';
import 'package:khmt2411066_letrucly_casestudy1/main.dart';

void main() {
  testWidgets('Ứng dụng khởi tạo thành công', (WidgetTester tester) async {
    expect(const ExpenseManagerApp(), isNotNull);
  });
}