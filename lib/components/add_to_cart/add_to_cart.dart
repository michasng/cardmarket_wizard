import 'dart:math';

import 'package:cardmarket_wizard/components/add_to_cart/models/offer_row.dart';
import 'package:cardmarket_wizard/components/add_to_cart/offers_table.dart';
import 'package:cardmarket_wizard/components/add_to_cart_button.dart';
import 'package:cardmarket_wizard/models/price_optimizer/price_optimizer_result.dart';
import 'package:cardmarket_wizard/models/wants/wants.dart';
import 'package:cardmarket_wizard/services/cardmarket/wizard/articles_repository.dart';
import 'package:flutter/material.dart';

class AddToCart extends StatefulWidget {
  final Wants wants;
  final SellersOffers sellersOffersToBuy;
  final Map<String, int> sellersShippingCostEuroCents;

  const AddToCart({
    super.key,
    required this.wants,
    required this.sellersOffersToBuy,
    required this.sellersShippingCostEuroCents,
  });

  @override
  State<AddToCart> createState() => _AddToCartState();
}

class _AddToCartState extends State<AddToCart> {
  List<OfferRow> _offerRows = [];

  @override
  void initState() {
    super.initState();

    final articlesRepository = ArticlesRepository.instance();
    for (final sellerName in widget.sellersOffersToBuy.keys) {
      final articlesByProduct =
          articlesRepository.retrieveForSeller(sellerName: sellerName);
      for (final MapEntry(key: productId, value: articles)
          in articlesByProduct.entries) {
        final productCountToBuy =
            widget.sellersOffersToBuy[sellerName]?[productId]?.length ?? 0;
        var productCountMarkedToBuy = 0;
        for (final article in articles) {
          final articleCountToBuy = min(
            productCountToBuy - productCountMarkedToBuy,
            article.quantity,
          );
          productCountMarkedToBuy += articleCountToBuy;
          _offerRows.add(
            OfferRow(
              sellerName: sellerName,
              productId: productId,
              article: article,
              countToBuy: articleCountToBuy,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OffersTable(
          offerRows: _offerRows,
          onChangeRow: (rowToChange, changedRow) {
            // TableView re-renders when the reference to all `rows` changes
            final rowIndex = _offerRows.indexOf(rowToChange);
            final offerRows = [..._offerRows];
            offerRows[rowIndex] = changedRow;
            setState(() {
              _offerRows = offerRows;
            });
          },
        ),
        AddToCartButton(
          quantityByArticleId: {
            for (final row in _offerRows)
              if (row.countToBuy > 0) row.article.id: row.countToBuy,
          },
        ),
      ],
    );
  }
}
