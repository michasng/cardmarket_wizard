import 'package:cardmarket_wizard/logging.dart';
import 'package:cardmarket_wizard/screens/wizard/components/async/wait_for.dart';
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

  String? _wantsTitle;

  @override
  void initState() {
    super.initState();
    _waitForWants();
  }

  Future<void> _waitForWants() async {
    try {
      final page = await WantsPage.fromCurrentPage();

      logger.info('Waiting for user to open a wants page.');
      await waitFor(() => page.at());
      final wantsTitle = await page.title;
      logger.info('Found wants page "$wantsTitle".');
      if (mounted) {
        setState(() => _wantsTitle = wantsTitle);

        logger.info('Waiting for confirmation.');
        await waitFor(() => !page.at() || !mounted);
        if (!page.at() && mounted) {
          logger.fine('Navigation detected.');
          setState(() => _wantsTitle = null);
          _waitForWants();
        }
      }
    } on Exception catch (e) {
      logger.severe(e);
      widget.resetToInitialSlide();
    }
  }

  void _onConfirm() {
    logger.info('Wants confirmed.');
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
        if (_wantsTitle != null) ...[
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _onConfirm,
            child: Text('Wants found: "$_wantsTitle". Confirm?'),
          ),
        ]
      ],
    );
  }
}
