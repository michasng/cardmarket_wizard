import 'package:freezed_annotation/freezed_annotation.dart';

part 'pagination.freezed.dart';

@freezed
abstract class Pagination with _$Pagination {
  const factory Pagination({
    required int totalCount,
    required int pageNumber,
    required int pageCount,
    required String? previousPageUrl,
    required String? nextPageUrl,
  }) = _Pagination;
}
