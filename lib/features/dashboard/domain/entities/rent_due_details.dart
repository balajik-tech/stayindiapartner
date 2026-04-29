import 'package:equatable/equatable.dart';

class RentDueDetails extends Equatable {
  final List<RentPayment> overdue;
  final List<RentPayment> upcoming;

  const RentDueDetails({
    required this.overdue,
    required this.upcoming,
  });

  @override
  List<Object?> get props => [overdue, upcoming];
}

class RentPayment extends Equatable {
  final String id;
  final String tenantName;
  final String tenantMobile;
  final String? tenantAvatar;
  final double amount;
  final DateTime dueDate;
  final String month;

  const RentPayment({
    required this.id,
    required this.tenantName,
    required this.tenantMobile,
    this.tenantAvatar,
    required this.amount,
    required this.dueDate,
    required this.month,
  });

  @override
  List<Object?> get props => [id, tenantName, tenantMobile, tenantAvatar, amount, dueDate, month];
}
