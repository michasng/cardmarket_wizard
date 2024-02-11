import 'dart:async';

import 'package:cardmarket_wizard/models/enums/card_condition.dart';
import 'package:cardmarket_wizard/models/enums/card_language.dart';
import 'package:cardmarket_wizard/models/enums/want_type.dart';
import 'package:cardmarket_wizard/models/wants.dart';
import 'package:cardmarket_wizard/services/browser_holder.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/cardmarket_page.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/helpers.dart';
import 'package:cardmarket_wizard/services/currency.dart';
import 'package:html/dom.dart';
import 'package:micha_core/micha_core.dart';

class _TableHead {
  final int? isReverseHoloIndex;
  final int? isSignedIndex;
  final int? isFirstEditionIndex;
  final int? isAlteredIndex;

  const _TableHead({
    required this.isReverseHoloIndex,
    required this.isSignedIndex,
    required this.isFirstEditionIndex,
    required this.isAlteredIndex,
  });

  @override
  String toString() {
    return {
      'isReverseHoloIndex': isReverseHoloIndex,
      'isSignedIndex': isSignedIndex,
      'isFirstEditionIndex': isFirstEditionIndex,
      'isAlteredIndex': isAlteredIndex,
    }.toString();
  }
}

class WantsPage extends CardmarketPage {
  static final _wantHrefPattern = RegExp(
    r'^\/\w+\/\w+\/(?:Cards|Products\/Singles)\/(?<id>[\w\d-\/]+?)(?:\?.*)?$',
  );

  WantsPage._({required super.page})
      : super(
          pathPattern: r'\/Wants\/(?<wants_id>[\w\d-]+)',
        );

  Future<_TableHead> _parseTableHead(Element headRow) async {
    int? indexOfChildLabel(String label) {
      final thElement =
          headRow.querySelector('[data-bs-original-title="$label"]')?.parent;
      if (thElement == null) return null;
      final index = headRow.children.indexOf(thElement);
      if (index == -1) return null;
      return index;
    }

    return _TableHead(
      isReverseHoloIndex: indexOfChildLabel('Reverse Holo?'),
      isSignedIndex: indexOfChildLabel('Signed?'),
      isFirstEditionIndex: indexOfChildLabel('First Edition?'),
      isAlteredIndex: indexOfChildLabel('Altered?'),
    );
  }

  WantsArticle _parseWantsArticle(Element trElement, _TableHead tableHead) {
    bool? optionalBoolByIndex(int? index) {
      if (index == null) return null;
      final tdElement = trElement.children[index];
      return tdElement
          .querySelector('span$tooltipSelector')
          ?.transform(takeTooltipText)
          ?.transform(parseBoolTooltip);
    }

    final nameLink = trElement.querySelector('.name a')!;
    final href = nameLink.attributes['href']!;
    final hrefMatch = _wantHrefPattern.firstMatch(href)!;

    return WantsArticle(
      id: hrefMatch.namedGroup('id')!,
      wantType: WantType.byPath(href),
      imageUrl: trElement
          .querySelector('.preview $tooltipSelector')
          ?.transform(takeTooltipText)
          ?.transform(extractImageUrl),
      amount: int.parse(trElement.querySelector('.amount')!.innerHtml),
      name: nameLink.innerHtml,
      url: '${CardmarketPage.baseUrl}$href',
      expansions: trElement
          .querySelectorAll('.expansion $tooltipSelector')
          .nullWhenEmpty
          ?.map((e) => e.text)
          .toSet(),
      languages: trElement
          .querySelectorAll('.languages $tooltipSelector')
          .nullWhenEmpty
          ?.map(takeTooltipText)
          .map((e) => CardLanguage.byLabel(e!))
          .toSet(),
      minCondition: CardCondition.byAbbreviation(
        trElement.querySelector('.condition .badge')!.text,
      ),
      isReverseHolo: optionalBoolByIndex(tableHead.isReverseHoloIndex),
      isSigned: optionalBoolByIndex(tableHead.isSignedIndex),
      isFirstEdition: optionalBoolByIndex(tableHead.isFirstEditionIndex),
      isAltered: optionalBoolByIndex(tableHead.isAlteredIndex),
      buyPriceEuroCents: trElement
          .querySelector('.buyPrice span')
          ?.innerHtml
          .transform(tryParseEuroCents),
      hasEmailAlert: trElement
          .querySelector('.mailAlert $tooltipSelector')
          ?.transform(takeTooltipText)
          ?.transform(parseBoolTooltip),
    );
  }

  Future<Wants> parse() async {
    final document = await parseDocument();

    final table = document.querySelector('#WantsListTable table')!;
    final headRow = table.querySelector('thead tr')!;
    final tableHead = await _parseTableHead(headRow);
    final trElements = table.querySelectorAll('tbody tr');

    return Wants(
      title: document.querySelector('.page-title-container h1')!.text,
      id: uriPattern.firstMatch(uri.toString())!.namedGroup('wants_id')!,
      articles: [
        for (final trElement in trElements)
          _parseWantsArticle(trElement, tableHead),
      ],
    );
  }

  static Future<WantsPage> fromCurrentPage() async {
    final holder = BrowserHolder.instance();
    final instance = WantsPage._(page: await holder.currentPage);
    await instance.waitForBrowserIdle();
    return instance;
  }
}
