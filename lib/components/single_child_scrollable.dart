import 'package:flutter/material.dart';

class SingleChildScrollable extends StatefulWidget {
  final Widget child;
  final Axis scrollDirection;
  final bool? primary;

  const SingleChildScrollable({
    super.key,
    required this.child,
    this.scrollDirection = Axis.vertical,
    this.primary,
  });

  @override
  State<SingleChildScrollable> createState() => _SingleChildScrollableState();
}

class _SingleChildScrollableState extends State<SingleChildScrollable> {
  final _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _controller,
      child: SingleChildScrollView(
        controller: _controller,
        scrollDirection: widget.scrollDirection,
        primary: widget.primary,
        child: Padding(
          // prevent overlap of scrollbar with scrollable content
          padding: EdgeInsets.only(
            right: widget.scrollDirection == Axis.vertical ? 16 : 0,
            bottom: widget.scrollDirection == Axis.horizontal ? 16 : 0,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
