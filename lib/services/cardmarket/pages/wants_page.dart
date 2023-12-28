import 'dart:async';

import 'package:cardmarket_wizard/components/transform.dart';
import 'package:cardmarket_wizard/models/enums/card_condition.dart';
import 'package:cardmarket_wizard/models/enums/card_language.dart';
import 'package:cardmarket_wizard/models/enums/want_type.dart';
import 'package:cardmarket_wizard/models/want.dart';
import 'package:cardmarket_wizard/services/browser_holder.dart';
import 'package:cardmarket_wizard/services/cardmarket/currency.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/cardmarket_page.dart';
import 'package:html/dom.dart';

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
    r'^\/en\/YuGiOh\/(?:Cards|Products\/Singles\/[\w-]+)\/(?<id>[\w\d-]+?)(?:\?.*)?$',
  );
  static final _imgPattern = RegExp(r'src=\"(?<image_url>.*?)\"');

  WantsPage({required super.page})
      : super(pathPattern: RegExp(r'^\/\w+\/\w+\/Wants\/(?<wantsId>\w+)$'));

  Future<String> get title async {
    final titleElement = await page.$('.page-title-container h1');
    return await titleElement.propertyValue('innerText');
  }

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

  Want _parseWant(Element row, _TableHead tableHead) {
    final nameLink = row.querySelector('.name a')!;
    final imgHtml = row
        .querySelector('.preview [data-bs-toggle="tooltip"]')
        ?.attributes['data-bs-original-title'];

    bool? parseOptionalBoolTooltip(String? tooltip) {
      if (tooltip == null) return null;
      if (tooltip == 'Yes') return true;
      if (tooltip == 'No') return false;
      throw Exception('Unknown tooltip $tooltip.');
    }

    bool? optionalBoolByIndex(int? index) {
      if (index == null) return null;
      final tdElement = row.children[index];
      final tooltip = tdElement
          .querySelector('span[data-bs-toggle="tooltip"]')
          ?.attributes['data-bs-original-title'];
      return parseOptionalBoolTooltip(tooltip);
    }

    final href = nameLink.attributes['href']!;
    final hrefMatch = _wantHrefPattern.firstMatch(href)!;

    return Want(
      id: hrefMatch.namedGroup('id')!,
      wantType: WantType.byPath(href),
      imageUrl: imgHtml == null
          ? null
          : _imgPattern.firstMatch(imgHtml)?.namedGroup('image_url'),
      amount: int.parse(row.querySelector('.amount')!.innerHtml),
      name: nameLink.innerHtml,
      url: '${CardmarketPage.baseUrl}$href',
      expansions: row
          .querySelectorAll('.expansion [data-bs-toggle="tooltip"]')
          .emptyAsNull
          ?.map((e) => e.text)
          .toSet(),
      languages: row
          .querySelectorAll('.languages [data-bs-toggle="tooltip"]')
          .emptyAsNull
          ?.map((e) =>
              CardLanguage.byLabel(e.attributes['data-bs-original-title']!))
          .toSet(),
      minCondition: CardCondition.byAbbreviation(
        row.querySelector('.condition .badge')!.text,
      ),
      isReverseHolo: optionalBoolByIndex(tableHead.isReverseHoloIndex),
      isSigned: optionalBoolByIndex(tableHead.isSignedIndex),
      isFirstEdition: optionalBoolByIndex(tableHead.isFirstEditionIndex),
      isAltered: optionalBoolByIndex(tableHead.isAlteredIndex),
      buyPriceEuroCents: row
          .querySelector('.buyPrice span')
          ?.innerHtml
          .transform(tryParseEuroCents),
      hasEmailAlert: parseOptionalBoolTooltip(row
          .querySelector('.mailAlert [data-bs-toggle="tooltip"]')
          ?.attributes['data-bs-original-title']),
    );
  }

  Future<List<Want>> get wants async {
    final table = await page.$('#WantsListTable table');
    final tableXml = await table.propertyValue('outerHTML');
    final parsedTable = Element.html(tableXml);
    final headRow = parsedTable.querySelector('thead tr')!;
    final tableHead = await _parseTableHead(headRow);
    final rows = parsedTable.querySelectorAll('tbody tr');

    return [
      for (final row in rows) _parseWant(row, tableHead),
    ];
  }

  static Future<WantsPage> fromCurrentPage() async {
    final holder = BrowserHolder.instance();
    return WantsPage(page: await holder.currentPage);
  }
}
