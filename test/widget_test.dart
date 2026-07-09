import 'package:flutter_test/flutter_test.dart';

import 'functional/helpers/test_app.dart';

void main() {
  testWidgets('shows login screen', (tester) async {
    await tester.pumpSorakApp();

    expect(find.text('Login'), findsWidgets);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
