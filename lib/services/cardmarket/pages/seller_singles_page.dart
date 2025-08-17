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
  static final RegExp _rowIdPattern = RegExp(r'^articleRow(?<id>\d+)$');
  static final RegExp _positiveIntegersPattern = RegExp(r'\d+');
  static final _singleHrefPattern = RegExp(
    r'^\/\w+\/\w+\/(?:Products\/Singles)\/(?<product_id>[\w\d-\/]+?)(?:\?.*)?$',
  );

  SellerSinglesPage._({required super.page})
    : super(pathPattern: r'\/Users\/[\w\d-]+\/Offers\/Singles');

  SellerSinglesArticleInfo _parseArticleInfo(Element column) {
    final productAttributes = column.querySelector('.product-attributes')!;
    final expansionElement = productAttributes.querySelector(
      '.expansion-symbol',
    )!;
    final conditionElement = productAttributes.querySelector(
      '.article-condition',
    )!;

    return SellerSinglesArticleInfo(
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

  SellerSinglesArticle _parseArticle(Element row) {
    final singleLink = row.querySelector('.col-seller a')!;
    final href = singleLink.attributes['href']!;
    final hrefMatch = _singleHrefPattern.firstMatch(href)!;

    return SellerSinglesArticle(
      id: _rowIdPattern.firstMatch(row.id)!.namedGroup('id')!,
      productId: hrefMatch.namedGroup('product_id')!,
      imageUrl: row
          .querySelector('.col-icon $tooltipSelector')
          ?.transform(takeTooltipTitle)
          ?.transform(extractImageUrl),
      name: singleLink.text,
      url: '${CardmarketPage.baseUrl}$href',
      info: _parseArticleInfo(row.querySelector('.col-product')!),
      offer: _parseArticleOffer(row.querySelector('.col-offer')!),
    );
  }

  Future<SellerSingles> parse() async {
    final document = await parseDocument();

    final pageTitleContainer = document.querySelector('.page-title-container')!;
    final titleElement = pageTitleContainer.querySelector('h1')!;

    final pagination = document.querySelector('.pagination');
    final paginationCountsSpan = pagination
        ?.querySelectorAll('.pagination-control')
        .first
        .nextElementSibling;
    final paginationCounts = paginationCountsSpan == null
        ? null
        : _positiveIntegersPattern
              .allMatches(paginationCountsSpan.text)
              .toList();

    final articleRows = document.querySelectorAll(
      '.article-table .table-body > .row',
    );

    return SellerSingles(
      name: titleElement.nodes[0].text!,
      location: Location.byLabel(
        titleElement
            .querySelector(tooltipSelector)!
            .transform(takeTooltipTitle)!,
      ),
      etaDays: pageTitleContainer.children.last.text
          .transform(_positiveIntegersPattern.firstMatch)
          ?.group(0)
          ?.transform(int.tryParse),
      pagination: pagination_model.Pagination(
        totalCount:
            pagination
                ?.querySelector('.total-count')!
                .text
                .transform(_positiveIntegersPattern.firstMatch)!
                .group(0)!
                .transform(int.parse) ??
            0,
        pageNumber: paginationCounts == null
            ? 1
            : paginationCounts[0].group(0)!.transform(int.parse),
        pageCount: paginationCounts == null
            ? 1
            : paginationCounts[1].group(0)!.transform(int.parse),
        previousPageUrl: pagination
            ?.querySelectorAll('.pagination-control')
            .first
            .attributes['href']
            ?.transform((path) => uri!.origin + path),
        nextPageUrl: pagination
            ?.querySelectorAll('.pagination-control')
            .last
            .attributes['href']
            ?.transform((path) => uri!.origin + path),
      ),
      articles: [for (final row in articleRows) _parseArticle(row)],
    );
  }

  static Future<SellerSinglesPage> goTo(
    String sellerName, {
    String? wantsId,
  }) async {
    final url = _createUrl(sellerName, wantsId: wantsId);
    final browserHolder = BrowserHolder.instance();
    await browserHolder.goTo(url.toString());
    final page = await browserHolder.currentPage;
    final instance = SellerSinglesPage._(page: page);
    return instance;
  }

  static Uri _createUrl(String sellerName, {String? wantsId}) {
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
    final instance = SellerSinglesPage._(page: await holder.currentPage);
    return instance;
  }
}
