import 'package:flutter_test/flutter_test.dart';
import 'package:aspen_house_finder/main.dart';

void main() {
  testWidgets('Aspen house finder shows Vietnamese discovery content and navigation', (tester) async {
    await tester.pumpWidget(const AspenApp());
    await tester.pump();

    // Verify main navigation destinations
    expect(find.text('Khám phá'), findsWidgets);
    expect(find.text('Đã lưu'), findsOneWidget);
    expect(find.text('Lịch hẹn'), findsOneWidget);
    expect(find.text('Tin nhắn'), findsOneWidget);
    expect(find.text('Tài khoản'), findsOneWidget);

    // Verify header and search
    expect(find.text('Tìm phòng trọ'), findsOneWidget);
  });

  testWidgets('Tapping "Xem tất cả" navigates to AllListingsPage without overflow', (tester) async {
    await tester.pumpWidget(const AspenApp());
    await tester.pump();

    // Find the 'Xem tất cả' buttons
    final seeAllButtons = find.text('Xem tất cả');
    expect(seeAllButtons, findsWidgets);

    // Tap the first 'Xem tất cả' button
    await tester.tap(seeAllButtons.first);
    await tester.pumpAndSettle();

    // Verify AllListingsPage opened
    expect(find.text('Phòng nổi bật gần bạn'), findsOneWidget);
    expect(find.textContaining('Hiển thị'), findsOneWidget);
  });
}
