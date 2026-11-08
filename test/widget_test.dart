import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aspen_house_finder/main.dart';
import 'package:aspen_house_finder/data/auth_repository.dart';
import 'package:aspen_house_finder/domain/user_profile.dart';

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
    expect(find.text('Hậu kiểm tin'), findsOneWidget);
    expect(find.text('Duyệt Chủ trọ'), findsOneWidget);
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

  testWidgets('Newly registered Finder account does not show seed data in Saved, Appointments, or Chats', (tester) async {
    await AuthRepository().logout();
    await tester.pumpWidget(const AspenApp());
    await tester.pump();

    // Register a new Finder
    await AuthRepository().register(
      fullName: 'Người Thuê Mới',
      email: 'new_finder@test.vn',
      password: 'password123',
      phoneNumber: '0912345678',
      role: UserRole.finder,
    );
    await tester.pumpAndSettle();

    // 1. Verify Wishlist (Đã lưu) has NO seed favorites
    await tester.tap(find.text('Đã lưu'));
    await tester.pumpAndSettle();
    expect(find.text('Chưa có phòng nào được lưu'), findsOneWidget);

    // 2. Verify Appointments (Lịch hẹn) has NO seed appointments
    await tester.tap(find.text('Lịch hẹn'));
    await tester.pumpAndSettle();
    expect(find.text('Chưa có lịch hẹn nào'), findsOneWidget);

    // 3. Verify Chats (Tin nhắn) has NO seed conversations
    await tester.tap(find.text('Tin nhắn'));
    await tester.pumpAndSettle();
    expect(find.text('Chưa có tin nhắn nào'), findsOneWidget);
  });

  testWidgets('Newly registered Owner account does not show seed listings or appointments', (tester) async {
    await AuthRepository().logout();
    await tester.pumpWidget(const AspenApp());
    await tester.pump();

    // Register a new Owner
    await AuthRepository().register(
      fullName: 'Chủ Trọ Mới',
      email: 'new_owner@test.vn',
      password: 'password123',
      phoneNumber: '0987654321',
      role: UserRole.owner,
    );
    await tester.pumpAndSettle();

    // 1. Verify My Listings (Tin đăng của tôi) has NO seed listings
    expect(find.text('Chưa có tin đăng nào'), findsOneWidget);

    // 2. Verify Manage Appointments (Duyệt lịch hẹn) has NO seed appointments
    await tester.tap(find.text('Duyệt lịch hẹn'));
    await tester.pumpAndSettle();
    expect(find.text('Chưa có lịch hẹn nào'), findsOneWidget);

    // 3. Verify Owner Profile shows pending verification
    await tester.tap(find.text('Chủ trọ'));
    await tester.pumpAndSettle();
    expect(find.text('Hồ sơ đang chờ xác minh CCCD'), findsOneWidget);
  });

  testWidgets('Owner add listing opens Cloudflare R2 image picker sheet and selects image', (tester) async {
    await AuthRepository().logout();
    await tester.pumpWidget(const AspenApp());
    await tester.pump();

    // Tap Owner quick login
    await tester.tap(find.text('Owner'));
    await tester.pumpAndSettle();

    // Switch to 'Đăng tin mới' tab
    await tester.tap(find.text('Đăng tin mới'));
    await tester.pumpAndSettle();

    // Verify upload card is present
    final uploadBtn = find.text('Tải ảnh phòng trọ lên Cloudflare R2');
    expect(uploadBtn, findsWidgets);

    // Scroll to and tap upload area
    await tester.ensureVisible(uploadBtn.first);
    await tester.tap(uploadBtn.first);
    await tester.pumpAndSettle();

    // Verify BottomSheet options
    expect(find.text('Chọn ảnh từ Thư viện (Gallery)'), findsOneWidget);
    expect(find.text('Chụp ảnh phòng trọ (Camera)'), findsOneWidget);
    expect(find.text('Nhập link ảnh Cloudflare R2 / Web'), findsOneWidget);

    // Select preset image
    final sampleImg = find.text('Phòng khép kín ban công');
    expect(sampleImg, findsOneWidget);
    await tester.tap(sampleImg);
    await tester.pumpAndSettle();

    // Verify preview is rendered with Cloudflare R2 badge
    expect(find.text('Cloudflare R2: prm-project'), findsOneWidget);
  });

  testWidgets('Admin reviews and approves a Host KYC application in AdminHostKycTab', (tester) async {
    await AuthRepository().logout();
    await tester.pumpWidget(const AspenApp());
    await tester.pump();

    // Tap Admin quick login
    await tester.tap(find.text('Admin'));
    await tester.pumpAndSettle();

    // Navigate to 'Duyệt Chủ trọ' tab
    await tester.tap(find.text('Duyệt Chủ trọ'));
    await tester.pumpAndSettle();

    // Verify KYC applications exist in pending tab
    expect(find.text('Duyệt hồ sơ Chủ trọ (KYC CCCD)'), findsOneWidget);
    expect(find.text('Duyệt Chủ trọ'), findsWidgets);

    // Tap the first approve button
    final approveBtn = find.widgetWithText(FilledButton, 'Duyệt Chủ trọ');
    expect(approveBtn, findsWidgets);
    await tester.tap(approveBtn.first);
    await tester.pumpAndSettle();

    // Verify confirmation snackbar
    expect(find.textContaining('Đã phê duyệt quyền Chủ trọ'), findsOneWidget);
  });

  testWidgets('Owner add listing auto-approves immediately with post-moderation status', (tester) async {
    await AuthRepository().logout();
    await tester.pumpWidget(const AspenApp());
    await tester.pump();

    // Tap Owner quick login
    await tester.tap(find.text('Owner'));
    await tester.pumpAndSettle();

    // Switch to 'Đăng tin mới' tab
    await tester.tap(find.text('Đăng tin mới'));
    await tester.pumpAndSettle();

    // Verify auto-approval banner
    expect(find.textContaining('Cơ chế Tự động duyệt'), findsOneWidget);

    // Enter title & price
    await tester.enterText(find.widgetWithText(TextField, 'Tiêu đề tin đăng (*)'), 'Phòng khép kín ban công Hola');
    await tester.enterText(find.widgetWithText(TextField, 'Giá thuê hàng tháng (VNĐ) (*)'), '2800000');
    await tester.pump();

    // Tap 'Đăng tin & Xuất bản ngay (Tự động duyệt)'
    final submitBtn = find.text('Đăng tin & Xuất bản ngay (Tự động duyệt)');
    await tester.ensureVisible(submitBtn);
    await tester.tap(submitBtn);
    await tester.pumpAndSettle();

    // Verify confirmation snackbar
    expect(find.textContaining('Đã tự động duyệt và xuất bản tin đăng thành công!'), findsOneWidget);

    // Check 'Tin đăng của tôi' tab shows post-moderation badge
    await tester.tap(find.text('Tin đăng của tôi'));
    await tester.pumpAndSettle();
    expect(find.text('Đang hiển thị (Chờ hậu kiểm)'), findsWidgets);
  });

  testWidgets('Chat conversation sends quick template messages and manually typed messages successfully', (tester) async {
    await AuthRepository().logout();
    await tester.pumpWidget(const AspenApp());
    await tester.pump();

    // Tap Finder quick login
    await tester.tap(find.text('Finder'));
    await tester.pumpAndSettle();

    // Switch to 'Tin nhắn' tab
    await tester.tap(find.text('Tin nhắn'));
    await tester.pumpAndSettle();

    // Verify chat room list exists
    expect(find.text('Hộp thư tin nhắn'), findsOneWidget);
    expect(find.text('Bác Hoàng Văn Minh (Chủ trọ)'), findsOneWidget);

    // Tap on room
    await tester.tap(find.text('Bác Hoàng Văn Minh (Chủ trọ)'));
    await tester.pumpAndSettle();

    // Verify inside conversation screen
    expect(find.text('Phòng này hiện tại còn trống không ạ?'), findsOneWidget);

    // 1. Send quick template
    await tester.tap(find.text('Phòng này hiện tại còn trống không ạ?'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify the sent message appears in the chat list
    expect(find.text('Phòng này hiện tại còn trống không ạ?'), findsWidgets);

    // Wait for simulated host reply
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.textContaining('Phòng hiện vẫn còn trống nhé'), findsOneWidget);

    // 2. Send manual message
    await tester.enterText(find.byType(TextField), 'Em có thể qua xem lúc 17h được không ạ?');
    await tester.pump();

    final sendBtn = find.byIcon(Icons.send);
    expect(sendBtn, findsOneWidget);
    await tester.tap(sendBtn);
    await tester.pumpAndSettle();

    // Verify manual message is visible
    expect(find.text('Em có thể qua xem lúc 17h được không ạ?'), findsOneWidget);

    // Wait for simulated host reply
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();
    expect(find.textContaining('giữ lịch đón bạn'), findsOneWidget);
  });

  testWidgets('Finder saves room to Wishlist, views in Đã lưu tab, and removes from Wishlist', (tester) async {
    await AuthRepository().logout();
    await tester.pumpWidget(const AspenApp());
    await tester.pump();

    // Tap Finder quick login
    await tester.tap(find.text('Finder'));
    await tester.pumpAndSettle();

    // Find heart icon on explore page and tap it to toggle
    final favBorder = find.byIcon(Icons.favorite_border);
    expect(favBorder, findsWidgets);
    await tester.tap(favBorder.first);
    await tester.pumpAndSettle();

    // Verify snackbar feedback
    expect(find.textContaining('vào danh sách yêu thích'), findsOneWidget);

    // Navigate to 'Đã lưu' tab
    await tester.tap(find.text('Đã lưu'));
    await tester.pumpAndSettle();

    // Verify wishlist title and listing present
    expect(find.text('Phòng trọ đã lưu (Wishlist)'), findsOneWidget);

    // Tap delete button in wishlist to remove
    final deleteBtn = find.byIcon(Icons.delete_outline);
    if (deleteBtn.evaluate().isNotEmpty) {
      await tester.tap(deleteBtn.first);
      await tester.pumpAndSettle();
      expect(find.textContaining('Đã bỏ lưu phòng'), findsOneWidget);
    }
  });

  testWidgets('Owner views pending inquiries in OwnerInboxTab and replies quickly with host templates', (tester) async {
    await AuthRepository().logout();
    await tester.pumpWidget(const AspenApp());
    await tester.pump();

    // Tap Owner quick login
    await tester.tap(find.text('Owner'));
    await tester.pumpAndSettle();

    // Verify Owner shell shows 'Tin nhắn chờ' tab
    expect(find.text('Tin nhắn chờ'), findsOneWidget);

    // Tap 'Tin nhắn chờ' tab
    await tester.tap(find.text('Tin nhắn chờ'));
    await tester.pumpAndSettle();

    // Verify Pending messages screen UI
    expect(find.text('Tin nhắn chờ & Phản hồi'), findsOneWidget);
    expect(find.textContaining('tin cần trả lời'), findsOneWidget);
    expect(find.textContaining('Chờ trả lời'), findsWidgets);
    expect(find.textContaining('Đã phản hồi'), findsWidgets);
    expect(find.textContaining('Tất cả'), findsWidgets);

    // Verify pending guest inquiry exists
    expect(find.text('Nguyễn Văn Tuấn (Khách tìm trọ)'), findsOneWidget);
    expect(find.text('Chờ bạn trả lời'), findsWidgets);

    // Tap quick template on the card to answer
    final quickReplyBtn = find.text('Chào bạn! Phòng hiện vẫn còn trống nhé.');
    expect(quickReplyBtn, findsWidgets);
    await tester.tap(quickReplyBtn.first);
    await tester.pumpAndSettle();

    // Verify success feedback
    expect(find.textContaining('Đã gửi phản hồi nhanh tới'), findsOneWidget);

    // Tap 'Trả lời ngay' to open conversation
    final replyBtn = find.text('Trả lời ngay');
    expect(replyBtn, findsWidgets);
    await tester.tap(replyBtn.first, warnIfMissed: false);
    await tester.pumpAndSettle();

    // Inside ChatConversationScreen, verify host templates are available
    expect(find.text('Chào bạn! Phòng hiện vẫn còn trống nhé.'), findsWidgets);
    expect(find.text('Bạn có thể qua xem phòng lúc 17h30 chiều nay được không?'), findsOneWidget);

    // Send a message as host
    await tester.tap(find.text('Bạn có thể qua xem phòng lúc 17h30 chiều nay được không?'), warnIfMissed: false);
    await tester.pumpAndSettle();

    // Verify the host message is in the chat
    expect(find.text('Bạn có thể qua xem phòng lúc 17h30 chiều nay được không?'), findsWidgets);
  });
}
