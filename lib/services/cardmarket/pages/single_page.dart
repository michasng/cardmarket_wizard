import 'dart:async';

import 'package:cardmarket_wizard/models/enums/card_condition.dart';
import 'package:cardmarket_wizard/models/enums/card_language.dart';
import 'package:cardmarket_wizard/models/enums/location.dart';
import 'package:cardmarket_wizard/models/enums/seller_rating.dart';
import 'package:cardmarket_wizard/models/enums/seller_type.dart';
import 'package:cardmarket_wizard/models/interfaces/article_offer.dart';
import 'package:cardmarket_wizard/models/interfaces/article_seller.dart';
import 'package:cardmarket_wizard/models/single/single.dart';
import 'package:cardmarket_wizard/models/single/single_article.dart';
import 'package:cardmarket_wizard/models/single/single_article_info.dart';
import 'package:cardmarket_wizard/services/browser_holder.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/cardmarket_page.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/helpers.dart';
import 'package:cardmarket_wizard/services/currency.dart';
import 'package:html/dom.dart';
import 'package:micha_core/micha_core.dart';

class SinglePage extends CardmarketPage {
  static final RegExp _positiveIntegersPattern = RegExp(r'\d+');
  static final RegExp _etaPattern = RegExp(r':\s*(\d+)');

  SinglePage({required super.page})
      : super(
          pathPattern: r'\/Products\/Singles\/(?<single_id>[\w\d-\/]+)',
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

  SingleArticleInfo _parseArticleInfo(Element column) {
    final productAttributes = column.querySelector('.product-attributes')!;
    final conditionElement =
        productAttributes.querySelector('.article-condition')!;

    return SingleArticleInfo(
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

  SingleArticle _parseSingleArticle(Element row) {
    return SingleArticle(
      seller: _parseArticleSeller(row.querySelector('.col-seller')!),
      info: _parseArticleInfo(row.querySelector('.col-product')!),
      offer: _parseArticleOffer(row.querySelector('.col-offer')!),
    );
  }

  Future<Single> parse() async {
    final document = await parseDocument();

    final productAvailability = document
        .querySelector('.info-list-container dl')!
        .transform(definitionListToMap);
    final reprintsLinks =
        productAvailability['Reprints']!.querySelectorAll('a');
    final showVersionsLink = reprintsLinks
        .firstWhere((element) => element.text.startsWith('Show Versions'));
    final articleRows =
        document.querySelectorAll('.article-table .table-body > .row');

    return Single(
      name: document.querySelector('h1')!.nodes[0].text!,
      extension: productAvailability['Printed in']!.text,
      imageUrl: document.querySelector('#image img')?.attributes['src'],
      rarity: productAvailability['Rarity']!
          .querySelector(tooltipSelector)!
          .transform(takeTooltipText)!,
      cardId: showVersionsLink.attributes['href']!
          .split('/')
          .reversed
          .skip(1)
          .first,
      versionCount: showVersionsLink.text.transform(
            (showVersions) => _positiveIntegersPattern
                .firstMatch(showVersions)
                ?.group(0)
                ?.transform(int.tryParse),
          ) ??
          (reprintsLinks.length - 2),
      totalArticleCount:
          productAvailability['Available items']?.text.transform(int.tryParse),
      minPriceEuroCents:
          productAvailability['From']?.text.transform(tryParseEuroCents),
      priceTrendEuroCents:
          productAvailability['Price Trend']?.text.transform(tryParseEuroCents),
      thirtyDaysAveragePriceEuroCents:
          productAvailability['30-days average price']
              ?.text
              .transform(tryParseEuroCents),
      sevenDaysAveragePriceEuroCents:
          productAvailability['7-days average price']
              ?.text
              .transform(tryParseEuroCents),
      oneDayAveragePriceEuroCents: productAvailability['1-day average price']
          ?.text
          .transform(tryParseEuroCents),
      rulesText: document.querySelector('.info-list-container > div p')?.text,
      articles: [
        for (final row in articleRows) _parseSingleArticle(row),
      ],
    );
  }

  static Uri createUrl(
    String singleId, {
    List<CardLanguage>? languages,
    CardCondition? minCondition,
  }) {
    final url = Uri.parse(CardmarketPage.baseUrl).replace(
      pathSegments: [
        ...CardmarketPage.basePathSegments,
        'Products',
        'Singles',
        ...singleId.split('/'),
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

  static Future<SinglePage> fromCurrentPage() async {
    final holder = BrowserHolder.instance();
    return SinglePage(page: await holder.currentPage);
  }
}
