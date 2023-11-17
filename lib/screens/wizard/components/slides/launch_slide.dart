import 'package:cardmarket_wizard/logging.dart';
import 'package:cardmarket_wizard/screens/wizard/components/slides/login_slide.dart';
import 'package:cardmarket_wizard/screens/wizard/components/stepping_slide_view.dart';
import 'package:cardmarket_wizard/services/browser_holder.dart';
import 'package:flutter/material.dart';

class LaunchSlide extends StatelessWidget implements Slide {
  static final logger = createLogger(LaunchSlide);

  @override
  final void Function(Widget nextSlide) goToNextSlide;
  @override
  final VoidCallback resetToInitialSlide;

  const LaunchSlide({
    super.key,
    required this.goToNextSlide,
    required this.resetToInitialSlide,
  });

  Future<void> _launch() async {
    logger.info('Launching browser');

    final holder = BrowserHolder.instance();
    await holder.launch();

    goToNextSlide(LoginSlide(
      goToNextSlide: goToNextSlide,
      resetToInitialSlide: resetToInitialSlide,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: _launch,
        child: const Text('Launch browser to start.'),
      ),
    );
  }
}
