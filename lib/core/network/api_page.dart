class ApiPage<T> {
  const ApiPage({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
  });

  final List<T> items;
  final int page;
  final int pageSize;
  final int total;
  final int totalPages;
}

class ApiListQuery {
  const ApiListQuery({
    this.page = 1,
    this.pageSize = 20,
    this.search,
    this.sortBy,
    this.sortOrder = 'desc',
  });

  final int page;
  final int pageSize;
  final String? search;
  final String? sortBy;
  final String sortOrder;

  Map<String, dynamic> toQueryParameters({
    Map<String, dynamic> filters = const {},
  }) {
    return {
      'page': page,
      'pageSize': pageSize,
      'sortOrder': sortOrder,
      if (search != null && search!.trim().isNotEmpty) 'search': search!.trim(),
      if (sortBy != null && sortBy!.trim().isNotEmpty) 'sortBy': sortBy!.trim(),
      ...filters,
    };
  }
}
