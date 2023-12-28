enum CardLanguage {
  english(1, 'English'),
  french(2, 'French'),
  german(3, 'German'),
  spanish(4, 'Spanish'),
  italian(5, 'Italian'),
  simplifiedChinese(6, 'S-Chinese'),
  japanese(7, 'Japanese'),
  portuguese(8, 'Portuguese'),
  korean(9, 'Korean'),
  traditionalChinese(10, 'T-Chinese');

  final int ordinal;
  final String label;

  const CardLanguage(this.ordinal, this.label);

  factory CardLanguage.byLabel(String label) {
    return values.firstWhere((value) => value.label == label);
  }
}
