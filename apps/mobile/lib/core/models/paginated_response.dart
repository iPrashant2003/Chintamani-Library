class PaginatedResponse<T> {
  final List<T> data;
  final int total;
  final int page;
  final int limit;

  const PaginatedResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final rawList = json['data'] as List<dynamic>? ?? [];
    final items = rawList
        .map((item) => fromJsonT(item as Map<String, dynamic>))
        .toList();

    return PaginatedResponse<T>(
      data: items,
      total: (json['total'] as num?)?.toInt() ?? items.length,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? items.length,
    );
  }

  bool get hasMore => (page * limit) < total;
}
