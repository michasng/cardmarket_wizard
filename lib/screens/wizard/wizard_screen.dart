import 'package:cardmarket_wizard/screens/wizard/components/slides/launch_slide.dart';
import 'package:cardmarket_wizard/screens/wizard/components/stepping_slide_view.dart';
import 'package:flutter/material.dart';

class SlideScreen extends StatefulWidget {
  const SlideScreen({super.key});

  @override
  State<SlideScreen> createState() => _SlideScreenState();
}

class _SlideScreenState extends State<SlideScreen> {
  final _slideViewController = SteppingSlideViewController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cardmarket Wizard'),
      ),
      body: SteppingSlideView(
        controller: _slideViewController,
        initialSlide: LaunchSlide(
          goToNextSlide: _slideViewController.goToNextSlide,
          resetToInitialSlide: _slideViewController.resetToInitialSlide,
        ),
      ),
    );
  }
}
