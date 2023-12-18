import 'package:cardmarket_wizard/components/async/wait_for.dart';
import 'package:cardmarket_wizard/logging.dart';
import 'package:cardmarket_wizard/navigator_state_go.dart';
import 'package:cardmarket_wizard/screens/wizard/final_screen.dart';
import 'package:cardmarket_wizard/screens/wizard/launch_screen.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/wants_page.dart';
import 'package:flutter/material.dart';

class SelectWantsScreen extends StatefulWidget {
  final String username;

  const SelectWantsScreen({
    super.key,
    required this.username,
  });

  @override
  State<SelectWantsScreen> createState() => _SelectWantsScreenState();
}

class _SelectWantsScreenState extends State<SelectWantsScreen> {
  static final logger = createLogger(SelectWantsScreen);

  String? _wantsTitle;

  @override
  void initState() {
    super.initState();
    _waitForWants();
  }

  Future<void> _waitForWants() async {
    final navigator = Navigator.of(context);

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
      navigator.go(const LaunchScreen());
    }
  }

  void _onConfirm() {
    logger.info('Wants confirmed.');
    final navigator = Navigator.of(context);
    navigator.go(const FinalScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Hello ${widget.username}.'),
            const SizedBox(height: 16),
            const Text('Now navigate to a wants page.'),
            if (_wantsTitle != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _onConfirm,
                child: Text('Wants found: "$_wantsTitle". Confirm?'),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
