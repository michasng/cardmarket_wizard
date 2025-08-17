import 'package:cardmarket_wizard/services/cardmarket/pages/seller_singles_page.dart';
import 'package:cardmarket_wizard/services/currency.dart';
import 'package:flutter/material.dart';

class SellerLink extends StatelessWidget {
  final String wantsId;
  final String sellerName;
  final int shippingCostEuroCents;

  const SellerLink({
    super.key,
    required this.wantsId,
    required this.sellerName,
    required this.shippingCostEuroCents,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await SellerSinglesPage.goTo(sellerName, wantsId: wantsId);
      },
      child: Text.rich(
        TextSpan(
          children: [
            const TextSpan(text: 'Seller '),
            TextSpan(
              text: sellerName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextSpan(
              text: ' (+ ${formatPrice(shippingCostEuroCents)} shipping)',
            ),
          ],
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
