enum SettlementDirection { tenantToOwner, ownerToTenant }

enum SettlementPaymentMethod { cash, upi }

enum SettlementHandlerType { owner, staff, other }

/// A single money movement recorded while settling a tenant's checkout,
/// e.g. tenant paid ₹500 cash to the security guard.
class SettlementPayment {
  final String localId;
  final double amount;
  final SettlementDirection direction;
  final SettlementPaymentMethod method;
  final SettlementHandlerType handlerType;
  final String? handlerStaffId;
  final String handlerName;
  final DateTime paidAt;

  const SettlementPayment({
    required this.localId,
    required this.amount,
    required this.direction,
    required this.method,
    required this.handlerType,
    this.handlerStaffId,
    required this.handlerName,
    required this.paidAt,
  });

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'direction': direction == SettlementDirection.tenantToOwner
        ? 'TENANT_TO_OWNER'
        : 'OWNER_TO_TENANT',
    'method': method == SettlementPaymentMethod.cash ? 'CASH' : 'UPI',
    'handledBy': {
      'type': handlerType.name.toUpperCase(),
      'staffId': ?handlerStaffId,
      'name': handlerName,
    },
    'paidAt': paidAt.toUtc().toIso8601String(),
  };
}
