import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stayindia_owner/features/bookings/domain/booking.dart';
import 'package:stayindia_owner/features/bookings/domain/usecases/get_bookings_usecase.dart';
import 'package:stayindia_owner/features/bookings/domain/usecases/scan_booking_usecase.dart';
import 'package:stayindia_owner/features/bookings/domain/usecases/finalize_checkin_usecase.dart';
import 'package:stayindia_owner/features/bookings/domain/usecases/checkout_booking_usecase.dart';
import 'package:stayindia_owner/features/bookings/domain/usecases/cancel_booking_usecase.dart';
import 'package:stayindia_owner/features/profile/domain/usecases/room_usecases.dart';
import 'package:stayindia_owner/features/dashboard/data/models/occupancy_model.dart';
import 'package:stayindia_owner/core/utils/error_helper.dart';
import 'bookings_state.dart';
import 'package:stayindia_owner/features/bookings/domain/settlement_payment.dart';

class BookingsCubit extends Cubit<BookingsState> {
  final GetBookingsUseCase getBookingsUseCase;
  final ScanBookingUseCase scanBookingUseCase;
  final FinalizeCheckinUseCase finalizeCheckinUseCase;
  final CheckoutBookingUseCase checkoutBookingUseCase;
  final CancelBookingUseCase cancelBookingUseCase;
  final GetOccupancyUseCase getOccupancyUseCase;

  BookingsCubit({
    required this.getBookingsUseCase,
    required this.scanBookingUseCase,
    required this.finalizeCheckinUseCase,
    required this.checkoutBookingUseCase,
    required this.cancelBookingUseCase,
    required this.getOccupancyUseCase,
  }) : super(const BookingsState());

