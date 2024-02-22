import 'package:cardmarket_wizard/components/help.dart';
import 'package:cardmarket_wizard/components/location_dropdown.dart';
import 'package:cardmarket_wizard/models/enums/location.dart';
import 'package:cardmarket_wizard/navigator_state_go.dart';
import 'package:cardmarket_wizard/screens/wizard/login_screen.dart';
import 'package:cardmarket_wizard/services/browser_holder.dart';
import 'package:cardmarket_wizard/services/wizard_settings.dart';
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
  Duration _requestInterval = const Duration(seconds: 4);

  Future<void> _launch(WizardSettings settings) async {
    final navigator = Navigator.of(context);
    LaunchScreen._logger.info('Launching browser');

    final holder = BrowserHolder.instance();
    await holder.launch();

    navigator.go(const LoginScreen());
  }

  WizardSettings? tryBuildSettings() {
    final location = _location;

    if (location == null) return null;
    return WizardSettings(
      location: location,
      requestInterval: _requestInterval,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = tryBuildSettings();

    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: FilledButton(
                  onPressed: settings == null ? null : () => _launch(settings),
                  child: const Text('Launch browser to start.'),
                ),
              ),
              const Gap(),
              Help(
                message: 'This is used to estimate shipping costs.',
                child: LocationDropdown(
                  value: _location,
                  labelText: 'Your location',
                  onChanged: (newValue) {
                    setState(() {
                      _location = newValue;
                    });
                  },
                ),
              ),
              const Text('Request interval'),
              Help(
                message: 'Cloudflare protection kicks in when you go too fast.',
                child: Slider(
                  label: '${_requestInterval.inSeconds.round()} s',
                  min: 1,
                  max: 10,
                  divisions: 9,
                  value: _requestInterval.inSeconds.toDouble(),
                  onChanged: (newValue) {
                    setState(() {
                      _requestInterval = Duration(seconds: newValue.round());
                    });
                  },
                ),
              ),
            ].separated(const Gap()),
          ),
        ),
      ),
    );
  }
}
