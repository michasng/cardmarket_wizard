import 'package:flutter/material.dart';

abstract interface class Slide {
  void Function(Widget nextSlide) get goToNextSlide;
  VoidCallback get resetToInitialSlide;
}

class SteppingSlideViewController {
  final _key = GlobalKey<_SteppingSlideViewState>();

  Future<void> resetToInitialSlide() async {
    await _key.currentState?.resetToInitialSlide();
  }

  Future<void> goToNextSlide(Widget nextSlide) async {
    await _key.currentState?.goToNextSlide(nextSlide);
  }
}

/// Renders a PageView with dynamic children.
/// Starts off from a single slide. Each slide declares its successor when transitioning to the next slide.
/// This simplifies shared state between slides, which can be passed directly from one slide to the next.
/// This widget is not scrollable, because it can only transition to the next and to the initial slide.
class SteppingSlideView extends StatefulWidget {
  final Widget initialSlide;
  final Duration animationDuration;
  final Curve animationCurve;

  SteppingSlideView({
    required SteppingSlideViewController controller,
    required this.initialSlide,
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.easeInOut,
  }) : super(key: controller._key);

  @override
  State<SteppingSlideView> createState() => _SteppingSlideViewState();
}

class _SteppingSlideViewState extends State<SteppingSlideView> {
  final _pageController = PageController();

  late Widget _previousSlide;
  late Widget _currentSlide;

  @override
  void initState() {
    super.initState();
    _previousSlide = widget.initialSlide;
    _currentSlide = widget.initialSlide;
  }

  Future<void> resetToInitialSlide() async {
    setState(() => _previousSlide = widget.initialSlide);
    await _animateToSlide(0);
    setState(() => _currentSlide = widget.initialSlide);
  }

  Future<void> goToNextSlide(Widget nextSlide) async {
    setState(() => _previousSlide = _currentSlide);
    _pageController.jumpToPage(0);
    setState(() => _currentSlide = nextSlide);

    await _animateToSlide(1);
  }

  Future<void> _animateToSlide(int slideIndex) async {
    await _pageController.animateToPage(
      slideIndex,
      duration: widget.animationDuration,
      curve: widget.animationCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _previousSlide,
        _currentSlide,
      ],
    );
  }
}
