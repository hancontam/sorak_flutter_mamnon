import 'package:flutter_test/flutter_test.dart';

import 'functional/helpers/test_app.dart';

void main() {
  testWidgets('shows login screen', (tester) async {
    await tester.pumpSorakApp();

    expect(find.text('Sorak Mầm non'), findsOneWidget);
    expect(find.text('Phụ huynh'), findsOneWidget);
    expect(find.text('Cán bộ'), findsOneWidget);
    expect(find.text('Mã thẻ học sinh'), findsOneWidget);
    expect(find.text('Mật khẩu'), findsOneWidget);
  });
}
