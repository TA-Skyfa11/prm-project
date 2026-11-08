import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'config/app_config.dart';
import 'data/listing_repository.dart';
import 'data/appointment_repository.dart';
import 'data/chat_repository.dart';
import 'domain/listing.dart';
import 'domain/appointment.dart';
import 'domain/chat.dart';
import 'domain/user_profile.dart';

const blue = Color(0xFF176CF5);
const darkBlue = Color(0xFF0F4CB8);
const muted = Color(0xFF8F959F);
const surface = Color(0xFFF5F8FC);
const green = Color(0xFF10B981);
const orange = Color(0xFFF59E0B);
const red = Color(0xFFEF4444);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    // Falls back gracefully if in mock or test environment
  }
  runApp(const AspenApp());
}

class AspenApp extends StatelessWidget {
  const AspenApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Aspen House Finder',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: blue),
          scaffoldBackgroundColor: Colors.white,
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const MainNavigationShell(),
      );
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentTab = 0;
  UserProfile _currentUser = UserProfile.defaultUser;

  final ListingRepository _listingRepo = ListingRepository();
  final AppointmentRepository _appointmentRepo = AppointmentRepository();
  final ChatRepository _chatRepo = ChatRepository();

  void _onRoleChanged(UserRole newRole) {
    setState(() {
      _currentUser = _currentUser.copyWith(role: newRole);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã chuyển vai trò sang: ${_currentUser.roleDisplay}'),
        backgroundColor: blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      ExplorePage(listingRepo: _listingRepo, appointmentRepo: _appointmentRepo, currentUser: _currentUser),
      SavedWishlistPage(listingRepo: _listingRepo, appointmentRepo: _appointmentRepo),
      AppointmentsPage(appointmentRepo: _appointmentRepo, currentUser: _currentUser),
      ChatListPage(chatRepo: _chatRepo, currentUser: _currentUser),
      ProfileHubPage(
        currentUser: _currentUser,
        onRoleChanged: _onRoleChanged,
        listingRepo: _listingRepo,
        appointmentRepo: _appointmentRepo,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _currentTab, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTab,
        onDestinationSelected: (idx) => setState(() => _currentTab = idx),
        indicatorColor: blue.withAlpha(28),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore, color: blue),
            label: 'Khám phá',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite, color: blue),
            label: 'Đã lưu',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month, color: blue),
            label: 'Lịch hẹn',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble, color: blue),
            label: 'Tin nhắn',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: blue),
            label: 'Tài khoản',
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// 1. EXPLORE & SEARCH PAGE
// ==============================================================================
class ExplorePage extends StatefulWidget {
  const ExplorePage({
    required this.listingRepo,
    required this.appointmentRepo,
    required this.currentUser,
    super.key,
  });

  final ListingRepository listingRepo;
  final AppointmentRepository appointmentRepo;
  final UserProfile currentUser;

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedCategory = 'Tất cả';
  String _selectedDistrict = 'Tất cả';
  String _searchQuery = '';
  double _maxPriceFilter = 15000000;