  Future<void> fetchBookings({
    String? kycStatus,
    String? roomType,
    String? hostelId,
  }) async {
    if (isClosed) return;

    final newKycStatus = kycStatus == null
        ? state.kycStatus
        : (kycStatus.isEmpty ? null : kycStatus);
    final newRoomType = roomType == null
        ? state.roomType
        : (roomType.isEmpty ? null : roomType);
    final newHostelId = hostelId ?? state.hostelId;

    emit(
      state.copyWith(
        status: BookingsStatus.loading,
        page: 1,
        hasMore: true,
        bookings: [],
        errorMessage: null,
        successMessage: null,
        kycStatus: kycStatus == null
            ? state.kycStatus
            : (kycStatus.isEmpty ? null : kycStatus),
        roomType: roomType == null
            ? state.roomType
            : (roomType.isEmpty ? null : roomType),
        hostelId: newHostelId,
      ),
    );
    try {
      final bookings = await getBookingsUseCase.execute(
        page: 1,
        kycStatus: newKycStatus,
        roomType: newRoomType,
        hostelId: newHostelId,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          status: BookingsStatus.success,
          bookings: bookings,
          hasMore: bookings.length >= 10,
        ),
      );
    } catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            status: BookingsStatus.failure,
            errorMessage: ErrorHelper.toFriendlyMessage(e),
          ),
        );
      }
    }
  }

  Future<void> loadMoreBookings() async {
    if (isClosed) return;
    if (state.isLoadMore || !state.hasMore) return;

    emit(state.copyWith(isLoadMore: true));
    try {
      final nextPage = state.page + 1;
      final newBookings = await getBookingsUseCase.execute(
        page: nextPage,
        kycStatus: state.kycStatus,
        roomType: state.roomType,
        hostelId: state.hostelId,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          status: BookingsStatus.success,
          bookings: [...state.bookings, ...newBookings],
          page: nextPage,
          hasMore: newBookings.length >= 10,
          isLoadMore: false,
        ),
      );
    } catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isLoadMore: false,
            errorMessage: 'Could not load more bookings',
          ),
        );
      }
    }
  }

  void changeFilter({String? kycStatus, String? roomType}) {
    fetchBookings(kycStatus: kycStatus, roomType: roomType);
  }

  Future<void> scanBooking(
    String token, {
    String? hostelId,
    String? bookingId,
  }) async {
    emit(
      state.copyWith(
        status: BookingsStatus.loading,
        errorMessage: null,
        successMessage: null,
      ),
    );
    try {
      final response = await scanBookingUseCase.execute(
        token,
        hostelId: hostelId,
        bookingId: bookingId,
      );
      emit(
        state.copyWith(
          status: BookingsStatus.success,
          scannedBooking: response,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: BookingsStatus.failure,
          errorMessage: ErrorHelper.toFriendlyMessage(e),
        ),
      );
    }
  }

  Future<void> manualCheckin(
    String accessCode, {
    String? hostelId,
    String? bookingId,
  }) async {
    emit(
      state.copyWith(
        status: BookingsStatus.loading,
        errorMessage: null,
        successMessage: null,
      ),
    );
    try {
      final response = await scanBookingUseCase.execute(
        accessCode,
        hostelId: hostelId,
        bookingId: bookingId,
        isManual: true,
      );
      emit(
        state.copyWith(
          status: BookingsStatus.success,
          scannedBooking: response,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: BookingsStatus.failure,
          errorMessage: ErrorHelper.toFriendlyMessage(e),
        ),
      );
    }
  }

  Future<void> fetchOccupancy(String hostelId) async {
    emit(
      state.copyWith(
        status: BookingsStatus.loading,
        errorMessage: null,
        successMessage: null,
      ),
    );
    try {
      final summary = await getOccupancyUseCase(hostelId);
      emit(
        state.copyWith(
          status: BookingsStatus.success,
          occupancy: summary as OccupancyModel,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: BookingsStatus.failure,
          errorMessage: ErrorHelper.toFriendlyMessage(e),
        ),
      );
    }
  }

  Future<void> finalizeCheckin({
    required String bookingId,
    required String roomId,
    required String bedNumber,
    String? accessCode,
    List<Map<String, String>>? documents,
  }) async {
    if (isClosed) return;
    emit(
      state.copyWith(
        status: BookingsStatus.loading,
        errorMessage: null,
        successMessage: null,
      ),
    );
    try {
      await finalizeCheckinUseCase.execute(
        bookingId: bookingId,
        roomId: roomId,
        bedNumber: bedNumber,
        accessCode: accessCode,
        documents: documents,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          status: BookingsStatus.success,
          successMessage: 'Check-in finalized successfully!',
          bookings: state.bookings
              .map(
                (b) => b.id == bookingId
                    ? b.copyWith(status: BookingStatus.checkedIn)
                    : b,
              )
              .toList(),
        ),
      );
    } catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            status: BookingsStatus.failure,
            errorMessage: ErrorHelper.toFriendlyMessage(e),
          ),
        );
      }
    }
  }

  Future<void> checkoutBooking(
    String bookingId, {
    double? securityDeposit,
    double? pendingRent,
    double? utilityDue,
    double? finalSettlement,
    List<SettlementPayment> settlementPayments = const [],
  }) async {
    if (isClosed) return;
    emit(state.copyWith(status: BookingsStatus.loading));
    try {
      await checkoutBookingUseCase.execute(
        bookingId,
        securityDeposit: securityDeposit,
        pendingRent: pendingRent,
        utilityDue: utilityDue,
        finalSettlement: finalSettlement,
        settlementPayments: settlementPayments,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          status: BookingsStatus.success,
          successMessage: 'Checked out successfully!',
          bookings: state.bookings
              .map(
                (b) => b.id == bookingId
                    ? b.copyWith(status: BookingStatus.checkedOut)
                    : b,
              )
              .toList(),
        ),
      );
    } catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            status: BookingsStatus.failure,
            errorMessage: ErrorHelper.toFriendlyMessage(e),
          ),
        );
      }
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    if (isClosed) return;
    emit(state.copyWith(status: BookingsStatus.loading));
    try {
      await cancelBookingUseCase.execute(bookingId);
      if (isClosed) return;
      emit(
        state.copyWith(
          status: BookingsStatus.success,
          successMessage: 'Booking cancelled successfully!',
          bookings: state.bookings
              .map(
                (b) => b.id == bookingId
                    ? b.copyWith(status: BookingStatus.cancelled)
                    : b,
              )
              .toList(),
        ),
      );
    } catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            status: BookingsStatus.failure,
            errorMessage: ErrorHelper.toFriendlyMessage(e),
          ),
        );
      }
    }
  }

  void searchBookings(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void clearScannedBooking() {
    emit(state.copyWith(scannedBooking: null));
  }
}
