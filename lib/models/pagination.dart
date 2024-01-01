class Pagination {
  final int totalCount;
  final int pageNumber;
  final int pageCount;
  final String? previousPageUrl;
  final String? nextPageUrl;

  const Pagination({
    required this.totalCount,
    required this.pageNumber,
    required this.pageCount,
    required this.previousPageUrl,
    required this.nextPageUrl,
  });

  @override
  String toString() {
    return {
      'totalCount': totalCount,
      'pageNumber': pageNumber,
      'pageCount': pageCount,
      'previousPageUrl': previousPageUrl,
      'nextPageUrl': nextPageUrl,
    }.toString();
  }
}
