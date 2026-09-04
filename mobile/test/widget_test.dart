import 'package:carcare_mobile/core/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('StatusBadge displays label and dot indicator', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatusBadge(
            label: 'ACTIVE',
            color: Colors.green,
            showDot: true,
          ),
        ),
      ),
    );

    expect(find.text('ACTIVE'), findsOneWidget);
  });

  testWidgets('LicensePlateBadge displays plate text', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LicensePlateBadge(plate: '1234-AB-16'),
        ),
      ),
    );

    expect(find.text('1234-AB-16'), findsOneWidget);
  });
}