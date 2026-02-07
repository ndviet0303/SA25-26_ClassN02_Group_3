// Chạy: flutter drive --driver=test_driver/integration_test.dart --target=integration_test/screenshot_screens_test.dart
// (Cần có test_driver/integration_test.dart; xem SCREENSHOTS.md)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:movie_fe/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Screenshot screens', () {
    testWidgets('01_welcome', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 4));
      final binding = tester.binding;
      if (binding is IntegrationTestWidgetsFlutterBinding) {
        await binding.takeScreenshot('01_welcome');
      }
    });

    // Mở rộng: thêm testWidgets cho từng màn, ví dụ:
    // testWidgets('02_login', (tester) async {
    //   app.main();
    //   await tester.pumpAndSettle(const Duration(seconds: 3));
    //   await tester.tap(find.bySemanticsLabel('Đăng nhập')); // hoặc find.text('...')
    //   await tester.pumpAndSettle();
    //   (tester.binding as IntegrationTestWidgetsFlutterBinding).takeScreenshot('02_login');
    // });
  });
}
