import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sorak_flutter_mamnon/core/theme/app_theme.dart';
import 'package:sorak_flutter_mamnon/core/widgets/app_shell.dart';
import 'package:sorak_flutter_mamnon/core/widgets/empty_view.dart';
import 'package:sorak_flutter_mamnon/core/widgets/error_view.dart';

import 'helpers/test_app.dart';

void main() {
  group('Goal 50 UI/UX hardening', () {
    testWidgets(
      'shared states are Vietnamese, semantic and usable at 2x text',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(360, 640));
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(() {
          tester.binding.setSurfaceSize(null);
          tester.platformDispatcher.clearTextScaleFactorTestValue();
        });

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: ErrorView(
                message: 'Máy chủ tạm thời không phản hồi. Mã: TRACE-50',
                onRetry: () {},
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.byKey(const ValueKey('error_state')), findsOneWidget);
        expect(find.text('Không thể tải dữ liệu'), findsOneWidget);
        expect(find.text('Thử lại'), findsOneWidget);
        expect(
          tester
              .getSize(find.byKey(const ValueKey('error_retry_button')))
              .height,
          greaterThanOrEqualTo(48),
        );
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(
              body: EmptyView(
                title: 'Backend chưa hỗ trợ',
                message: 'Dữ liệu này chưa có trong phạm vi hiện tại.',
                type: EmptyViewType.unsupported,
              ),
            ),
          ),
        );
        await tester.pump();

        expect(
          find.byKey(const ValueKey('empty_state_unsupported')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('health quick entry guards dirty data and keeps save visible', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(360, 640));
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(() {
        tester.binding.setSurfaceSize(null);
        tester.platformDispatcher.clearTextScaleFactorTestValue();
      });

      await tester.pumpLoggedInSorakApp();
      final shellContext = tester.element(find.byType(AppShell));
      Navigator.of(shellContext).pushNamed('/health');
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mầm 1A - A101').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nguyễn Minh An').first);
      await tester.pumpAndSettle();

      final saveFinder = find.byKey(const Key('health_roster_save_button'));
      expect(saveFinder, findsOneWidget);
      expect(tester.widget<FilledButton>(saveFinder).onPressed, isNull);
      expect(tester.getBottomRight(saveFinder).dy, lessThanOrEqualTo(640));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nhập chiều cao'),
        '104',
      );
      await tester.pump();
      // Height-only still enables save so the sheet can show a clear error
      // about missing weight (backend requires both measures).
      expect(tester.widget<FilledButton>(saveFinder).onPressed, isNotNull);
      expect(
        find.textContaining('chiều cao và cân nặng'),
        findsWidgets,
      );

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Bỏ thay đổi?'), findsOneWidget);

      await tester.tap(find.text('Tiếp tục nhập'));
      await tester.pumpAndSettle();
      // Sheet stays open — student name is the sheet title.
      expect(find.text('Lưu sức khỏe'), findsOneWidget);
      expect(find.text('Nguyễn Minh An'), findsWidgets);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('discard_health_changes_button')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Lưu sức khỏe'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
