import 'package:cardmarket_wizard/services/cardmarket/wizard/shopping_cart_service.dart';
import 'package:flutter/material.dart';
import 'package:micha_core/micha_core.dart';

class AddToCartButton extends StatefulWidget {
  static final _logger = createLogger(AddToCartButton);

  final Map<String, int> quantityByArticleId;

  const AddToCartButton({super.key, required this.quantityByArticleId});

  @override
  State<AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<AddToCartButton> {
  bool loading = false;

  Future<void> addToCart() async {
    final messenger = ScaffoldMessenger.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final shoppingCartService = ShoppingCartService.instance();
    try {
      await shoppingCartService.addToShoppingCart(widget.quantityByArticleId);
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: colorScheme.primary,
          content: Row(
            spacing: 16,
            children: [
              Icon(Icons.shopping_cart_outlined, color: colorScheme.onPrimary),
              Text(
                'Articles were added to the shopping cart.',
                style: TextStyle(color: colorScheme.onPrimary),
              ),
            ],
          ),
        ),
      );
    } on Exception catch (exception, stackTrace) {
      final message = 'Failed to add articles to the shopping cart.';
      AddToCartButton._logger.severe(message, exception, stackTrace);
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: colorScheme.error,
          content: Row(
            spacing: 16,
            children: [
              Icon(Icons.shopping_cart_outlined, color: colorScheme.onError),
              Text(message, style: TextStyle(color: colorScheme.onError)),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: loading
          ? null
          : () async {
              setState(() {
                loading = true;
              });

              await addToCart();

              setState(() {
                loading = false;
              });
            },
      icon: Icon(Icons.add_shopping_cart),
      label: const Text('Add to shopping cart'),
    );
  }
}
