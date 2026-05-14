import 'package:equatable/equatable.dart';
import '../../../domain/entities/tenant.dart';

enum TenantsStatus { initial, loading, success, failure }

// Added pagination fields


class TenantsState extends Equatable {
  final TenantsStatus status;
  final List<Tenant> tenants;
  final String? errorMessage;
  final int page;
  final bool hasReachedMax;
  final TenantsStatus status;
  final List<Tenant> tenants;
  final String? errorMessage;

  const TenantsState({
    this.status = TenantsStatus.initial,
    this.tenants = const [],
    this.errorMessage,
    this.page = 1,
    this.hasReachedMax = false,
  });

  TenantsState copyWith({
    TenantsStatus? status,
    List<Tenant>? tenants,
    String? errorMessage,
    int? page,
    bool? hasReachedMax,
  }) {
    return TenantsState(
      status: status ?? this.status,
      tenants: tenants ?? this.tenants,
      errorMessage: errorMessage ?? this.errorMessage,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
    return TenantsState(
      status: status ?? this.status,
      tenants: tenants ?? this.tenants,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, tenants, errorMessage];
}
