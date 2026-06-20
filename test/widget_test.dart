import 'package:flutter_test/flutter_test.dart';
import 'package:scientific_matrix_calculator/main.dart';

void main() {
  testWidgets('Smoke test for Scientific Matrix Calculator App', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ScientificMatrixCalculatorApp());

    // Verify that the calculator screen is loaded and shows '0' as default input.
    expect(find.text('0'), findsWidgets);
  });
}
