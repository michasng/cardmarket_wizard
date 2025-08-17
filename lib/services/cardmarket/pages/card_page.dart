import 'dart:async';

import 'package:cardmarket_wizard/models/card/card_article.dart';
import 'package:cardmarket_wizard/models/card/card_article_info.dart';
import 'package:cardmarket_wizard/models/enums/card_condition.dart';
import 'package:cardmarket_wizard/models/enums/card_language.dart';
import 'package:cardmarket_wizard/models/enums/location.dart';
import 'package:cardmarket_wizard/models/enums/seller_rating.dart';
import 'package:cardmarket_wizard/models/enums/seller_type.dart';
import 'package:cardmarket_wizard/models/interfaces/article_offer.dart';
import 'package:cardmarket_wizard/models/interfaces/article_seller.dart';
import 'package:cardmarket_wizard/models/interfaces/product.dart';
import 'package:cardmarket_wizard/services/browser_holder.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/cardmarket_page.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/helpers.dart';
import 'package:cardmarket_wizard/services/currency.dart';
import 'package:html/dom.dart';
import 'package:micha_core/micha_core.dart';

class CardPage extends CardmarketPage {
  static final RegExp _rowIdPattern = RegExp(r'^articleRow(?<id>\d+)$');
  static final RegExp _positiveIntegersPattern = RegExp(r'\d+');
  static final RegExp _etaPattern = RegExp(r':\s*(\d+)');

  CardPage._({required super.page})
    : super(pathPattern: r'\/Cards\/(?<card_id>[\w\d-]+)');

  ArticleSeller _parseArticleSeller(Element column) {
    final sellerExtendedTooltips = column.querySelectorAll(
      '.seller-extended $tooltipSelector',
    );
    final sellerRatingTooltip = sellerExtendedTooltips.firstOrNull?.transform(
      takeTooltipTitle,
    );
    final explicitSellerRating = SellerRating.values
        .cast<SellerRating?>()
        .firstWhere(
          (value) => value?.label == sellerRatingTooltip,
          orElse: () => null,
        );
    final saleAndItemCountsTooltip = sellerExtendedTooltips
        .firstWhere((tooltip) => tooltip.classes.contains('sell-count'))
        .transform(takeTooltipTitle)!;
    final saleAndItemCounts = saleAndItemCountsTooltip
        .transform((tooltip) => _positiveIntegersPattern.allMatches(tooltip))
        .map((match) => int.parse(match.group(0)!));
    final estimatedTimesOfArrival = column
        .querySelector('.fonticon-calendar$tooltipSelector')!
        .transform(takeTooltipTitle)!
        .transform((tooltip) => _etaPattern.allMatches(tooltip))
        .map((match) => int.tryParse(match.group(1)!));

    final sellerNameTooltipTexts = column
        .querySelectorAll('.seller-name $tooltipSelector')
        .map((e) => takeTooltipTitle(e)!);
    final explicitSellerType = SellerType.values.cast<SellerType?>().firstWhere(
      (value) => value?.label == sellerNameTooltipTexts.skip(1).firstOrNull,
      orElse: () => null,
    );

    final locationLabel = sellerNameTooltipTexts.first.replaceFirst(
      'Item location: ',
      '',
    );

    return ArticleSeller(
      name: column.querySelector('.seller-name a')!.text,
      rating: explicitSellerRating,
      saleCount: saleAndItemCounts.first,
      itemCount: saleAndItemCounts.last,
      // etaDays comes before etaLocationDays, but etaDays can be missing
      etaDays: estimatedTimesOfArrival.toList().reversed.skip(1).firstOrNull,
      etaLocationDays: estimatedTimesOfArrival.last!,
      location: Location.byLabel(locationLabel),
      sellerType: explicitSellerType ?? SellerType.private,
      warnings: sellerNameTooltipTexts
          .skip(1 + (explicitSellerType == null ? 0 : 1))
          .toList(),
    );
  }

