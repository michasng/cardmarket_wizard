import 'package:cardmarket_wizard/models/wants_article.dart';

class Wants {
  String title;
  String id;
  List<WantsArticle> articles;

  Wants({
    required this.title,
    required this.id,
    required this.articles,
  });

  @override
  String toString() {
    return {
      'title': title,
      'id': id,
      'articles': articles,
    }.toString();
  }
}
