import 'package:cardmarket_wizard/components/location_dropdown.dart';
import 'package:cardmarket_wizard/models/enums/location.dart';
import 'package:cardmarket_wizard/models/wizard_settings.dart';
import 'package:cardmarket_wizard/navigator_state_go.dart';
import 'package:cardmarket_wizard/screens/wizard/login_screen.dart';
import 'package:cardmarket_wizard/services/browser_holder.dart';
import 'package:flutter/material.dart';
import 'package:micha_core/micha_core.dart';

class LaunchScreen extends StatefulWidget {
  static final _logger = createLogger(LaunchScreen);

  const LaunchScreen({super.key});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  Location? _location;

  Future<void> _launch(WizardSettings settings) async {
    final navigator = Navigator.of(context);
    LaunchScreen._logger.info('Launching browser');

    final holder = BrowserHolder.instance();
    await holder.launch();

    navigator.go(LoginScreen(settings: settings));
  }

  WizardSettings? tryBuildSettings() {
    final location = _location;

    if (location == null) return null;
    return WizardSettings(location: location);
  }

  @override
  Widget build(BuildContext context) {
    final settings = tryBuildSettings();

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Let\'s begin',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Text(
              'Please select your location, so shipping costs can be estimated.',
            ),
            LocationDropdown(
              value: _location,
              onChanged: (newValue) {
                setState(() {
                  _location = newValue;
                });
              },
            ),
            FilledButton(
              onPressed: settings == null ? null : () => _launch(settings),
              child: const Text('Launch browser to start.'),
            ),
          ].separated(const Gap()),
        ),
      ),
    );
  }
}
