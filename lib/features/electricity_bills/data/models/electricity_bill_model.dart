import 'package:equatable/equatable.dart';
import '../../../../core/utils/string_utils.dart';

class ElectricityBillModel extends Equatable {
  final String id;
  final String hostelId;
  final String roomId;
  final String roomCode; // e.g. "G01", "G02", "101", "102"
  final String roomName; // e.g. "Room G01"
  final DateTime billStartDate;
  final DateTime billEndDate;
  final DateTime dueDate;
  final String month;
  final double amount;
  final String? note;
  final String? status;
  final List<dynamic>? tenantSplits;

  ElectricityBillModel({
    String? id,
    String? hostelId,
    String? roomId,
    String? roomCode,
    String? roomName,
    DateTime? billStartDate,
    DateTime? billEndDate,
    DateTime? dueDate,
    DateTime? date,
    String? month,
    double? amount,
    this.note,
    this.status,
    this.tenantSplits,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        hostelId = hostelId ?? '',
        roomId = roomId ?? '',
        roomCode = roomCode ?? '',
        roomName = roomName ?? '',
        billStartDate = billStartDate ?? date ?? DateTime.now(),
        billEndDate = billEndDate ?? date ?? DateTime.now(),
        dueDate = dueDate ?? date ?? DateTime.now(),
        month = month ?? '',
        amount = amount ?? 0.0;

  DateTime get date => billStartDate;
  double get billAmount => amount;

  bool get isPaid {
    final s = status?.toUpperCase();
    if (s == 'PAID' || s == 'COMPLETED') return true;
    if (tenantSplits != null && tenantSplits!.isNotEmpty) {
      final allTenantsPaid = tenantSplits!.every((item) {
        if (item is Map) {
          final ts = item['status']?.toString().toUpperCase();
          return ts == 'PAID' || ts == 'COMPLETED';
        }
        return false;
      });
      if (allTenantsPaid) return true;
    }
    return false;
  }

  bool get isPaidOrPartiallyPaid {
    final s = status?.toUpperCase();
    if (s == 'PAID' || s == 'PARTIALLY_PAID' || s == 'PARTIAL' || s == 'COMPLETED') {
      return true;
    }
    if (tenantSplits != null && tenantSplits!.isNotEmpty) {
      final hasAnyPaidTenant = tenantSplits!.any((item) {
        if (item is Map) {
          final ts = item['status']?.toString().toUpperCase();
          return ts == 'PAID' || ts == 'PARTIALLY_PAID' || ts == 'PARTIAL' || ts == 'COMPLETED';
        }
        return false;
      });
      if (hasAnyPaidTenant) return true;
    }
    return false;
  }

  ElectricityBillModel copyWith({
    String? id,
    String? hostelId,
    String? roomId,
    String? roomCode,
    String? roomName,
    DateTime? billStartDate,
    DateTime? billEndDate,
    DateTime? dueDate,
    String? month,
    double? amount,
    String? note,
    String? status,
    List<dynamic>? tenantSplits,
  }) {
    return ElectricityBillModel(
      id: id ?? this.id,
      hostelId: hostelId ?? this.hostelId,
      roomId: roomId ?? this.roomId,
      roomCode: roomCode ?? this.roomCode,
      roomName: roomName ?? this.roomName,
      billStartDate: billStartDate ?? this.billStartDate,
      billEndDate: billEndDate ?? this.billEndDate,
      dueDate: dueDate ?? this.dueDate,
      month: month ?? this.month,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      status: status ?? this.status,
      tenantSplits: tenantSplits ?? this.tenantSplits,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hostelId': hostelId,
      'roomId': roomId,
      'roomCode': roomCode,
      'roomName': roomName,
      'billStartDate': billStartDate.toIso8601String(),
      'billEndDate': billEndDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'month': month,
      'amount': amount,
      'note': note,
      'status': status,
      'tenantSplits': tenantSplits,
    };
  }

  factory ElectricityBillModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDt(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString()) ?? DateTime.now();
    }

    final startDate = parseDt(json['billStartDate'] ?? json['date']);
    final endDate = parseDt(json['billEndDate'] ?? json['date']);
    final due = parseDt(json['dueDate'] ?? json['date']);

    final roomObj = json['room'] is Map ? json['room'] as Map<String, dynamic> : null;
    final rawRoomId = json['roomId'] as String? ?? roomObj?['_id'] as String? ?? '';
    final rawRoomTypename = json['roomCode'] as String? ?? roomObj?['roomTypename'] as String? ?? '';
    final formattedCode = StringUtils.formatRoomNumber(rawRoomTypename, roomObj?['floor']);
    final formattedName = rawRoomTypename.contains('Room') ? rawRoomTypename : 'Room $formattedCode';

    return ElectricityBillModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      hostelId: json['hostelId'] as String? ?? json['hostel']?['_id'] as String? ?? '',
      roomId: rawRoomId,
      roomCode: formattedCode,
      roomName: formattedName,
      billStartDate: startDate,
      billEndDate: endDate,
      dueDate: due,
      month: json['month'] as String? ?? '',
      amount: json['billAmount'] != null
          ? (json['billAmount'] as num).toDouble()
          : (json['amount'] != null ? (json['amount'] as num).toDouble() : 0.0),
      note: json['notes'] as String? ?? json['note'] as String?,
      status: json['status'] as String?,
      tenantSplits: json['tenantSplits'] as List<dynamic>?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        hostelId,
        roomId,
        roomCode,
        roomName,
        billStartDate,
        billEndDate,
        dueDate,
        month,
        amount,
        note,
        status,
        tenantSplits,
      ];
}

class ElectricityRoomModel extends Equatable {
  final String id;
  final String code; // e.g. "G01", "G02", "101"
  final String name; // e.g. "Room G01", "Room G02"
  final bool isCustom;

  const ElectricityRoomModel({
    this.id = '',
    this.code = '',
    this.name = '',
    this.isCustom = false,
  });

  ElectricityRoomModel copyWith({
    String? id,
    String? code,
    String? name,
    bool? isCustom,
  }) {
    return ElectricityRoomModel(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'isCustom': isCustom,
    };
  }

  factory ElectricityRoomModel.fromJson(Map<String, dynamic> json) {
    return ElectricityRoomModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? json['code'] as String? ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? 'Room ${json['code'] ?? ''}',
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [id, code, name, isCustom];
}