  final List<String> _districts = ['Tất cả', 'Cầu Giấy', 'Ba Đình', 'Nam Từ Liêm', 'Đống Đa', 'Tây Hồ'];
  final List<String> _categories = ['Tất cả', 'Phòng trọ', 'Căn hộ mini', 'Nhà nguyên căn', 'Ở ghép'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Bộ lọc tìm kiếm nâng cao', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 14),
              const Text('Khu vực quận/huyện', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _districts.map((d) {
                  final sel = d == _selectedDistrict;
                  return ChoiceChip(
                    label: Text(d),
                    selected: sel,
                    onSelected: (val) {
                      setSheetState(() => _selectedDistrict = d);
                      setState(() => _selectedDistrict = d);
                    },
                    selectedColor: blue,
                    labelStyle: TextStyle(color: sel ? Colors.white : Colors.black87, fontSize: 12),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Mức giá tối đa', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(
                    '${(_maxPriceFilter / 1000000).toStringAsFixed(1)} triệu/tháng',
                    style: const TextStyle(color: blue, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Slider(
                value: _maxPriceFilter,
                min: 1000000,
                max: 15000000,
                divisions: 14,
                activeColor: blue,
                onChanged: (val) {
                  setSheetState(() => _maxPriceFilter = val);
                  setState(() => _maxPriceFilter = val);
                },
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Áp dụng bộ lọc', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Listing>>(
      stream: widget.listingRepo.watchListings(),
      builder: (context, snapshot) {
        final allListings = snapshot.data ?? widget.listingRepo.currentListings;

        // Apply filters
        final filtered = allListings.where((item) {
          final matchesCategory = _selectedCategory == 'Tất cả' || item.category == _selectedCategory;
          final matchesDistrict = _selectedDistrict == 'Tất cả' || item.district == _selectedDistrict;
          final matchesPrice = item.price <= _maxPriceFilter;
          final matchesQuery = _searchQuery.isEmpty ||
              '${item.title} ${item.address} ${item.district} ${item.description}'
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase());
          return matchesCategory && matchesDistrict && matchesPrice && matchesQuery;
        }).toList();

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverToBoxAdapter(child: _buildHeader()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverToBoxAdapter(child: _buildSearchAndFilter()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverToBoxAdapter(child: _buildCategoriesBar()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _buildSectionTitle(
                  'Phòng nổi bật gần bạn (${filtered.length})',
                  onSeeAll: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AllListingsPage(
                        title: 'Phòng nổi bật gần bạn',
                        listings: filtered,
                        listingRepo: widget.listingRepo,
                        appointmentRepo: widget.appointmentRepo,
                        currentUser: widget.currentUser,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              sliver: SliverToBoxAdapter(
                child: SizedBox(
                  height: 260,
                  child: filtered.isEmpty
                      ? const Center(child: Text('Không tìm thấy phòng phù hợp tiêu chí'))
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: filtered.take(5).length,
                          separatorBuilder: (_, _) => const SizedBox(width: 14),
                          itemBuilder: (_, i) => _buildPopularCard(filtered[i]),
                        ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
              sliver: SliverToBoxAdapter(
                child: _buildSectionTitle(
                  'Gợi ý dành cho sinh viên & người đi làm',
                  onSeeAll: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AllListingsPage(
                        title: 'Tất cả phòng gợi ý',
                        listings: allListings,
                        listingRepo: widget.listingRepo,
                        appointmentRepo: widget.appointmentRepo,
                        currentUser: widget.currentUser,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList.builder(
                itemCount: filtered.length,
                itemBuilder: (_, i) => _buildRecommendedTile(filtered[i]),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        );
      },
    );
  }

  Widget _buildHeader() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Xin chào, ${widget.currentUser.fullName}', style: const TextStyle(color: muted, fontSize: 13)),
              const SizedBox(height: 2),
              const Text('Tìm phòng trọ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          InkWell(
            onTap: _openFilterSheet,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: blue, size: 16),
                  const SizedBox(width: 4),
                  Text(_selectedDistrict, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const Icon(Icons.arrow_drop_down, size: 18),
                ],
              ),
            ),
          ),
        ],
      );

  Widget _buildSearchAndFilter() => Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Tìm theo trường, phố, tiện ích...',
                hintStyle: const TextStyle(color: muted, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: muted),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: _openFilterSheet,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: blue, borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.tune, color: Colors.white, size: 20),
            ),
          ),
        ],
      );

  Widget _buildCategoriesBar() => SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _categories.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final cat = _categories[i];
            final sel = cat == _selectedCategory;
            return ChoiceChip(
              label: Text(cat),
              selected: sel,
              onSelected: (_) => setState(() => _selectedCategory = cat),
              selectedColor: blue,
              labelStyle: TextStyle(color: sel ? Colors.white : muted, fontSize: 12, fontWeight: FontWeight.w600),
              backgroundColor: surface,
              side: BorderSide.none,
            );
          },
        ),
      );

  Widget _buildSectionTitle(String title, {VoidCallback? onSeeAll}) => Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Xem tất cả', style: TextStyle(color: blue, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      );

  Widget _buildPopularCard(Listing item) {
    final isFav = widget.listingRepo.isFavorite(item.id);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetailPage(
            listing: item,
            listingRepo: widget.listingRepo,
            appointmentRepo: widget.appointmentRepo,
            currentUser: widget.currentUser,
          ),
        ),
      ),
      child: SizedBox(
        width: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  Image.network(
                    item.imageUrl,
                    height: 165,
                    width: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(height: 165, color: surface),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.black.withAlpha(160), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Color(0xFFFFB800), size: 14),
                          const SizedBox(width: 3),
                          Text('${item.rating}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () {
                        widget.listingRepo.toggleFavorite(item.id);
                        setState(() {});
                      },
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white,
                        child: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? red : muted, size: 18),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: blue.withAlpha(220), borderRadius: BorderRadius.circular(8)),
                      child: Text(item.category, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.district,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: muted, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 6),
                Text(item.formattedPrice, style: const TextStyle(color: blue, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedTile(Listing item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      color: surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailPage(
              listing: item,
              listingRepo: widget.listingRepo,
              appointmentRepo: widget.appointmentRepo,
              currentUser: widget.currentUser,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item.imageUrl,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(width: 90, height: 90, color: Colors.grey.shade200),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: blue.withAlpha(30), borderRadius: BorderRadius.circular(6)),
                          child: Text(item.category, style: const TextStyle(color: blue, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.district,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: muted, fontSize: 11),
                          ),
                        ),
                        const Icon(Icons.star, color: Color(0xFFFFB800), size: 14),
                        Text(' ${item.rating}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item.formattedPrice, style: const TextStyle(color: blue, fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Điện: ${item.formattedElectricity}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: muted, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==============================================================================
// 1.1 ALL LISTINGS (VIEW ALL) PAGE
// ==============================================================================
class AllListingsPage extends StatefulWidget {
  const AllListingsPage({
    required this.title,
    required this.listings,
    required this.listingRepo,
    required this.appointmentRepo,
    required this.currentUser,
    super.key,
  });

  final String title;
  final List<Listing> listings;
  final ListingRepository listingRepo;
  final AppointmentRepository appointmentRepo;
  final UserProfile currentUser;

  @override
  State<AllListingsPage> createState() => _AllListingsPageState();
}

class _AllListingsPageState extends State<AllListingsPage> {
  String _sortMode = 'Mặc định';
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Listing> filtered = widget.listings.where((item) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return '${item.title} ${item.address} ${item.district} ${item.category}'.toLowerCase().contains(q);
    }).toList();

    if (_sortMode == 'Giá tăng dần') {
      filtered.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortMode == 'Giá giảm dần') {
      filtered.sort((a, b) => b.price.compareTo(a.price));
    } else if (_sortMode == 'Đánh giá cao') {
      filtered.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm phòng trọ...',
                      hintStyle: const TextStyle(color: muted, fontSize: 13),
                      prefixIcon: const Icon(Icons.search, color: muted, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: surface,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                PopupMenuButton<String>(
                  initialValue: _sortMode,
                  onSelected: (mode) => setState(() => _sortMode = mode),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  icon: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.sort, color: blue, size: 20),
                  ),
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'Mặc định', child: Text('Mặc định')),
                    const PopupMenuItem(value: 'Giá tăng dần', child: Text('Giá thấp đến cao')),
                    const PopupMenuItem(value: 'Giá giảm dần', child: Text('Giá cao đến thấp')),
                    const PopupMenuItem(value: 'Đánh giá cao', child: Text('Đánh giá cao nhất')),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                Text('Hiển thị ${filtered.length} phòng trọ', style: const TextStyle(color: muted, fontSize: 12)),
                const Spacer(),
                Text('Sắp xếp: $_sortMode', style: const TextStyle(color: blue, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('Không tìm thấy phòng phù hợp tiêu chí'))
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (_, i) {
                      final item = filtered[i];
                      final isFav = widget.listingRepo.isFavorite(item.id);
                      return Card(
                        elevation: 0,
                        color: surface,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailPage(
                                listing: item,
                                listingRepo: widget.listingRepo,
                                appointmentRepo: widget.appointmentRepo,
                                currentUser: widget.currentUser,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    item.imageUrl,
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Container(width: 90, height: 90, color: Colors.grey.shade200),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: blue.withAlpha(30), borderRadius: BorderRadius.circular(6)),
                                            child: Text(item.category, style: const TextStyle(color: blue, fontSize: 10, fontWeight: FontWeight.bold)),
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              item.district,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(color: muted, fontSize: 11),
                                            ),
                                          ),
                                          const Icon(Icons.star, color: Color(0xFFFFB800), size: 14),
                                          Text(' ${item.rating}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(item.formattedPrice, style: const TextStyle(color: blue, fontWeight: FontWeight.bold, fontSize: 14)),
                                          GestureDetector(
                                            onTap: () {
                                              widget.listingRepo.toggleFavorite(item.id);
                                              setState(() {});
                                            },
                                            child: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? red : muted, size: 20),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// 2. SAVED / WISHLIST PAGE
// ==============================================================================
class SavedWishlistPage extends StatefulWidget {
  const SavedWishlistPage({
    required this.listingRepo,
    required this.appointmentRepo,
    super.key,
  });

  final ListingRepository listingRepo;
  final AppointmentRepository appointmentRepo;

  @override
  State<SavedWishlistPage> createState() => _SavedWishlistPageState();
}

class _SavedWishlistPageState extends State<SavedWishlistPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Set<String>>(
      stream: widget.listingRepo.watchFavorites(),
      builder: (context, favSnapshot) {
        final all = widget.listingRepo.currentListings;
        final favorites = all.where((l) => widget.listingRepo.isFavorite(l.id)).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Phòng trọ đã lưu (Wishlist)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: favorites.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: 70, color: muted.withAlpha(120)),
                      const SizedBox(height: 16),
                      const Text('Chưa có phòng nào được lưu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('Lưu phòng trọ yêu thích để tiện theo dõi và so sánh giá.', style: TextStyle(color: muted)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: favorites.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (_, i) {
                    final item = favorites[i];
                    return Card(
                      elevation: 0,
                      color: surface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailPage(
                              listing: item,
                              listingRepo: widget.listingRepo,
                              appointmentRepo: widget.appointmentRepo,
                              currentUser: UserProfile.defaultUser,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  item.imageUrl,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Container(width: 70, height: 70, color: Colors.grey.shade200),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text('${item.district} · ${item.formattedPrice}', style: const TextStyle(color: blue, fontWeight: FontWeight.bold, fontSize: 13)),
                                    Text('Điện: ${item.formattedElectricity}', style: const TextStyle(color: muted, fontSize: 11)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: red),
                                onPressed: () {
                                  widget.listingRepo.toggleFavorite(item.id);
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

// ==============================================================================
// 3. APPOINTMENTS (VIEWING REQUESTS) PAGE
// ==============================================================================
class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({
    required this.appointmentRepo,
    required this.currentUser,
    super.key,
  });

  final AppointmentRepository appointmentRepo;
  final UserProfile currentUser;

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  String _statusFilter = 'Tất cả';

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return orange;
      case 'approved':
        return green;
      case 'completed':
        return blue;
      case 'rejected':
      case 'cancelled':
        return red;
      default:
        return muted;
    }
  }

  void _showCancelDialog(Appointment aptm) {
    final reasonCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hủy lịch hẹn xem phòng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vui lòng nhập lý do hủy lịch:'),
            const SizedBox(height: 10),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(hintText: 'VD: Bận việc đột xuất, đã tìm được phòng...', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: red),
            onPressed: () {
              widget.appointmentRepo.updateStatus(aptm.id, 'cancelled', reason: reasonCtrl.text.trim());
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã hủy lịch hẹn thành công')));
            },
            child: const Text('Xác nhận hủy'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(Appointment aptm) {
    final reasonCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Từ chối lịch hẹn của khách'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Lý do từ chối (bắt buộc):'),
            const SizedBox(height: 10),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(hintText: 'VD: Trùng lịch, chủ nhà đi vắng...', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: red),
            onPressed: () {
              final r = reasonCtrl.text.trim().isEmpty ? 'Chủ nhà bận khung giờ này' : reasonCtrl.text.trim();
              widget.appointmentRepo.updateStatus(aptm.id, 'rejected', reason: r);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã từ chối lịch hẹn')));
            },
            child: const Text('Từ chối'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOwnerMode = widget.currentUser.role == UserRole.owner;

    return StreamBuilder<List<Appointment>>(
      stream: widget.appointmentRepo.watchAppointments(),
      builder: (context, snapshot) {
        final all = snapshot.data ?? widget.appointmentRepo.currentAppointments;
        final filtered = all.where((a) {
          if (_statusFilter == 'Chờ duyệt') return a.status == 'pending';
          if (_statusFilter == 'Đã xác nhận') return a.status == 'approved';
          if (_statusFilter == 'Đã hoàn thành') return a.status == 'completed';
          if (_statusFilter == 'Đã hủy') return a.status == 'cancelled' || a.status == 'rejected';
          return true;
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: Text(
              isOwnerMode ? 'Quản lý lịch hẹn (Chủ trọ)' : 'Lịch hẹn xem phòng của tôi',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: ['Tất cả', 'Chờ duyệt', 'Đã xác nhận', 'Đã hoàn thành', 'Đã hủy'].map((st) {
                    final sel = st == _statusFilter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(st),
                        selected: sel,
                        onSelected: (_) => setState(() => _statusFilter = st),
                        selectedColor: blue,
                        labelStyle: TextStyle(color: sel ? Colors.white : muted, fontSize: 12),
                        backgroundColor: surface,
                        side: BorderSide.none,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          body: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 64, color: muted.withAlpha(120)),
                      const SizedBox(height: 16),
                      Text('Không có lịch hẹn nào ($_statusFilter)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (_, i) {
                    final item = filtered[i];
                    return Card(
                      elevation: 0,
                      color: surface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(item.listingThumbnail, width: 50, height: 50, fit: BoxFit.cover),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.listingTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      const SizedBox(height: 4),
                                      Text(isOwnerMode ? 'Người đặt: ${item.finderName} (${item.finderPhone})' : 'Chủ trọ: ${item.ownerName}', style: const TextStyle(color: muted, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: _getStatusColor(item.status).withAlpha(30), borderRadius: BorderRadius.circular(12)),
                                  child: Text(item.statusDisplay, style: TextStyle(color: _getStatusColor(item.status), fontWeight: FontWeight.bold, fontSize: 11)),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 16, color: blue),
                                const SizedBox(width: 6),
                                Text('${item.time} · Ngày ${item.date}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              ],
                            ),
                            if (item.note.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text('Lời nhắn: "${item.note}"', style: const TextStyle(color: muted, fontSize: 12, fontStyle: FontStyle.italic)),
                            ],
                            if (item.rejectionReason != null) ...[
                              const SizedBox(height: 6),
                              Text('Lý do từ chối: ${item.rejectionReason}', style: const TextStyle(color: red, fontSize: 12)),
                            ],
                            const SizedBox(height: 12),
                            // Action buttons based on status & role
                            if (isOwnerMode && item.status == 'pending') ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(foregroundColor: red),
                                      onPressed: () => _showRejectDialog(item),
                                      child: const Text('Từ chối'),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: FilledButton(
                                      style: FilledButton.styleFrom(backgroundColor: green),
                                      onPressed: () {
                                        widget.appointmentRepo.updateStatus(item.id, 'approved');
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xác nhận đồng ý lịch hẹn!')));
                                      },
                                      child: const Text('Đồng ý'),
                                    ),
                                  ),
                                ],
                              ),
                            ] else if (isOwnerMode && item.status == 'approved') ...[
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  style: FilledButton.styleFrom(backgroundColor: blue),
                                  onPressed: () {
                                    widget.appointmentRepo.updateStatus(item.id, 'completed');
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xác nhận hoàn thành xem phòng!')));
                                  },
                                  child: const Text('Đánh dấu đã xem phòng thành công'),
                                ),
                              ),
                            ] else if (!isOwnerMode && (item.status == 'pending' || item.status == 'approved')) ...[
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(foregroundColor: red),
                                icon: const Icon(Icons.cancel_outlined, size: 16),
                                label: const Text('Hủy lịch hẹn này'),
                                onPressed: () => _showCancelDialog(item),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

// ==============================================================================
// 4. CHAT LIST & MESSAGING
// ==============================================================================
class ChatListPage extends StatelessWidget {
  const ChatListPage({
    required this.chatRepo,
    required this.currentUser,
    super.key,
  });

  final ChatRepository chatRepo;
  final UserProfile currentUser;

  @override
  Widget build(BuildContext context) {
    final rooms = ChatRoom.demo;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hộp thư tin nhắn', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: rooms.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final room = rooms[i];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            leading: Stack(
              children: [
                CircleAvatar(radius: 26, backgroundImage: networkErrorHandledImage(room.otherPartyAvatar)),
                if (room.unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: CircleAvatar(radius: 8, backgroundColor: blue, child: Text('${room.unreadCount}', style: const TextStyle(color: Colors.white, fontSize: 10))),
                  ),
              ],
            ),
            title: Text(room.otherPartyName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (room.listingTitle != null)
                  Text('Về: ${room.listingTitle}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: blue, fontSize: 11)),
                const SizedBox(height: 2),
                Text(room.lastMessageText, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: muted, fontSize: 13)),
              ],
            ),
            trailing: Text(room.lastMessageTime, style: const TextStyle(color: muted, fontSize: 11)),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatConversationScreen(
                  room: room,
                  chatRepo: chatRepo,
                  currentUser: currentUser,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ChatConversationScreen extends StatefulWidget {
  const ChatConversationScreen({
    required this.room,
    required this.chatRepo,
    required this.currentUser,
    super.key,
  });

  final ChatRoom room;
  final ChatRepository chatRepo;
  final UserProfile currentUser;

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final TextEditingController _msgCtrl = TextEditingController();

  void _send(String text) {
    if (text.trim().isEmpty) return;
    widget.chatRepo.sendMessage(
      widget.room.id,
      text.trim(),
      senderId: widget.currentUser.id,
      senderName: widget.currentUser.fullName,
    );
    _msgCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(radius: 18, backgroundImage: networkErrorHandledImage(widget.room.otherPartyAvatar)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.room.otherPartyName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const Text('Đang hoạt động', style: TextStyle(color: green, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call, color: blue),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đang kết nối cuộc gọi nhanh tới chủ trọ: 0982123456...')));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: widget.chatRepo.watchMessages(widget.room.id),
              builder: (context, snapshot) {
                final msgs = snapshot.data ?? [];
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: msgs.length,
                  itemBuilder: (_, i) {
                    final m = msgs[i];
                    return Align(
                      alignment: m.isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: m.isMe ? blue : surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          m.text,
                          style: TextStyle(color: m.isMe ? Colors.white : Colors.black87, fontSize: 14),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Quick message presets
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: ChatRepository.quickTemplates.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final q = ChatRepository.quickTemplates[i];
                return ActionChip(
                  label: Text(q, style: const TextStyle(fontSize: 11)),
                  onPressed: () => _send(q),
                  backgroundColor: surface,
                  side: BorderSide.none,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    decoration: InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      filled: true,
                      fillColor: surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: blue,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                    onPressed: () => _send(_msgCtrl.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// 5. PROFILE & MANAGEMENT HUB (ROLES SWITCHER & LANDLORD / ADMIN SUITE)
// ==============================================================================
class ProfileHubPage extends StatelessWidget {
  const ProfileHubPage({
    required this.currentUser,
    required this.onRoleChanged,
    required this.listingRepo,
    required this.appointmentRepo,
    super.key,
  });

  final UserProfile currentUser;
  final ValueChanged<UserRole> onRoleChanged;
  final ListingRepository listingRepo;
  final AppointmentRepository appointmentRepo;

  void _showKYCDialog(BuildContext context) {
    final cccdCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng ký xác minh Chủ trọ (KYC)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hệ thống yêu cầu xác minh CCCD/CMND để bảo vệ người thuê khỏi tin giả:'),
            const SizedBox(height: 12),
            TextField(
              controller: cccdCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Số CCCD gắn chip (12 số)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.cloud_upload_outlined),
              label: const Text('Tải ảnh 2 mặt CCCD lên Cloudflare R2'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: blue),
            onPressed: () {
              Navigator.pop(ctx);
              onRoleChanged(UserRole.owner);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Hồ sơ đã được duyệt! Đã cấp quyền Chủ nhà trọ.')),
              );
            },
            child: const Text('Gửi hồ sơ duyệt'),
          ),
        ],
      ),
    );
  }

  void _showAddPostDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    String cat = 'Phòng trọ';

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Đăng tin phòng trọ mới'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Tiêu đề bài đăng')),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: cat,
                  items: ['Phòng trọ', 'Căn hộ mini', 'Nhà nguyên căn', 'Ở ghép'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) => setDialogState(() => cat = val ?? 'Phòng trọ'),
                  decoration: const InputDecoration(labelText: 'Loại hình cho thuê'),
                ),
                const SizedBox(height: 8),
                TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Giá thuê hàng tháng (VNĐ)')),
                const SizedBox(height: 8),
                TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Địa chỉ cụ thể')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: blue),
              onPressed: () {
                final p = double.tryParse(priceCtrl.text) ?? 3000000;
                final newPost = Listing(
                  id: 'post_${DateTime.now().millisecondsSinceEpoch}',
                  title: titleCtrl.text.trim().isEmpty ? 'Phòng trọ mới đăng' : titleCtrl.text.trim(),
                  city: 'Hà Nội',
                  district: 'Cầu Giấy',
                  address: addressCtrl.text.trim().isEmpty ? 'Cầu Giấy, Hà Nội' : addressCtrl.text.trim(),
                  category: cat,
                  price: p,
                  deposit: p,
                  rating: 5.0,
                  reviewsCount: 1,
                  imageUrl: 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=700',
                  description: 'Phòng mới sạch sẽ đầy đủ nội thất...',
                  amenities: const ['Wi-Fi', 'Điều hòa', 'Nóng lạnh'],
                );
                listingRepo.addListing(newPost);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bài đăng đã được tạo và gửi duyệt thành công!')),
                );
              },
              child: const Text('Đăng bài'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ & Phân quyền', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // User Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  CircleAvatar(radius: 32, backgroundImage: networkErrorHandledImage(currentUser.avatarUrl)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(currentUser.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                        const SizedBox(height: 4),
                        Text(currentUser.email, style: const TextStyle(color: muted, fontSize: 12)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: blue.withAlpha(25), borderRadius: BorderRadius.circular(8)),
                          child: Text(currentUser.roleDisplay, style: const TextStyle(color: blue, fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Role Switcher (For grading / demo test)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Chuyển đổi vai trò trải nghiệm (PRM393 Demo):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: FilterChip(
                    label: const Text('Finder', style: TextStyle(fontSize: 12)),
                    selected: currentUser.role == UserRole.finder,
                    onSelected: (_) => onRoleChanged(UserRole.finder),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilterChip(
                    label: const Text('Owner', style: TextStyle(fontSize: 12)),
                    selected: currentUser.role == UserRole.owner,
                    onSelected: (_) => onRoleChanged(UserRole.owner),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilterChip(
                    label: const Text('Admin', style: TextStyle(fontSize: 12)),
                    selected: currentUser.role == UserRole.admin,
                    onSelected: (_) => onRoleChanged(UserRole.admin),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Role specific menu actions
            if (currentUser.role == UserRole.finder) ...[
              ListTile(
                leading: const Icon(Icons.verified_user_outlined, color: blue),
                title: const Text('Đăng ký trở thành Chủ trọ (KYC)'),
                subtitle: const Text('Xác thực danh tính để bắt đầu đăng tin cho thuê phòng'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showKYCDialog(context),
              ),
            ] else if (currentUser.role == UserRole.owner) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: blue.withAlpha(80)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Khu vực Quản trị dành cho Chủ trọ', style: TextStyle(fontWeight: FontWeight.bold, color: blue, fontSize: 15)),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: blue),
                      icon: const Icon(Icons.add),
                      label: const Text('Đăng tin phòng trọ mới'),
                      onPressed: () => _showAddPostDialog(context),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.home_work_outlined),
                      label: const Text('Quản lý khu trọ & Trạng thái phòng'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tính năng quản lý tòa nhà và đồng bộ trạng thái qua Firestore.')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ] else if (currentUser.role == UserRole.admin) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: orange.withAlpha(80)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Khu vực Quản trị viên (Admin Portal)', style: TextStyle(fontWeight: FontWeight.bold, color: orange, fontSize: 15)),
                    const SizedBox(height: 10),
                    const Text('KPIs Hệ thống: 120 Người dùng · 45 Bài đăng · 3 Báo cáo vi phạm'),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: orange),
                      icon: const Icon(Icons.approval),
                      label: const Text('Kiểm duyệt tin đăng (Pending Queue)'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đang tải danh sách tin bài cần Admin xét duyệt...')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Bảo mật & Đổi mật khẩu'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.cloud_outlined),
              title: const Text('Kiến trúc Cloudflare + Firebase'),
              subtitle: const Text('Edge API Worker, R2 Media CDN & Firestore Rules'),
              trailing: const Icon(Icons.info_outline),
              onTap: () {
                showDialog<void>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Cloudflare + Firebase Integration'),
                    content: const Text(
                      '• Worker API: ${AppConfig.workerBaseUrl}\n'
                      '• R2 Storage: ${AppConfig.r2BucketName} (Cloudflare)\n'
                      '• Firebase Project: ${AppConfig.firebaseProjectId}\n'
                      '• Storage Bucket: ${AppConfig.firebaseStorageBucket}\n'
                      '• Firestore: Real-time NoSQL DB & Security Rules\n'
                      '• Google Services: Đã kết nối google-services.json',
                    ),
                    actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đã hiểu'))],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ==============================================================================
// 6. LISTING DETAIL PAGE & VIEWING BOOKING MODAL
// ==============================================================================
class DetailPage extends StatelessWidget {
  const DetailPage({
    required this.listing,
    required this.listingRepo,
    required this.appointmentRepo,
    required this.currentUser,
    super.key,
  });

  final Listing listing;
  final ListingRepository listingRepo;
  final AppointmentRepository appointmentRepo;
  final UserProfile currentUser;

  void _openBookingSheet(BuildContext context) {
    String selectedDate = '12/11/2026';
    String selectedTime = '15:30';
    final noteCtrl = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Đặt lịch hẹn xem phòng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 10),
              Text(listing.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, color: blue)),
              const SizedBox(height: 16),
              const Text('Chọn ngày xem:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['11/11/2026', '12/11/2026', '13/11/2026', '14/11/2026'].map((d) {
                  final sel = d == selectedDate;
                  return ChoiceChip(
                    label: Text(d),
                    selected: sel,
                    onSelected: (_) => setSheetState(() => selectedDate = d),
                    selectedColor: blue,
                    labelStyle: TextStyle(color: sel ? Colors.white : Colors.black87, fontSize: 12),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              const Text('Khung giờ rảnh:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['09:00', '11:30', '15:30', '17:30', '19:00'].map((t) {
                  final sel = t == selectedTime;
                  return ChoiceChip(
                    label: Text(t),
                    selected: sel,
                    onSelected: (_) => setSheetState(() => selectedTime = t),
                    selectedColor: blue,
                    labelStyle: TextStyle(color: sel ? Colors.white : Colors.black87, fontSize: 12),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(
                  labelText: 'Lời nhắn gửi chủ trọ',
                  hintText: 'VD: Em muốn xem chỗ để xe và kiểm tra máy giặt...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: blue, padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () {
                    final aptm = Appointment(
                      id: 'aptm_${DateTime.now().millisecondsSinceEpoch}',
                      listingId: listing.id,
                      listingTitle: listing.title,
                      listingThumbnail: listing.imageUrl,
                      finderId: currentUser.id,
                      finderName: currentUser.fullName,
                      finderPhone: currentUser.phoneNumber,
                      ownerId: listing.ownerId,
                      ownerName: listing.ownerName,
                      date: selectedDate,
                      time: selectedTime,
                      status: 'pending',
                      note: noteCtrl.text.trim(),
                    );
                    appointmentRepo.bookAppointment(aptm);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Yêu cầu đặt lịch đã được gửi tới Chủ trọ thành công!'),
                        backgroundColor: green,
                      ),
                    );
                  },
                  child: const Text('Xác nhận đặt lịch', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                listing.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(color: surface),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => listingRepo.toggleFavorite(listing.id),
                icon: Icon(
                  listingRepo.isFavorite(listing.id) ? Icons.favorite : Icons.favorite_border,
                  color: listingRepo.isFavorite(listing.id) ? red : Colors.white,
                ),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: blue.withAlpha(25), borderRadius: BorderRadius.circular(8)),
                        child: Text(listing.category, style: const TextStyle(color: blue, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      const Spacer(),
                      const Icon(Icons.star, color: Color(0xFFFFB800), size: 18),
                      Text(' ${listing.rating}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(' (${listing.reviewsCount} đánh giá)', style: const TextStyle(color: muted, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(listing.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.3)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: blue),
                      const SizedBox(width: 4),
                      Expanded(child: Text(listing.address, style: const TextStyle(color: muted, fontSize: 13))),
                    ],
                  ),
                  const Divider(height: 32),

                  // Transparent Utility Costs Section
                  const Text('Minh bạch chi phí hàng tháng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        _buildCostRow('Tiền thuê hàng tháng', listing.formattedPrice, isPrimary: true),
                        const Divider(height: 16),
                        _buildCostRow('Tiền điện', listing.formattedElectricity),
                        const SizedBox(height: 6),
                        _buildCostRow('Tiền nước', listing.formattedWater),
                        const SizedBox(height: 6),
                        _buildCostRow('Internet / Wi-Fi', '${listing.internetCost.toStringAsFixed(0)} đ/tháng'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Room specs
                  const Text('Thông số phòng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSpecBadge(Icons.square_foot, '${listing.areaM2} m²', 'Diện tích'),
                      _buildSpecBadge(Icons.group_outlined, 'Tối đa ${listing.maxOccupants}', 'Người ở'),
                      _buildSpecBadge(Icons.stairs_outlined, 'Tầng ${listing.floor}', 'Vị trí'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Amenities
                  const Text('Tiện ích có sẵn', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: listing.amenities
                        .map((a) => Chip(
                              avatar: const Icon(Icons.check_circle, color: blue, size: 16),
                              label: Text(a, style: const TextStyle(fontSize: 12)),
                              backgroundColor: surface,
                              side: BorderSide.none,
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 24),

                  // Description
                  const Text('Mô tả chi tiết', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(listing.description, style: const TextStyle(color: Colors.black87, height: 1.5, fontSize: 14)),
                  const SizedBox(height: 24),

                  // Landlord Contact Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        const CircleAvatar(radius: 24, backgroundColor: surface, child: Icon(Icons.person, color: blue)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(listing.ownerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              const Text('Chủ trọ đã xác minh CCCD', style: TextStyle(color: green, fontSize: 11)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.phone, color: green),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đang gọi tới ${listing.ownerPhone}...')));
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.chat_bubble_outline, color: blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatConversationScreen(
                                  room: ChatRoom(
                                    id: 'room_${listing.id}',
                                    otherPartyId: listing.ownerId,
                                    otherPartyName: listing.ownerName,
                                    otherPartyAvatar: '',
                                    lastMessageText: '',
                                    lastMessageTime: '',
                                    listingTitle: listing.title,
                                  ),
                                  chatRepo: ChatRepository(),
                                  currentUser: currentUser,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 10, offset: const Offset(0, -3))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Giá thuê trọn gói', style: TextStyle(color: muted, fontSize: 11)),
                Text(listing.formattedPrice, style: const TextStyle(color: blue, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: blue, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
              icon: const Icon(Icons.calendar_month),
              label: const Text('Đặt lịch xem phòng'),
              onPressed: () => _openBookingSheet(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostRow(String label, String value, {bool isPrimary = false}) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isPrimary ? 14 : 13, fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: isPrimary ? 15 : 13, fontWeight: FontWeight.bold, color: isPrimary ? blue : Colors.black87)),
        ],
      );

  Widget _buildSpecBadge(IconData icon, String value, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(14)),
        child: Column(
          children: [
            Icon(icon, color: blue, size: 22),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text(label, style: const TextStyle(color: muted, fontSize: 11)),
          ],
        ),
      );
}

// Image provider with graceful fallback
ImageProvider networkErrorHandledImage(String url) {
  if (url.isEmpty || !url.startsWith('http')) {
    return const NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300');
  }
  return NetworkImage(url);
}
