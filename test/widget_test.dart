import 'package:evacuation_center_locator/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the locator title and sample centers', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const EvacuationLocatorApp(forceMapsSetupNotice: true),
    );

    expect(find.text('Cabadbaran Evacuation Locator'), findsOneWidget);
    expect(find.text('10 evacuation centers'), findsOneWidget);
    expect(find.text('Cabadbaran Municipal Evacuation Center'), findsOneWidget);
  });

  testWidgets('filters centers by search text', (WidgetTester tester) async {
    await tester.pumpWidget(
      const EvacuationLocatorApp(forceMapsSetupNotice: true),
    );

    await tester.enterText(find.byType(TextField), 'Bongan');
    await tester.pump();

    expect(find.text('1 evacuation center'), findsOneWidget);
    expect(find.text('Bongan Elementary School Center'), findsOneWidget);
  });
}
