/// A token is required to add articles to the cardmarket shopping cart.
/// The token can be extracted from hidden <input> elements on most pages.
/// It presumably identifies the user and must be used with a session cookie belonging to the same user.
class CardmarketTokenHolder {
  static CardmarketTokenHolder? _instance;
  static const tokenName = '__cmtkn';
  String? token;

  CardmarketTokenHolder._internal();

  factory CardmarketTokenHolder.instance() {
    return _instance ??= CardmarketTokenHolder._internal();
  }
}
