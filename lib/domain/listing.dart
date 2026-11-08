class Listing {
  const Listing({
    required this.id,
    required this.title,
    required this.city,
    required this.district,
    required this.address,
    required this.category,
    required this.price,
    this.deposit = 0,
    this.electricityCost = 3800,
    this.waterCost = 30000,
    this.internetCost = 100000,
    this.areaM2 = 25.0,
    this.maxOccupants = 2,
    this.floor = 2,
    required this.rating,
    this.reviewsCount = 0,
    this.approvalStatus = 'approved',
    this.roomStatus = 'available',
    required this.imageUrl,
    this.images = const [],
    required this.description,
    required this.amenities,
    this.ownerId = 'owner_001',
    this.ownerName = 'Chủ trọ',
    this.ownerPhone = '0982123456',
    this.latitude = 21.0285,
    this.longitude = 105.8542,
  });

  final String id;
  final String title;
  final String city;
  final String district;
  final String address;
  final String category;
  final double price;
  final double deposit;
  final double electricityCost;
  final double waterCost;
  final double internetCost;
  final double areaM2;
  final int maxOccupants;
  final int floor;
  final double rating;
  final int reviewsCount;
  final String approvalStatus; // "pending", "approved", "rejected"
  final String roomStatus; // "available", "rented", "hidden"
  final String imageUrl;
  final List<String> images;
  final String description;
  final List<String> amenities;
  final String ownerId;
  final String ownerName;
  final String ownerPhone;
  final double latitude;
  final double longitude;

  String get formattedPrice {
    if (price >= 1000000) {
      final millions = price / 1000000;
      return millions % 1 == 0 ? '${millions.toStringAsFixed(0)} tr/tháng' : '${millions.toStringAsFixed(1)} tr/tháng';
    }
    return '${price.toStringAsFixed(0)} đ/tháng';
  }

  String get formattedElectricity => '${electricityCost.toStringAsFixed(0)} đ/kWh';
  String get formattedWater => '${waterCost.toStringAsFixed(0)} đ/khối';

  factory Listing.fromMap(String id, Map<String, dynamic> map) => Listing(
        id: id,
        title: map['title'] as String? ?? 'Phòng trọ',
        city: map['city'] as String? ?? 'Hà Nội',
        district: map['district'] as String? ?? 'Cầu Giấy',
        address: map['address'] as String? ?? 'Hà Nội',
        category: map['category'] as String? ?? 'Phòng trọ',
        price: (map['price'] as num?)?.toDouble() ?? 3000000,
        deposit: (map['deposit'] as num?)?.toDouble() ?? 3000000,
        electricityCost: (map['electricityCost'] as num?)?.toDouble() ?? 3800,
        waterCost: (map['waterCost'] as num?)?.toDouble() ?? 30000,
        internetCost: (map['internetCost'] as num?)?.toDouble() ?? 100000,
        areaM2: (map['areaM2'] as num?)?.toDouble() ?? 25.0,
        maxOccupants: (map['maxOccupants'] as num?)?.toInt() ?? 2,
        floor: (map['floor'] as num?)?.toInt() ?? 1,
        rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
        reviewsCount: (map['reviewsCount'] as num?)?.toInt() ?? 0,
        approvalStatus: map['approvalStatus'] as String? ?? 'approved',
        roomStatus: map['roomStatus'] as String? ?? 'available',
        imageUrl: map['imageUrl'] as String? ?? '',
        images: List<String>.from(map['images'] as List? ?? []),
        description: map['description'] as String? ?? '',
        amenities: List<String>.from(map['amenities'] as List? ?? const []),
        ownerId: map['ownerId'] as String? ?? 'owner_001',
        ownerName: map['ownerName'] as String? ?? 'Chủ nhà',
        ownerPhone: map['ownerPhone'] as String? ?? '0982123456',
        latitude: (map['latitude'] as num?)?.toDouble() ?? 21.0285,
        longitude: (map['longitude'] as num?)?.toDouble() ?? 105.8542,
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        'city': city,
        'district': district,
        'address': address,
        'category': category,
        'price': price,
        'deposit': deposit,
        'electricityCost': electricityCost,
        'waterCost': waterCost,
        'internetCost': internetCost,
        'areaM2': areaM2,
        'maxOccupants': maxOccupants,
        'floor': floor,
        'rating': rating,
        'reviewsCount': reviewsCount,
        'approvalStatus': approvalStatus,
        'roomStatus': roomStatus,
        'imageUrl': imageUrl,
        'images': images,
        'description': description,
        'amenities': amenities,
        'ownerId': ownerId,
        'ownerName': ownerName,
        'ownerPhone': ownerPhone,
        'latitude': latitude,
        'longitude': longitude,
      };

  Listing copyWith({
    String? approvalStatus,
    String? roomStatus,
    double? rating,
    int? reviewsCount,
  }) =>
      Listing(
        id: id,
        title: title,
        city: city,
        district: district,
        address: address,
        category: category,
        price: price,
        deposit: deposit,
        electricityCost: electricityCost,
        waterCost: waterCost,
        internetCost: internetCost,
        areaM2: areaM2,
        maxOccupants: maxOccupants,
        floor: floor,
        rating: rating ?? this.rating,
        reviewsCount: reviewsCount ?? this.reviewsCount,
        approvalStatus: approvalStatus ?? this.approvalStatus,
        roomStatus: roomStatus ?? this.roomStatus,
        imageUrl: imageUrl,
        images: images,
        description: description,
        amenities: amenities,
        ownerId: ownerId,
        ownerName: ownerName,
        ownerPhone: ownerPhone,
        latitude: latitude,
        longitude: longitude,
      );

  static const demo = [
    Listing(
      id: 'post_cau_giay_301',
      title: 'Phòng khép kín ban công thoáng mát gần ĐH Giao Thông Vận Tải',
      city: 'Hà Nội',
      district: 'Cầu Giấy',
      address: 'Số 26 Ngõ 165 Cầu Giấy',
      category: 'Căn hộ mini',
      price: 3800000,
      deposit: 3800000,
      electricityCost: 3800,
      waterCost: 30000,
      internetCost: 100000,
      areaM2: 28.0,
      maxOccupants: 2,
      floor: 3,
      rating: 4.9,
      reviewsCount: 8,
      imageUrl: 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=700',
      images: [
        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=700',
        'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=700',
        'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=700',
      ],
      description: 'Phòng cực thoáng đẹp, mới sơn sửa. Có ban công riêng phơi đồ, full đồ: giường nệm, tủ quần áo 3 cánh, điều hòa Inverter mát lịm, bình nóng lạnh Ariston, tủ lạnh mini. Khóa vân tay ra vào tự do, camera giám sát 24/7. Cách trạm xe buýt và ga tàu điện Nhổn 200m.',
      amenities: ['Wi-Fi', 'Điều hòa', 'Nóng lạnh', 'Tủ lạnh', 'Chỗ để xe', 'Khóa vân tay', 'Ban công', 'Vệ sinh khép kín'],
      ownerId: 'owner_001',
      ownerName: 'Bác Hoàng Văn Minh',
      ownerPhone: '0982123456',
      latitude: 21.0345,
      longitude: 105.7923,
    ),
    Listing(
      id: 'post_ba_dinh_202',
      title: 'Studio view hồ Trúc Bạch cực chill, full nội thất cao cấp',
      city: 'Hà Nội',
      district: 'Ba Đình',
      address: 'Số 12 Trúc Bạch',
      category: 'Căn hộ mini',
      price: 6200000,
      deposit: 6200000,
      electricityCost: 4000,
      waterCost: 100000,
      internetCost: 0,
      areaM2: 35.0,
      maxOccupants: 2,
      floor: 4,
      rating: 4.8,
      reviewsCount: 12,
      imageUrl: 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=700',
      images: [
        'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=700',
        'https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=700',
      ],
      description: 'Studio cửa sổ kính tràn panorama ngắm hồ mát mẻ. Trang bị bếp nấu từ âm, hút mùi, máy giặt riêng trong phòng. Khu dân trí cao, yên tĩnh tuyệt đối, an ninh đảm bảo.',
      amenities: ['Wi-Fi', 'Điều hòa', 'Máy giặt riêng', 'Thang máy', 'Bếp từ', 'Bảo vệ 24/7', 'Chỗ để xe'],
      ownerId: 'owner_002',
      ownerName: 'Chị Trần Thanh Hà',
      ownerPhone: '0915678999',
      latitude: 21.0498,
      longitude: 105.8398,
    ),
    Listing(
      id: 'post_nam_tu_liem_101',
      title: 'Phòng trọ giá rẻ cho sinh viên FPTU / ĐHQG gần bến xe Mỹ Đình',
      city: 'Hà Nội',
      district: 'Nam Từ Liêm',
      address: 'Ngõ 39 Đình Thôn',
      category: 'Phòng trọ',
      price: 2500000,
      deposit: 2500000,
      electricityCost: 3500,
      waterCost: 25000,
      internetCost: 80000,
      areaM2: 20.0,
      maxOccupants: 2,
      floor: 2,
      rating: 4.6,
      reviewsCount: 5,
      imageUrl: 'https://images.unsplash.com/photo-1497366754035-f200968a6e72?w=700',
      images: [
        'https://images.unsplash.com/photo-1497366754035-f200968a6e72?w=700',
      ],
      description: 'Phòng trọ sạch sẽ có gác xép lửng kiên cố ngủ riêng. Có sẵn nóng lạnh, quạt trần, kệ bếp nấu ăn. Để xe tầng 1 miễn phí.',
      amenities: ['Wi-Fi', 'Gác lửng', 'Nóng lạnh', 'Chỗ để xe miễn phí', 'Kệ bếp'],
      ownerId: 'owner_001',
      ownerName: 'Bác Hoàng Văn Minh',
      ownerPhone: '0982123456',
      latitude: 21.0189,
      longitude: 105.7765,
    ),
    Listing(
      id: 'post_dong_da_401',
      title: 'Nhà riêng 3 tầng Chùa Bộc tiện nhóm bạn ở ghép hoặc kinh doanh online',
      city: 'Hà Nội',
      district: 'Đống Đa',
      address: 'Số 45 Ngõ Chùa Bộc',
      category: 'Nhà nguyên căn',
      price: 9500000,
      deposit: 9500000,
      electricityCost: 2500,
      waterCost: 20000,
      internetCost: 200000,
      areaM2: 65.0,
      maxOccupants: 6,
      floor: 3,
      rating: 4.7,
      reviewsCount: 4,
      imageUrl: 'https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=700',
      images: [
        'https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=700',
      ],
      description: 'Nhà 3 phòng ngủ riêng biệt, 2 WC, phòng khách rộng rãi, sân thượng phơi đồ ngắm thành phố. Điện nước tính theo công tơ giá dân cực rẻ.',
      amenities: ['Điện nước giá dân', '3 Phòng ngủ', 'Bếp riêng', 'Sân thượng phơi đồ', 'Chỗ để xe'],
      ownerId: 'owner_003',
      ownerName: 'Cô Đỗ Mai Lan',
      ownerPhone: '0903456789',
      latitude: 21.0076,
      longitude: 105.8284,
    ),
  ];
}
