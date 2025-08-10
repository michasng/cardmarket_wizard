import 'package:flutter/material.dart';

class PhotoIcon extends StatelessWidget {
  final String imageUrl;

  const PhotoIcon(this.imageUrl, {super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      richMessage: WidgetSpan(
        alignment: PlaceholderAlignment.baseline,
        baseline: TextBaseline.alphabetic,
        child: Image.network(imageUrl),
      ),
      child: Icon(Icons.camera_alt_outlined),
    );
  }
}
