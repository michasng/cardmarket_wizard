import 'package:cardmarket_wizard/components/async/wait_for.dart';
import 'package:cardmarket_wizard/logging.dart';
import 'package:cardmarket_wizard/models/wants.dart';
import 'package:cardmarket_wizard/navigator_state_go.dart';
import 'package:cardmarket_wizard/screens/wizard/debug_screen.dart';
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

  Wants? _wants;

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
      await waitFor(() async => await page.at() || !mounted);
      if (!mounted) return;

      final wants = await page.parse();
      if (!mounted) return;
      setState(() => _wants = wants);

      logger.info('Wants page "${wants.title}" waiting for confirmation.');
      await waitFor(() async => !await page.at() || !mounted);
      if (!mounted) return;

      logger.fine('Navigation away from wants page detected.');
      setState(() => _wants = null);
      _waitForWants();
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
          children: _wants == null
              ? [
                  Text(
                    'Hello ${widget.username}.',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  const Text('Now navigate to a wants page.'),
                ]
              : [
                  Text(
                    'Detected open wants page: "${_wants?.title}"',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _onConfirm,
                    child: const Text('Confirm?'),
                  ),
                  const SizedBox(height: 16),
                  const Text('Otherwise navigate to a different wants page.'),
                ],
        ),
      ),
      floatingActionButton: TextButton(
        onPressed: () {
          final navigator = Navigator.of(context);
          navigator.go(const DebugScreen());
        },
        child: const Text('debugging options'),
      ),
    );
  }
}
