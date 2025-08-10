import 'package:html/dom.dart';

// Most elements use the "original" title,
// but at least some image tooltips are using the regular title.
const String _tooltipOriginalTitleAttribute = 'data-bs-original-title';
const String _tooltipTitleAttribute = 'data-bs-title';

const String tooltipSelector = '[data-bs-toggle="tooltip"]';

String selectOriginalTooltip(String tooltip) =>
    '$tooltipSelector[$_tooltipOriginalTitleAttribute="$tooltip"]';

String? takeTooltipTitle(Element element) =>
    element.attributes[_tooltipTitleAttribute] ??
    element.attributes[_tooltipOriginalTitleAttribute];

final _imgPattern = RegExp(r'src=\"(?<image_url>.*?)\"');

String? extractImageUrl(String imgHtml) =>
    _imgPattern.firstMatch(imgHtml)?.namedGroup('image_url');

bool parseBoolTooltip(String tooltip) {
  if (tooltip == 'Yes') return true;
  if (tooltip == 'No') return false;
  throw Exception('Unknown tooltip $tooltip.');
}

Map<String, Element> definitionListToMap(Element dlElement) {
  final dtElements = dlElement.querySelectorAll('dt');
  final ddElements = dlElement.querySelectorAll('dd');
  assert(dtElements.length == ddElements.length);
  return {
    for (var i = 0; i < dtElements.length; i++)
      dtElements[i].text: ddElements[i],
  };
}
