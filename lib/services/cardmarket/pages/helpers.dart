import 'package:html/dom.dart';

const String _tooltipTextAttribute = 'data-bs-original-title';

const String tooltipSelector = '[data-bs-toggle="tooltip"]';

String selectTooltip(String tooltip) =>
    '$tooltipSelector[$_tooltipTextAttribute="$tooltip"]';

String? takeTooltipText(Element element) =>
    element.attributes[_tooltipTextAttribute];

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
