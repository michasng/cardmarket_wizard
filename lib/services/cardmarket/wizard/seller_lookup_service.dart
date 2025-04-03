import 'package:cardmarket_wizard/models/enums/location.dart';
import 'package:cardmarket_wizard/models/enums/want_type.dart';
import 'package:cardmarket_wizard/models/price_optimizer/price_optimizer_result.dart';
import 'package:cardmarket_wizard/models/seller_singles/seller_singles_article.dart';
import 'package:cardmarket_wizard/models/wants/wants.dart';
import 'package:cardmarket_wizard/services/browser_holder.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/seller_singles_page.dart';
import 'package:collection/collection.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:micha_core/micha_core.dart';

class SellerLookupService {
  static SellerLookupService? _instance;

  const SellerLookupService._internal();

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
          .where(
            (wantsArticle) => wantsArticle.productId == sellerArticle.productId,
          )
          .firstOrNull;
      final fuzzyNameMatch = extractOne(
        query: sellerArticle.name,
        choices: wants.articles,
        getter: (wantsArticle) => wantsArticle.name,
      );
      final offers = sellerOffers.putIfAbsent(
        (exactIdMatch ?? fuzzyNameMatch.choice).productId,
        () => [],
      );

      sellerArticle.offer.quantity
          .times((_) => offers.add(sellerArticle.offer.priceEuroCents));
    }

    // Seller offers are not pre-sorted. "Sort by Name (A to Z)" is selected.
    // Even if "Sort by Price (cheapest first)" is selected, cardmarked refuses to sort when there are too many offers.
    for (final offers in sellerOffers.values) {
      offers.sort();
    }

    return (location, sellerOffers);
  }
}
