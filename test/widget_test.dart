import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scientific_matrix_calculator/main.dart';
import 'package:scientific_matrix_calculator/screens/home_screen.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('Smoke test for Scientific Matrix Calculator App Splash', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ScientificMatrixCalculatorApp());
    // Advance past splash screen delay (2.8s + transitions)
    await tester.pump(const Duration(seconds: 4));

    // Verify that the splash screen title loads
    expect(find.text('Calculadora '), findsOneWidget);
  });

  testWidgets('Smoke test for HomeScreen including Accounting suite', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );
    await tester.pump();

    // Verify header and new Contable tab
    expect(find.text('Calculadora '), findsOneWidget);
    expect(find.text('Contable'), findsWidgets);
  });
}
