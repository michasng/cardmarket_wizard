import 'package:cardmarket_wizard/models/wants/wants_article.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'wants.freezed.dart';
part 'wants.g.dart';

@freezed
class Wants with _$Wants {
  const factory Wants({
    required String title,
    required String id,
    required List<WantsArticle> articles,
  }) = _Wants;

  factory Wants.fromJson(Map<String, Object?> json) => _$WantsFromJson(json);
}
