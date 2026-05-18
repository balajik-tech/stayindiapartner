import 'package:equatable/equatable.dart';
import 'package:stayindia_owner/features/tenants/domain/entities/tenant_entity.dart';

abstract class TenantState extends Equatable {
  const TenantState();
  @override
  List<Object?> get props => [];
}

class TenantInitial extends TenantState {}

class TenantLoading extends TenantState {}

class TenantLoaded extends TenantState {
  final List<TenantEntity> tenants;
  final String? searchQuery;
  final bool hasMore;
  final bool isLoadMore;
  final int page;
  final String? errorMessage;

  const TenantLoaded({
    required this.tenants,
    this.searchQuery,
    this.hasMore = false,
    this.isLoadMore = false,
    this.page = 1,
    this.errorMessage,
  });

  TenantLoaded copyWith({
    List<TenantEntity>? tenants,
    String? searchQuery,
    bool? hasMore,
    bool? isLoadMore,
    int? page,
    String? errorMessage,
  }) {
    return TenantLoaded(
      tenants: tenants ?? this.tenants,
      searchQuery: searchQuery ?? this.searchQuery,
      hasMore: hasMore ?? this.hasMore,
      isLoadMore: isLoadMore ?? this.isLoadMore,
      page: page ?? this.page,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    tenants,
    searchQuery,
    hasMore,
    isLoadMore,
    page,
    errorMessage,
  ];
}

class TenantEmpty extends TenantState {
  final String? message;
  const TenantEmpty({this.message});
  @override
  List<Object?> get props => [message];
}

class TenantError extends TenantState {
  final String message;
  const TenantError({required this.message});
  @override
  List<Object?> get props => [message];
}

abstract class TenantDetailState extends Equatable {
  const TenantDetailState();
  @override
  List<Object?> get props => [];
}

class TenantDetailInitial extends TenantDetailState {}

class TenantDetailLoading extends TenantDetailState {}

class TenantDetailLoaded extends TenantDetailState {
  final TenantDetailEntity detail;
  const TenantDetailLoaded(this.detail);
  @override
  List<Object?> get props => [detail];
}

class TenantDetailError extends TenantDetailState {
  final String message;
  const TenantDetailError(this.message);
  @override
  List<Object?> get props => [message];
}
