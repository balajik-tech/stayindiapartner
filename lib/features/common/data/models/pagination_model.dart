class PaginationModel {
  final int totalResults;
  final int totalPages;
  final int currentPage;
  final int limit;
  final bool hasNextPage;
  final bool hasPrevPage;

  PaginationModel({
    required this.totalResults,
    required this.totalPages,
    required this.currentPage,
    required this.limit,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      totalResults: json['totalResults'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
      limit: json['limit'] ?? 10,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPrevPage: json['hasPrevPage'] ?? false,
    );
  }

  factory PaginationModel.empty() {
    return PaginationModel(
      totalResults: 0,
      totalPages: 0,
      currentPage: 1,
      limit: 10,
      hasNextPage: false,
      hasPrevPage: false,
    );
  }
}

class PaginatedResponse<T> {
  final List<T> results;
  final PaginationModel pagination;

  PaginatedResponse({
    required this.results,
    required this.pagination,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final resultsJson = json['results'] as List<dynamic>? ?? [];
    return PaginatedResponse(
      results: resultsJson.map((item) => fromJsonT(item as Map<String, dynamic>)).toList(),
      pagination: PaginationModel.fromJson(json['pagination'] ?? {}),
    );
  }
}
