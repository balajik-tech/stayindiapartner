import 'package:equatable/equatable.dart';
import '../../data/models/electricity_bill_model.dart';

enum DateFilterType { thisMonth, lastMonth, last30Days, custom }

class ElectricityBillState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final String hostelId;
  final String pgName;
  final String subtitle;
  final List<ElectricityRoomModel> rooms;
  final List<ElectricityBillModel> bills;
  final DateFilterType filterType;
  final DateTime fromDate;
  final DateTime toDate;

  ElectricityBillState({
    this.isLoading = false,
    this.errorMessage,
    this.hostelId = '',
    this.pgName = 'My PG',
    this.subtitle = 'Room electricity bills',
    this.rooms = const [],
    this.bills = const [],
    this.filterType = DateFilterType.thisMonth,
    DateTime? fromDate,
    DateTime? toDate,
  })  : fromDate = fromDate ?? _getStartOfCurrentMonth(),
        toDate = toDate ?? DateTime.now();

  static DateTime _getStartOfCurrentMonth() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  ElectricityBillState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? hostelId,
    String? pgName,
    String? subtitle,
    List<ElectricityRoomModel>? rooms,
    List<ElectricityBillModel>? bills,
    DateFilterType? filterType,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return ElectricityBillState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      hostelId: hostelId ?? this.hostelId,
      pgName: pgName ?? this.pgName,
      subtitle: subtitle ?? this.subtitle,
      rooms: rooms ?? this.rooms,
      bills: bills ?? this.bills,
      filterType: filterType ?? this.filterType,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hostelId': hostelId,
      'pgName': pgName,
      'subtitle': subtitle,
      'rooms': rooms.map((r) => r.toJson()).toList(),
      'bills': bills.map((b) => b.toJson()).toList(),
      'filterType': filterType.name,
      'fromDate': fromDate.toIso8601String(),
      'toDate': toDate.toIso8601String(),
    };
  }

  factory ElectricityBillState.fromJson(Map<String, dynamic> json) {
    DateFilterType type = DateFilterType.thisMonth;
    if (json['filterType'] != null) {
      type = DateFilterType.values.firstWhere(
        (e) => e.name == json['filterType'],
        orElse: () => DateFilterType.thisMonth,
      );
    }

    final roomsList = (json['rooms'] as List<dynamic>?)
            ?.map((e) => ElectricityRoomModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final billsList = (json['bills'] as List<dynamic>?)
            ?.map((e) => ElectricityBillModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return ElectricityBillState(
      hostelId: json['hostelId'] as String? ?? '',
      pgName: json['pgName'] as String? ?? 'My PG',
      subtitle: json['subtitle'] as String? ?? 'Room electricity bills',
      rooms: roomsList,
      bills: billsList,
      filterType: type,
      fromDate: json['fromDate'] != null
          ? DateTime.tryParse(json['fromDate'] as String)
          : null,
      toDate: json['toDate'] != null
          ? DateTime.tryParse(json['toDate'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorMessage,
        hostelId,
        pgName,
        subtitle,
        rooms,
        bills,
        filterType,
        fromDate,
        toDate,
      ];
}
