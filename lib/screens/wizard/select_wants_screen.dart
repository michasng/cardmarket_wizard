import 'package:cardmarket_wizard/models/enums/location.dart';
import 'package:cardmarket_wizard/models/wants.dart';
import 'package:cardmarket_wizard/navigator_state_go.dart';
import 'package:cardmarket_wizard/screens/wizard/debug_screen.dart';
import 'package:cardmarket_wizard/screens/wizard/launch_screen.dart';
import 'package:cardmarket_wizard/screens/wizard/wizard_screen.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/wants_page.dart';
import 'package:flutter/material.dart';
import 'package:micha_core/micha_core.dart';

class SelectWantsScreen extends StatefulWidget {
  final Location location;
  final String username;

  const SelectWantsScreen({
    super.key,
    required this.location,
    required this.username,
  });

  @override
  State<SelectWantsScreen> createState() => _SelectWantsScreenState();
}

class _SelectWantsScreenState extends State<SelectWantsScreen> {
  static final _logger = createLogger(SelectWantsScreen);

  Wants? _wants;

  @override
  void initState() {
    super.initState();
    _waitForWants();
  }

  Future<void> _waitForWants() async {
    final navigator = Navigator.of(context);

    final page = await WantsPage.fromCurrentPage();
    while (mounted) {
      _logger.info('Waiting for user to open a wants page.');
      await waitFor(() async => await page.at() || !mounted);
      if (!mounted) return;

      try {
        final wants = await page.parse();
        if (!mounted) return;
        setState(() => _wants = wants);

        _logger.info(
          'Wants page "${wants.title}" (ID ${wants.id}) waiting for confirmation.',
        );
        await waitFor(() async => !await page.at() || !mounted);
        if (!mounted) return;

        _logger.fine('Navigation away from wants page detected.');
        setState(() => _wants = null);
      } on Exception catch (e) {
        if (e.toString().contains('Session closed')) {
          _logger.info('Restarting wizard, because the browser was closed.');
          navigator.go(const LaunchScreen());
          return;
        }
        _logger.severe(e);
      }
    }
  }

  void _onConfirm() {
    _logger.info('Wants confirmed.');
    final navigator = Navigator.of(context);
    navigator.go(WizardScreen(
      location: widget.location,
      wants: _wants!,
    ));
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
                  const Gap(),
                  const Text('Now navigate to a wants page.'),
                ]
              : [
                  Text(
                    'Detected open wants page: "${_wants?.title}"',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  FilledButton(
                    onPressed: _onConfirm,
                    child: const Text('Confirm?'),
                  ),
                  const Text('Otherwise navigate to a different wants page.'),
                ].separated(const Gap()),
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
