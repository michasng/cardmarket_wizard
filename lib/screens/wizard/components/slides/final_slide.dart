import 'package:cardmarket_wizard/screens/wizard/components/stepping_slide_view.dart';
import 'package:flutter/material.dart';

class FinalSlide extends StatelessWidget implements Slide {
  @override
  final void Function(Widget nextSlide) goToNextSlide;
  @override
  final VoidCallback resetToInitialSlide;

  const FinalSlide({
    super.key,
    required this.goToNextSlide,
    required this.resetToInitialSlide,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('That\'s all for now.'),
    );
  }
}
