import 'package:cardmarket_wizard/models/enums/location.dart';
import 'package:cardmarket_wizard/screens/preliminary_result/models/seller_row.dart';
import 'package:cardmarket_wizard/screens/preliminary_result/sellers_wants_table.dart';
import 'package:cardmarket_wizard/services/cardmarket/shipping_costs_service.dart';
import 'package:cardmarket_wizard/services/cardmarket/wizard/wizard_settings_service.dart';
import 'package:flutter/material.dart';
import 'package:micha_core/micha_core.dart';

class AsyncSellersWantsTable extends StatelessWidget {
  final List<String> productIds;
  final List<SellerRow> rows;
  final Set<String> selectedSellerNames;
  final void Function(String sellerName) onToggleSellerSelected;

  const AsyncSellersWantsTable({
    super.key,
    required this.productIds,
    required this.rows,
    required this.selectedSellerNames,
    required this.onToggleSellerSelected,
  });

  Future<Map<Location, int>> getMinShippingEuroCentsByLocation() async {
    final settings = WizardSettingsService.instance();
    final shippingCostsService = ShippingCostsService.instance();

    return {
      for (final row in rows)
        row.seller.location: shippingCostsService.estimateShippingCost(
          cardCount: 1,
          valueEuroCents: 1,
          shippingMethods: await shippingCostsService.findShippingMethods(
            fromCountry: row.seller.location,
            toCountry: settings.location,
          ),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return AsyncBuilder(
      createFuture: (context) => getMinShippingEuroCentsByLocation(),
      builder: (context, minShippingEuroCentsByLocation) {
        return SellersWantsTable(
          productIds: productIds,
          rows: rows,
          minShippingEuroCentsByLocation: minShippingEuroCentsByLocation,
          selectedSellerNames: selectedSellerNames,
          onToggleSellerSelected: onToggleSellerSelected,
        );
      },
    );
  }
}
