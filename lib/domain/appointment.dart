class Appointment {
  const Appointment({
    required this.id,
    required this.listingId,
    required this.listingTitle,
    required this.listingThumbnail,
    required this.finderId,
    required this.finderName,
    required this.finderPhone,
    required this.ownerId,
    this.ownerName = 'Chủ trọ',
    required this.date,
    required this.time,
    required this.status, // "pending", "approved", "rejected", "completed", "cancelled"
    this.note = '',
    this.cancelReason,
    this.rejectionReason,
  });

  final String id;
  final String listingId;
  final String listingTitle;
  final String listingThumbnail;
  final String finderId;
  final String finderName;
  final String finderPhone;
  final String ownerId;
  final String ownerName;
  final String date;
  final String time;
  final String status;
  final String note;
  final String? cancelReason;
  final String? rejectionReason;

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'approved':
        return 'Đã xác nhận';
      case 'rejected':
        return 'Bị từ chối';
      case 'completed':
        return 'Đã hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  factory Appointment.fromMap(String id, Map<String, dynamic> map) => Appointment(
        id: id,
        listingId: map['listingId'] as String? ?? '',
        listingTitle: map['listingTitle'] as String? ?? 'Phòng trọ',
        listingThumbnail: map['listingThumbnail'] as String? ?? '',
        finderId: map['finderId'] as String? ?? '',
        finderName: map['finderName'] as String? ?? 'Người thuê',
        finderPhone: map['finderPhone'] as String? ?? '',
        ownerId: map['ownerId'] as String? ?? '',
        ownerName: map['ownerName'] as String? ?? 'Chủ trọ',
        date: map['appointmentDate'] as String? ?? '',
        time: map['appointmentTime'] as String? ?? '',
        status: map['status'] as String? ?? 'pending',
        note: map['finderNote'] as String? ?? '',
        cancelReason: map['cancelReason'] as String?,
        rejectionReason: map['rejectionReason'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'listingId': listingId,
        'listingTitle': listingTitle,
        'listingThumbnail': listingThumbnail,
        'finderId': finderId,
        'finderName': finderName,
        'finderPhone': finderPhone,
        'ownerId': ownerId,
        'ownerName': ownerName,
        'appointmentDate': date,
        'appointmentTime': time,
        'status': status,
        'finderNote': note,
        'cancelReason': cancelReason,
        'rejectionReason': rejectionReason,
      };

  Appointment copyWith({
    String? status,
    String? cancelReason,
    String? rejectionReason,
  }) =>
      Appointment(
        id: id,
        listingId: listingId,
        listingTitle: listingTitle,
        listingThumbnail: listingThumbnail,
        finderId: finderId,
        finderName: finderName,
        finderPhone: finderPhone,
        ownerId: ownerId,
        ownerName: ownerName,
        date: date,
        time: time,
        status: status ?? this.status,
        note: note,
        cancelReason: cancelReason ?? this.cancelReason,
        rejectionReason: rejectionReason ?? this.rejectionReason,
      );

  static final List<Appointment> demo = [
    const Appointment(
      id: 'aptm_001',
      listingId: 'post_cau_giay_301',
      listingTitle: 'Phòng khép kín ban công thoáng mát gần ĐH Giao Thông Vận Tải',
      listingThumbnail: 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=700',
      finderId: 'current_user_finder',
      finderName: 'Trần Thị Lan (Bạn)',
      finderPhone: '0977888999',
      ownerId: 'owner_001',
      ownerName: 'Bác Hoàng Văn Minh',
      date: '12/11/2026',
      time: '15:30',
      status: 'pending',
      note: 'Em muốn qua xem trực tiếp phòng và chỗ sạc xe điện ạ.',
    ),
    const Appointment(
      id: 'aptm_002',
      listingId: 'post_ba_dinh_202',
      listingTitle: 'Studio view hồ Trúc Bạch cực chill, full nội thất cao cấp',
      listingThumbnail: 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=700',
      finderId: 'current_user_finder',
      finderName: 'Trần Thị Lan (Bạn)',
      finderPhone: '0977888999',
      ownerId: 'owner_002',
      ownerName: 'Chị Trần Thanh Hà',
      date: '10/11/2026',
      time: '09:00',
      status: 'approved',
      note: 'Xem phòng buổi sáng trước khi đi làm.',
    ),
  ];
}
