import 'package:flutter_test/flutter_test.dart';
import 'package:aspen_house_finder/main.dart';
import 'package:aspen_house_finder/data/auth_repository.dart';

void main() {
  testWidgets('Initial screen shows Login/Register first', (tester) async {
    await AuthRepository().logout();
    await tester.pumpWidget(const AspenApp());
    await tester.pump();

    // Verify Login/Register screen is shown first
    expect(find.text('House Finding System'), findsOneWidget);
    expect(find.text('Đăng nhập'), findsWidgets);
    expect(find.text('Đăng ký'), findsOneWidget);

    // Verify role quick-login buttons
    expect(find.text('Finder'), findsOneWidget);
    expect(find.text('Owner'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
    expect(find.text('Duyệt xem phòng với tư cách Khách (Guest)'), findsOneWidget);
  });

  testWidgets('Finder login opens FinderMainShell and navigation', (tester) async {
    await AuthRepository().logout();
    await tester.pumpWidget(const AspenApp());
    await tester.pump();

    // Tap Finder quick login
    await tester.tap(find.text('Finder'));
    await tester.pumpAndSettle();

    // Verify Finder destinations
    expect(find.text('Khám phá'), findsWidgets);
    expect(find.text('Đã lưu'), findsOneWidget);
    expect(find.text('Lịch hẹn'), findsOneWidget);
    expect(find.text('Tin nhắn'), findsOneWidget);
    expect(find.text('Tài khoản'), findsOneWidget);

    // Verify 'Xem tất cả' button navigates to AllListingsPage
    final seeAll = find.text('Xem tất cả');
    expect(seeAll, findsWidgets);
    await tester.tap(seeAll.first);
    await tester.pumpAndSettle();
    expect(find.text('Phòng nổi bật gần bạn'), findsOneWidget);
  });

  testWidgets('Owner login opens OwnerMainShell', (tester) async {
    await AuthRepository().logout();
    await tester.pumpWidget(const AspenApp());
    await tester.pump();

    // Tap Owner quick login
    await tester.tap(find.text('Owner'));
    await tester.pumpAndSettle();

    // Verify Owner destinations
    expect(find.text('Tin đăng của tôi'), findsOneWidget);
    expect(find.text('Đăng tin mới'), findsOneWidget);
    expect(find.text('Duyệt lịch hẹn'), findsOneWidget);
    expect(find.text('Chủ trọ'), findsOneWidget);
  });

  testWidgets('Admin login opens AdminMainShell', (tester) async {
    await AuthRepository().logout();
    await tester.pumpWidget(const AspenApp());
    await tester.pump();

    // Tap Admin quick login
    await tester.tap(find.text('Admin'));
    await tester.pumpAndSettle();

    // Verify Admin destinations
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Kiểm duyệt tin'), findsOneWidget);
    expect(find.text('Người dùng & Admin'), findsOneWidget);
  });

  testWidgets('Guest login opens Guest flow with login prompt on restricted tabs', (tester) async {
    await AuthRepository().logout();
    await tester.pumpWidget(const AspenApp());
    await tester.pump();

    // Tap Guest browse button
    final guestBtn = find.text('Duyệt xem phòng với tư cách Khách (Guest)');
    await tester.ensureVisible(guestBtn);
    await tester.tap(guestBtn);
    await tester.pumpAndSettle();

    // Verify Guest mode UI
    expect(find.text('Xin chào, Khách khám phá'), findsOneWidget);
    expect(find.text('Khám phá'), findsWidgets);

    // Tapping restricted tab 'Đã lưu' should trigger login prompt
    await tester.tap(find.text('Đã lưu'));
    await tester.pumpAndSettle();
    expect(find.text('Yêu cầu đăng nhập'), findsOneWidget);
  });
}
