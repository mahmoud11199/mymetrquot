import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mymetrquot/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const storageChannel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final storage = <String, String>{};

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    dotenv.testLoad(fileInput: 'API_BASE_URL=https://example.com/backend');
  });

  setUp(() {
    storage.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storageChannel, (MethodCall call) async {
      final arguments = (call.arguments as Map<dynamic, dynamic>? ?? <dynamic, dynamic>{});
      final key = arguments['key'] as String?;

      switch (call.method) {
        case 'write':
          if (key != null) {
            storage[key] = (arguments['value'] ?? '').toString();
          }
          return null;
        case 'read':
          return key == null ? null : storage[key];
        case 'delete':
          if (key != null) {
            storage.remove(key);
          }
          return null;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storageChannel, null);
  });

  testWidgets('auth screen shows onboarding and auth actions', (tester) async {
    await tester.pumpWidget(const MyMetrQuotApp());
    await tester.pump();

    expect(find.text('Welcome to mymetrquot'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
    expect(find.text('Select role'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });
}
