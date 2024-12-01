import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:plinko_forge2d/src/widgets/outlined_text.dart';

class OverlayScreen extends StatelessWidget {
  const OverlayScreen({
    super.key,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
     this.titleFontSize = 40,
     this.subtitleFontSize = 30

  });

  final String title;
  final Color color;
  final String subtitle;
  final double titleFontSize;
  final double subtitleFontSize;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: (){
        onTap();
      },
      child: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            OutlinedText(
             text: title,
              align: TextAlign.center,
            ).animate().slideY(duration: 750.ms, begin: -3, end: 0),
            const SizedBox(height: 16),
            OutlinedText(
              text: subtitle,
              align: TextAlign.center,
            )
                .animate(onPlay: (controller) => controller.repeat())
                .fadeIn(duration: 1.seconds)
                .then(delay: const Duration(milliseconds: 500))
                .fadeOut(duration: 0.5.seconds),
          ],
        ),
      ),
    );
  }
}