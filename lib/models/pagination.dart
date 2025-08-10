import 'package:freezed_annotation/freezed_annotation.dart';

part 'pagination.freezed.dart';
part 'pagination.g.dart';

@freezed
abstract class Pagination with _$Pagination {
  const factory Pagination({
    required int totalCount,
    required int pageNumber,
    required int pageCount,
    required String? previousPageUrl,
    required String? nextPageUrl,
  }) = _Pagination;

  factory Pagination.fromJson(Map<String, Object?> json) =>
      _$PaginationFromJson(json);
}