  CardArticleInfo _parseArticleInfo(Element column) {
    final productAttributes = column.querySelector('.product-attributes')!;
    final expansionElement = productAttributes.querySelector(
      '.expansion-symbol',
    )!;
    final conditionElement = productAttributes.querySelector(
      '.article-condition',
    )!;

    return CardArticleInfo(
      expansion: expansionElement.text,
      rarity: expansionElement.nextElementSibling!.transform(takeTooltipTitle)!,
      condition: CardCondition.byAbbreviation(conditionElement.text),
      language: CardLanguage.byLabel(
        takeTooltipTitle(conditionElement.nextElementSibling!)!,
      ),
      isReverseHolo:
          productAttributes.querySelector(
            selectOriginalTooltip('Reverse Holo'),
          ) !=
          null,
      isSigned:
          productAttributes.querySelector(selectOriginalTooltip('Signed')) !=
          null,
      isFirstEdition:
          productAttributes.querySelector(
            selectOriginalTooltip('First Edition'),
          ) !=
          null,
      isAltered:
          productAttributes.querySelector(selectOriginalTooltip('Altered')) !=
          null,
      imageUrl: productAttributes
          .querySelector('.fonticon-camera$tooltipSelector')
          ?.transform(takeTooltipTitle)
          ?.transform(extractImageUrl),
      comment: column.querySelector('.product-comments')?.text,
    );
  }

  ArticleOffer _parseArticleOffer(Element column) {
    return ArticleOffer(
      priceEuroCents: column
          .querySelector('.price-container')!
          .text
          .transform(parseEuroCents),
      quantity: column
          .querySelector('.amount-container')!
          .text
          .transform(int.parse),
    );
  }

  CardArticle _parseCardArticle(Element row) {
    return CardArticle(
      id: _rowIdPattern.firstMatch(row.id)!.namedGroup('id')!,
      imageUrl: row
          .querySelector('.col-icon $tooltipSelector')
          ?.transform(takeTooltipTitle)
          ?.transform(extractImageUrl),
      seller: _parseArticleSeller(row.querySelector('.col-seller')!),
      info: _parseArticleInfo(row.querySelector('.col-product')!),
      offer: _parseArticleOffer(row.querySelector('.col-offer')!),
    );
  }

  Future<Card> parse() async {
    final document = await parseDocument();

    final productAvailability = document
        .querySelector('#info .infoContainer dl')
        ?.transform(definitionListToMap);
    final articleRows = document.querySelectorAll(
      '.article-table .table-body > .row',
    );

    return Card(
      name: document.querySelector('h1')!.text,
      totalArticleCount: productAvailability?['No. of Available Items']?.text
          .transform(int.tryParse),
      versionCount: productAvailability?['No. of Versions']?.text.transform(
        int.tryParse,
      ),
      minPriceEuroCents: productAvailability?['Available from']?.text.transform(
        tryParseEuroCents,
      ),
      priceTrendEuroCents: productAvailability?['Price Trend']?.text.transform(
        tryParseEuroCents,
      ),
      rulesText: document.querySelector('#info .infoContainer > div')?.text,
      articles: [for (final row in articleRows) _parseCardArticle(row)],
    );
  }

  static Future<CardPage> goTo(
    String cardId, {
    List<CardLanguage>? languages,
    CardCondition? minCondition,
  }) async {
    final url = _createUrl(
      cardId,
      languages: languages,
      minCondition: minCondition,
    );
    final browserHolder = BrowserHolder.instance();
    await browserHolder.goTo(url.toString());
    final page = await browserHolder.currentPage;
    final instance = CardPage._(page: page);
    return instance;
  }

  static Uri _createUrl(
    String cardId, {
    List<CardLanguage>? languages,
    CardCondition? minCondition,
  }) {
    final url = Uri.parse(CardmarketPage.baseUrl).replace(
      pathSegments: [...CardmarketPage.basePathSegments, 'Cards', cardId],
      queryParameters: <String, String>{
        if (languages != null)
          'language': languages.map((language) => language.ordinal).join(','),
        if (minCondition != null)
          'minCondition': minCondition.ordinal.toString(),
      }.nullWhenEmpty,
    );
    return url;
  }

  static Future<CardPage> fromCurrentPage() async {
    final holder = BrowserHolder.instance();
    final instance = CardPage._(page: await holder.currentPage);
    return instance;
  }
}
