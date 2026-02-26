import 'package:flutter_test/flutter_test.dart';

import 'package:mymetrquot/main.dart';

void main() {
  testWidgets('meter screen shows core controls and values', (tester) async {
    await tester.pumpWidget(const TaxiMeterApp());

    expect(find.text('Digital Taxi Meter'), findsOneWidget);
    expect(find.text('10.00 EGP'), findsOneWidget);
    expect(find.text('Elapsed Time'), findsOneWidget);
    expect(find.text('Distance'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Pause'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);
  });
}
