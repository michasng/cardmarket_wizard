import 'package:cardmarket_wizard/logging.dart';
import 'package:cardmarket_wizard/services/browser_holder.dart';
import 'package:flutter/material.dart';

class LaunchSlide extends StatelessWidget {
  static final logger = createLogger(LaunchSlide);

  final VoidCallback onSuccess;

  const LaunchSlide({
    super.key,
    required this.onSuccess,
  });

  Future<void> _launch() async {
    logger.info('Launching browser');

    final holder = BrowserHolder.instance();
    await holder.launch();
    onSuccess();
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
