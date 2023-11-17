import 'package:cardmarket_wizard/logging.dart';
import 'package:cardmarket_wizard/screens/wizard/slides/launch_slide.dart';
import 'package:cardmarket_wizard/screens/wizard/slides/login_slide.dart';
import 'package:cardmarket_wizard/screens/wizard/slides/select_wants_slide.dart';
import 'package:flutter/material.dart';

class SlideScreen extends StatefulWidget {
  const SlideScreen({super.key});

  @override
  State<SlideScreen> createState() => _SlideScreenState();
}

class _SlideScreenState extends State<SlideScreen> {
  static final logger = createLogger(SlideScreen);

  final _pageController = PageController();
  final pageCount = 4;
  int _currentSlideIndex = 0;

  String? _username;

  Future<void> _restart() async {
    logger.info('Restart wizard');

    setState(() => _currentSlideIndex = 0);
    await _animateToCurrentSlideIndex();
  }

  Future<void> _next() async {
    logger.info('Next slide');

    setState(() => _currentSlideIndex = (_currentSlideIndex + 1) % 3);
    await _animateToCurrentSlideIndex();
  }

  Future<void> _animateToCurrentSlideIndex() async {
    await _pageController.animateToPage(
      _currentSlideIndex,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cardmarket Wizard'),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          LaunchSlide(onSuccess: _next),
          LoginSlide(
            onSuccess: (username) async {
              setState(() => _username = username);
              await _next();
            },
            onError: _restart,
          ),
          _username == null
              ? Container()
              : SelectWantsSlide(
                  username: _username!,
                  onSuccess: _next,
                  onError: _restart,
                ),
          const Center(
            child: Text('That\'s all for now.'),
          ),
        ],
      ),
    );
  }
}
