import 'package:flutter_test/flutter_test.dart';

import 'package:mymetrquot/main.dart';

void main() {
  testWidgets('auth screen shows onboarding and auth actions', (tester) async {
    await tester.pumpWidget(const MyMetrQuotApp());

    expect(find.text('Welcome to mymetrquot'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
    expect(find.text('Select role'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });
}
