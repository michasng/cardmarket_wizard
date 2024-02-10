import 'dart:async';

import 'package:cardmarket_wizard/models/enums/card_condition.dart';
import 'package:cardmarket_wizard/models/enums/card_language.dart';
import 'package:cardmarket_wizard/models/enums/location.dart';
import 'package:cardmarket_wizard/models/interfaces/article_offer.dart';
import 'package:cardmarket_wizard/models/pagination.dart' as pagination_model;
import 'package:cardmarket_wizard/models/seller_singles/seller_singles.dart';
import 'package:cardmarket_wizard/models/seller_singles/seller_singles_article.dart';
import 'package:cardmarket_wizard/models/seller_singles/seller_singles_article_info.dart';
import 'package:cardmarket_wizard/services/browser_holder.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/cardmarket_page.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/helpers.dart';
import 'package:cardmarket_wizard/services/currency.dart';
import 'package:html/dom.dart';
import 'package:micha_core/micha_core.dart';

class SellerSinglesPage extends CardmarketPage {
  static final RegExp _positiveIntegersPattern = RegExp(r'\d+');

  SellerSinglesPage({required super.page})
      : super(
          pathPattern: r'\/Users\/[\w\d-]+\/Offers\/Singles',
        );

  SellerSingleArticleInfo _parseArticleInfo(Element column) {
    final productAttributes = column.querySelector('.product-attributes')!;
    final expansionElement =
        productAttributes.querySelector('.expansion-symbol')!;
    final conditionElement =
        productAttributes.querySelector('.article-condition')!;

    return SellerSingleArticleInfo(
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

  SellerSinglesArticle _parseArticle(Element row) {
    final singleLink = row.querySelector('.col-seller a')!;

    return SellerSinglesArticle(
      imageUrl: row
          .querySelector('.col-icon $tooltipSelector')
          ?.transform(takeTooltipText)
          ?.transform(extractImageUrl),
      name: singleLink.text,
      url: singleLink.attributes['href']!,
      info: _parseArticleInfo(row.querySelector('.col-product')!),
      offer: _parseArticleOffer(row.querySelector('.col-offer')!),
    );
  }

  Future<SellerSingles> parse() async {
    final document = await parseDocument();

    final pageTitleContainer = document.querySelector('.page-title-container')!;
    final titleElement = pageTitleContainer.querySelector('h1')!;

    final filterToggle = document.querySelector('#filterToggle')!;
    final pagination = filterToggle.querySelector('.pagination')!;
    final paginationCountsSpan = pagination
        .querySelectorAll('.pagination-control')
        .first
        .nextElementSibling!;
    final paginationCounts =
        _positiveIntegersPattern.allMatches(paginationCountsSpan.text).toList();

    final articleRows =
        document.querySelectorAll('.article-table .table-body > .row');

    return SellerSingles(
      name: titleElement.nodes[0].text!,
      location: Location.byLabel(titleElement
          .querySelector(tooltipSelector)!
          .transform(takeTooltipText)!),
      etaDays: pageTitleContainer.children.last.text
          .transform(_positiveIntegersPattern.firstMatch)
          ?.group(0)
          ?.transform(int.tryParse),
      pagination: pagination_model.Pagination(
        totalCount: pagination
            .querySelector('.total-count')!
            .text
            .transform(_positiveIntegersPattern.firstMatch)!
            .group(0)!
            .transform(int.parse),
        pageNumber: paginationCounts[0].group(0)!.transform(int.parse),
        pageCount: paginationCounts[1].group(0)!.transform(int.parse),
        previousPageUrl: pagination
            .querySelectorAll('.pagination-control')
            .first
            .attributes['href'],
        nextPageUrl: pagination
            .querySelectorAll('.pagination-control')
            .last
            .attributes['href'],
      ),
      articles: [
        for (final row in articleRows) _parseArticle(row),
      ],
    );
  }

  static Uri createUrl(
    String sellerName, {
    String? wantsId,
  }) {
    final url = Uri.parse(CardmarketPage.baseUrl).replace(
      pathSegments: [
        ...CardmarketPage.basePathSegments,
        'Users',
        sellerName,
        'Offers',
        'Singles',
      ],
      queryParameters: <String, String>{
        if (wantsId != null) 'idWantslist': wantsId,
      }.nullWhenEmpty,
    );
    return url;
  }

  static Future<SellerSinglesPage> fromCurrentPage() async {
    final holder = BrowserHolder.instance();
    return SellerSinglesPage(page: await holder.currentPage);
  }
}
