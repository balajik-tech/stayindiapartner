import 'package:equatable/equatable.dart';
import 'package:stayindia_owner/features/bookings/domain/booking.dart';

import 'package:stayindia_owner/features/dashboard/data/models/occupancy_model.dart';

enum BookingsStatus { initial, loading, success, failure }

class BookingsState extends Equatable {
  final BookingsStatus status;
  final List<Booking> bookings;
  final List<PendingBooking> pendingBookings;
  final String? errorMessage;
  final String? successMessage;
  final ScanBookingResponse? scannedBooking;
  final OccupancyModel? occupancy;
  final String? searchQuery;
  final String? kycStatus;
  final String? roomType;
  final String? hostelId;

  final int page;
  final bool hasMore;
  final bool isLoadMore;

  const BookingsState({
    this.status = BookingsStatus.initial,
    this.bookings = const [],
    this.pendingBookings = const [],
    this.errorMessage,
    this.successMessage,
    this.scannedBooking,
    this.occupancy,
    this.searchQuery,
    this.kycStatus,
    this.roomType,
    this.hostelId,
    this.page = 1,
    this.hasMore = true,
    this.isLoadMore = false,
  });

  List<Booking> get _filtered => searchQuery == null || searchQuery!.isEmpty
      ? bookings
      : bookings.where((b) {
          final q = searchQuery!.toLowerCase();
          return b.tenantName.toLowerCase().contains(q) ||
              b.roomTypeName.toLowerCase().contains(q) ||
              b.bedNumber.toLowerCase().contains(q) ||
              b.tenantPhone.toLowerCase().contains(q);
        }).toList();

  List<Booking> get requests => _filtered
      .where(
        (b) =>
            [BookingStatus.confirmed, BookingStatus.pending].contains(b.status),
      )
      .toList();

  List<Booking> get checkIns =>
      _filtered.where((b) => b.status == BookingStatus.checkedIn).toList();

  static const Object _keep = Object();

  BookingsState copyWith({
    BookingsStatus? status,
    List<Booking>? bookings,
    List<PendingBooking>? pendingBookings,
    Object? errorMessage = _keep,
    Object? successMessage = _keep,
    Object? scannedBooking = _keep,
    Object? searchQuery = _keep,
    Object? kycStatus = _keep,
    Object? roomType = _keep,
    Object? hostelId = _keep,
    OccupancyModel? occupancy,
    int? page,
    bool? hasMore,
    bool? isLoadMore,
  }) {
    return BookingsState(
      status: status ?? this.status,
      bookings: bookings ?? this.bookings,
      pendingBookings: pendingBookings ?? this.pendingBookings,
      errorMessage: errorMessage == _keep
          ? this.errorMessage
          : errorMessage as String?,
      successMessage: successMessage == _keep
          ? this.successMessage
          : successMessage as String?,
      scannedBooking: scannedBooking == _keep
          ? this.scannedBooking
          : scannedBooking as ScanBookingResponse?,
      searchQuery: searchQuery == _keep
          ? this.searchQuery
          : searchQuery as String?,
      kycStatus: kycStatus == _keep ? this.kycStatus : kycStatus as String?,
      roomType: roomType == _keep ? this.roomType : roomType as String?,
      hostelId: hostelId == _keep ? this.hostelId : hostelId as String?,
      occupancy: occupancy ?? this.occupancy,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadMore: isLoadMore ?? this.isLoadMore,
    );
  }

  @override
  List<Object?> get props => [
    status,
    bookings,
    pendingBookings,
    errorMessage,
    successMessage,
    scannedBooking,
    searchQuery,
    kycStatus,
    roomType,
    hostelId,
    occupancy,
    page,
    hasMore,
    isLoadMore,
  ];
}
