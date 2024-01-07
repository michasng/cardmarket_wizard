import 'dart:async';

import 'package:cardmarket_wizard/models/article_offer.dart';
import 'package:cardmarket_wizard/models/article_seller.dart';
import 'package:cardmarket_wizard/models/card.dart';
import 'package:cardmarket_wizard/models/enums/card_condition.dart';
import 'package:cardmarket_wizard/models/enums/card_language.dart';
import 'package:cardmarket_wizard/models/enums/location.dart';
import 'package:cardmarket_wizard/models/enums/seller_rating.dart';
import 'package:cardmarket_wizard/models/enums/seller_type.dart';
import 'package:cardmarket_wizard/services/browser_holder.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/cardmarket_page.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/helpers.dart';
import 'package:cardmarket_wizard/services/currency.dart';
import 'package:html/dom.dart';
import 'package:micha_core/micha_core.dart';

class CardPage extends CardmarketPage {
  static final RegExp _positiveIntegersPattern = RegExp(r'\d+');
  static final RegExp _etaPattern = RegExp(r':\s*(\d+)');

  CardPage({required super.page})
      : super(
          isAt: CardmarketPage.createIsAt(r'\/Cards\/(?<card_id>[\w\d-]+)'),
        );

  ArticleSeller _parseArticleSeller(Element column) {
    final sellerExtendedTooltips =
        column.querySelectorAll('.seller-extended $tooltipSelector');
    final sellerRatingTooltip =
        sellerExtendedTooltips.firstOrNull?.transform(takeTooltipText);
    final explicitSellerRating =
        SellerRating.values.cast<SellerRating?>().firstWhere(
              (value) => value?.label == sellerRatingTooltip,
              orElse: () => null,
            );
    final saleAndItemCountsTooltip = sellerExtendedTooltips
        .firstWhere((tooltip) => tooltip.classes.contains('sell-count'))
        .transform(takeTooltipText);
    final saleAndItemCounts = saleAndItemCountsTooltip
        ?.transform((tooltip) => _positiveIntegersPattern.allMatches(tooltip))
        .map((match) => int.tryParse(match.group(0)!));
    final estimatedTimesOfArrival = column
        .querySelector('.fonticon-calendar$tooltipSelector')
        ?.transform(takeTooltipText)
        ?.transform((tooltip) => _etaPattern.allMatches(tooltip))
        .map((match) => int.tryParse(match.group(1)!));

    final sellerNameTooltipTexts = column
        .querySelectorAll('.seller-name $tooltipSelector')
        .map((e) => takeTooltipText(e)!);
    final explicitSellerType = SellerType.values.cast<SellerType?>().firstWhere(
          (value) => value?.label == sellerNameTooltipTexts.skip(1).firstOrNull,
          orElse: () => null,
        );

    final locationLabel =
        sellerNameTooltipTexts.first.replaceFirst('Item location: ', '');

    return ArticleSeller(
      name: column.querySelector('.seller-name a')!.text,
      rating: explicitSellerRating,
      saleCount: saleAndItemCounts?.firstOrNull,
      itemCount: saleAndItemCounts?.skip(1).firstOrNull,
      etaDays: estimatedTimesOfArrival?.firstOrNull,
      etaLocationDays: estimatedTimesOfArrival?.skip(1).firstOrNull,
      location: Location.byLabel(locationLabel),
      sellerType: explicitSellerType ?? SellerType.private,
      warnings: sellerNameTooltipTexts
          .skip(1 + (explicitSellerType == null ? 0 : 1))
          .toList(),
    );
  }

  CardArticleInfo _parseArticleInfo(Element column) {
    final productAttributes = column.querySelector('.product-attributes')!;
    final expansionElement =
        productAttributes.querySelector('.expansion-symbol')!;
    final conditionElement =
        productAttributes.querySelector('.article-condition')!;

    return CardArticleInfo(
      expansion: expansionElement.text,
      rarity: expansionElement.nextElementSibling!.transform(takeTooltipText)!,
      condition: CardCondition.byAbbreviation(conditionElement.text),
      language: CardLanguage.byLabel(
          takeTooltipText(conditionElement.nextElementSibling!)!),
      isReverseHolo:
          productAttributes.querySelector(selectTooltip('Reverse Holo')) !=
              null,
      isSigned:
          productAttributes.querySelector(selectTooltip('Signed')) != null,
      isFirstEdition:
          productAttributes.querySelector(selectTooltip('First Edition')) !=
              null,
      isAltered:
          productAttributes.querySelector(selectTooltip('Altered')) != null,
      imageUrl: productAttributes
          .querySelector('.fonticon-camera$tooltipSelector')
          ?.transform(takeTooltipText)
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
      quantity:
          column.querySelector('.amount-container')!.text.transform(int.parse),
    );
  }

  CardArticle _parseCardArticle(Element row) {
    return CardArticle(
      imageUrl: row
          .querySelector('.col-icon $tooltipSelector')
          ?.transform(takeTooltipText)
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
    final articleRows =
        document.querySelectorAll('.article-table .table-body > .row');

    return Card(
      name: document.querySelector('h1')!.text,
      totalArticleCount: productAvailability?['No. of Available Items']
          ?.text
          .transform(int.tryParse),
      versionCount:
          productAvailability?['No. of Versions']?.text.transform(int.tryParse),
      minPriceEuroCents: productAvailability?['Available from']
          ?.text
          .transform(tryParseEuroCents),
      priceTrendEuroCents: productAvailability?['Price Trend']
          ?.text
          .transform(tryParseEuroCents),
      rulesText: document.querySelector('#info .infoContainer > div')?.text,
      articles: [
        for (final row in articleRows) _parseCardArticle(row),
      ],
    );
  }

  static Uri createUrl(
    String cardId, {
    List<CardLanguage>? languages,
    CardCondition? minCondition,
  }) {
    final url = Uri.parse(CardmarketPage.baseUrl).replace(
      pathSegments: [
        ...CardmarketPage.basePathSegments,
        'Cards',
        cardId,
      ],
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
    return CardPage(page: await holder.currentPage);
  }
}
