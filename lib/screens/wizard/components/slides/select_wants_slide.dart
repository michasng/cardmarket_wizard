import 'package:cardmarket_wizard/logging.dart';
import 'package:cardmarket_wizard/screens/wizard/components/slides/final_slide.dart';
import 'package:cardmarket_wizard/screens/wizard/components/stepping_slide_view.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/wants_page.dart';
import 'package:flutter/material.dart';

class SelectWantsSlide extends StatefulWidget implements Slide {
  final String username;

  @override
  final void Function(Widget nextSlide) goToNextSlide;
  @override
  final VoidCallback resetToInitialSlide;

  const SelectWantsSlide({
    super.key,
    required this.username,
    required this.goToNextSlide,
    required this.resetToInitialSlide,
  });

  @override
  State<SelectWantsSlide> createState() => _SelectWantsSlideState();
}

class _SelectWantsSlideState extends State<SelectWantsSlide> {
  static final logger = createLogger(SelectWantsSlide);

  bool _wantsDetected = false;

  @override
  void initState() {
    super.initState();
    _waitForWants();
  }

  Future<void> _waitForWants() async {
    try {
      final page = await WantsPage.fromCurrentPage();

      logger.info('Waiting for user to open a wants page.');
      while (!page.at()) {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      logger.info('Found wants page.');
      setState(() => _wantsDetected = true);
    } on Exception catch (e) {
      logger.severe(e);
      widget.resetToInitialSlide();
    }
  }

  void _onConfirm() {
    widget.goToNextSlide(FinalSlide(
      goToNextSlide: widget.goToNextSlide,
      resetToInitialSlide: widget.resetToInitialSlide,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Hello ${widget.username}.'),
        const SizedBox(height: 16),
        const Text('Now navigate to a wants page.'),
        if (_wantsDetected) ...[
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _onConfirm,
            child: const Text('Wants found. Confirm?'),
          ),
        ]
      ],
    );
  }
}
