import 'package:cardmarket_wizard/components/help.dart';
import 'package:cardmarket_wizard/components/location_dropdown.dart';
import 'package:cardmarket_wizard/models/enums/location.dart';
import 'package:cardmarket_wizard/navigator_state_go.dart';
import 'package:cardmarket_wizard/screens/login/login_screen.dart';
import 'package:cardmarket_wizard/services/browser_holder.dart';
import 'package:cardmarket_wizard/services/cardmarket/wizard/wizard_settings_service.dart';
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
  Duration _requestInterval = const Duration(seconds: 0);
  bool _isLaunching = false;

  Future<void> _launch(WizardSettingsService settings) async {
    setState(() {
      _isLaunching = true;
    });
    final navigator = Navigator.of(context);
    LaunchScreen._logger.info('Launching browser...');

    final holder = BrowserHolder.instance();
    try {
      await holder.launch();
    } catch (exception, stackTrace) {
      LaunchScreen._logger.severe(
        'Failed to launch browser',
        exception,
        stackTrace,
      );
      setState(() {
        _isLaunching = false;
      });
      return;
    }

    navigator.go(const LoginScreen());
  }

  WizardSettingsService? tryBuildSettings() {
    final location = _location;

    if (location == null) return null;
    return WizardSettingsService(
      location: location,
      requestInterval: _requestInterval,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = tryBuildSettings();

    return Scaffold(
      body: Center(
        child: _isLaunching
            ? const Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 16,
                children: [Spinner(), Text('Launching browser. Please wait.')],
              )
            : SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    Center(
                      child: FilledButton(
                        onPressed: settings == null
                            ? null
                            : () => _launch(settings),
                        child: const Text('Launch browser to start.'),
                      ),
                    ),
                    const Gap(),
                    Help(
                      message: 'This is used to estimate shipping costs.',
                      child: LocationDropdown(
                        value: _location,
                        labelText: 'Your country',
                        onChanged: (newValue) {
                          setState(() {
                            _location = newValue;
                          });
                        },
                      ),
                    ),
                    const Text('Request interval'),
                    Help(
                      message:
                          'Slowing down may avoid "429 Too Many Requests".',
                      child: Slider(
                        label: '${_requestInterval.inSeconds} s',
                        min: 0,
                        max: 10,
                        divisions: 10,
                        value: _requestInterval.inSeconds.toDouble(),
                        onChanged: (newValue) {
                          setState(() {
                            _requestInterval = Duration(
                              seconds: newValue.round(),
                            );
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
