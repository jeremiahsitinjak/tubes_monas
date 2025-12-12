class Celengan {
  final int? id;
  final String nama;
  final double target;
  final double nominalTerkumpul;
  final DateTime? targetDate;
  final String currency;
  final String plan;
  final double nominalPengisian;
  final bool notifOn;
  final String? notifTime;
  final String? notifDay;
  final String? imagePath;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final double totalDeposit;
  final double totalWithdraw;

  Celengan({
    this.id,
    required this.nama,
    required this.target,
    this.nominalTerkumpul = 0,
    this.targetDate,
    required this.currency,
    required this.plan,
    required this.nominalPengisian,
    this.notifOn = false,
    this.notifTime,
    this.notifDay,
    this.imagePath,
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.totalDeposit = 0,
    this.totalWithdraw = 0,
  });

  factory Celengan.fromJson(Map<String, dynamic> json) {
    return Celengan(
      id: json['id'],
      nama: json['nama'] ?? json['name'] ?? '',
      target: _parseDouble(json['target'] ?? json['target_amount']),
      nominalTerkumpul: _parseDouble(json['nominal_terkumpul'] ?? json['collected_amount']),
      targetDate: json['target_date'] != null
          ? DateTime.parse(json['target_date'])
          : null,
      currency: json['currency'] ?? 'Indonesia Rupiah (Rp)',
      plan: json['plan'] ?? json['frequency'] ?? 'Harian',
      nominalPengisian: _parseDouble(json['nominal_pengisian'] ?? json['amount']),
      notifOn: _parseBool(json['notif_on'] ?? json['notification_enabled']),
      notifTime: json['notif_time'] ?? json['notification_time'],
      notifDay: json['notif_day'] ?? json['notification_day'],
      imagePath: json['image_url'] ?? json['image_path'] ?? json['image'],
      status: json['status'] ?? 'active',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      totalDeposit: _parseDouble(json['total_deposit']),
      totalWithdraw: _parseDouble(json['total_withdraw']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'target': target,
      'nominal_terkumpul': nominalTerkumpul,
      'target_date': targetDate?.toIso8601String(),
      'currency': currency,
      'plan': plan,
      'nominal_pengisian': nominalPengisian,
      'notif_on': notifOn ? 1 : 0,
      'notif_time': notifTime,
      'notif_day': notifDay,
      'image_path': imagePath,
      'status': status,
      'total_deposit': totalDeposit,
      'total_withdraw': totalWithdraw,
    };
  }

  bool get isCompleted {
    if (targetDate == null) return false;
    return DateTime.now().isAfter(targetDate!) || nominalTerkumpul >= target;
  }

  double get progress {
    if (target == 0) return 0;
    return (nominalTerkumpul / target).clamp(0.0, 1.0);
  }
}

double _parseDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}

bool _parseBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final lower = value.toLowerCase();
    return lower == 'true' || lower == '1';
  }
  return false;
}

