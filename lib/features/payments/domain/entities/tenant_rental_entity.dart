import 'package:equatable/equatable.dart';
import 'package:stayindia_owner/features/tenants/domain/entities/tenant_entity.dart';

class TenantRentalEntity extends Equatable {
  final String id;
  final double bookingAmount;
  final double deposit;
  final double maintenance;
  final double electricityBill;
  final double parkingBill;
  final double discountAmount;
  final double payableAmount;
  final String currency;
  final String? receiptNumber;
  final String paymentStatus;
  final String transferStatus;
  final String? paymentDate;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;
  final TenantRentalBookingEntity? booking;
  final TenantRentalPaymentDetailEntity? payment;

  const TenantRentalEntity({
    required this.id,
    required this.bookingAmount,
    required this.deposit,
    required this.maintenance,
    required this.electricityBill,
    required this.parkingBill,
    required this.discountAmount,
    required this.payableAmount,
    required this.currency,
    this.receiptNumber,
    required this.paymentStatus,
    required this.transferStatus,
    this.paymentDate,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.booking,
    this.payment,
  });

  bool get isPaid {
    final status = paymentStatus.toUpperCase();
    final pStatus = (payment?.status ?? '').toUpperCase();
    return status == 'SUCCESS' || status == 'PAID' || pStatus == 'SUCCESS';
  }

  TenantPaymentItemEntity toTenantPaymentItemEntity() {
    final dateStr = paymentDate ?? createdAt ?? booking?.checkInDate ?? '';
    final paid = isPaid;
    final bStatus = booking?.status;

    String displayStatus;
    if (paid) {
      displayStatus = 'PAID';
    } else if (bStatus != null && bStatus.isNotEmpty) {
      displayStatus = bStatus == 'CHECKED_IN'
          ? 'CHECKED IN'
          : bStatus.replaceAll('_', ' ').toUpperCase();
    } else {
      displayStatus =
          paymentStatus.isNotEmpty ? paymentStatus.toUpperCase() : 'PENDING';
    }

    final totalAmt = payableAmount > 0 ? payableAmount : bookingAmount;
    final paidAmt = paid ? totalAmt : (payment?.amount ?? 0.0);
    final dueAmt = paid ? 0.0 : totalAmt;

    return TenantPaymentItemEntity(
      id: id,
      month: dateStr,
      totalAmount: totalAmt,
      paidAmount: paidAmt,
      dueAmount: dueAmt,
      status: displayStatus,
      paymentType: payment?.method ?? 'RENT',
      paymentDate: dateStr.isNotEmpty ? dateStr : null,
      dueDate: booking?.endDate,
    );
  }

  @override
  List<Object?> get props => [
        id,
        bookingAmount,
        deposit,
        maintenance,
        electricityBill,
        parkingBill,
        discountAmount,
        payableAmount,
        currency,
        receiptNumber,
        paymentStatus,
        transferStatus,
        paymentDate,
        notes,
        createdAt,
        updatedAt,
        booking,
        payment,
      ];
}

class TenantRentalBookingEntity extends Equatable {
  final String id;
  final String? sharingType;
  final String? bookingType;
  final String? bedNumber;
  final String? startDate;
  final String? endDate;
  final String? checkInDate;
  final double rent;
  final double deposit;
  final double maintenance;
  final String? status;
  final String? paymentStatus;
  final TenantRentalRoomEntity? room;

  const TenantRentalBookingEntity({
    required this.id,
    this.sharingType,
    this.bookingType,
    this.bedNumber,
    this.startDate,
    this.endDate,
    this.checkInDate,
    required this.rent,
    required this.deposit,
    required this.maintenance,
    this.status,
    this.paymentStatus,
    this.room,
  });

  @override
  List<Object?> get props => [
        id,
        sharingType,
        bookingType,
        bedNumber,
        startDate,
        endDate,
        checkInDate,
        rent,
        deposit,
        maintenance,
        status,
        paymentStatus,
        room,
      ];
}

class TenantRentalRoomEntity extends Equatable {
  final String id;
  final String? roomTypename;
  final int floor;
  final String? roomType;
  final String? sharingType;

  const TenantRentalRoomEntity({
    required this.id,
    this.roomTypename,
    required this.floor,
    this.roomType,
    this.sharingType,
  });

  @override
  List<Object?> get props => [
        id,
        roomTypename,
        floor,
        roomType,
        sharingType,
      ];
}

class TenantRentalPaymentDetailEntity extends Equatable {
  final String? method;
  final String? status;
  final double amount;
  final String? paidAt;
  final String? reference;
  final String? notes;

  const TenantRentalPaymentDetailEntity({
    this.method,
    this.status,
    required this.amount,
    this.paidAt,
    this.reference,
    this.notes,
  });

  @override
  List<Object?> get props => [
        method,
        status,
        amount,
        paidAt,
        reference,
        notes,
      ];
}
