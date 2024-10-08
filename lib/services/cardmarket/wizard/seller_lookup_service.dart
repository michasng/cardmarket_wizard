import 'package:cardmarket_wizard/models/enums/location.dart';
import 'package:cardmarket_wizard/models/enums/want_type.dart';
import 'package:cardmarket_wizard/models/price_optimizer/price_optimizer_result.dart';
import 'package:cardmarket_wizard/models/seller_singles/seller_singles_article.dart';
import 'package:cardmarket_wizard/models/wants/wants.dart';
import 'package:cardmarket_wizard/services/browser_holder.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/seller_singles_page.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';

class SellerLookupService {
  static SellerLookupService? _instance;

  SellerLookupService._internal();

  factory SellerLookupService.instance() {
    return _instance ??= SellerLookupService._internal();
  }

  Future<(Location, WantsPrices)> lookupSeller({
    required Wants wants,
    required String sellerName,
  }) async {
    final browserHolder = BrowserHolder.instance();

    List<SellerSinglesArticle> sellerArticles = [];
    var sellerSinglesPage = await SellerSinglesPage.goTo(
      sellerName,
      wantsId: wants.id,
    );
    Location location;
    while (true) {
      final sellerSingles = await sellerSinglesPage.parse();
      sellerArticles.addAll(sellerSingles.articles);
      final url = sellerSingles.pagination.nextPageUrl;
      if (url == null) {
        location = sellerSingles.location;
        break;
      }
      await browserHolder.goTo(url);
      sellerSinglesPage = await SellerSinglesPage.fromCurrentPage();
    }
    final WantsPrices sellerOffers = {};
    final singlesWantsArticles =
        wants.articles.where((article) => article.wantType == WantType.single);
    for (final sellerArticle in sellerArticles) {
      final exactIdMatch = singlesWantsArticles
          .where((article) => article.id == sellerArticle.id)
          .firstOrNull;
      final fuzzyNameMatch = extractOne(
        query: sellerArticle.name,
        choices: wants.articles,
        getter: (wantsArticle) => wantsArticle.name,
      );
      sellerOffers
          .putIfAbsent((exactIdMatch ?? fuzzyNameMatch.choice).id, () => [])
          .add(sellerArticle.offer.priceEuroCents);
    }
    return (location, sellerOffers);
  }
}
