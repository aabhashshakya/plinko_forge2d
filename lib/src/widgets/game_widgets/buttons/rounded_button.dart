///Created by Aabhash Shakya on 11/28/24
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../outlined_text.dart';

class RoundedButton extends StatelessWidget {
  const RoundedButton({super.key,
    required this.backgroundImage,
    this.borderRadius = 74,
    required this.label,
    this.fontSize = 18,
    required this.onTap,
    required this.width, this.enabled = true});

  final bool enabled;
  final String backgroundImage;
  final double borderRadius;
  final String label;
  final int fontSize;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter:  enabled ? const ColorFilter.mode(Colors.transparent,BlendMode.srcATop) : ColorFilter.mode(
          Colors.black.withOpacity(0.5), BlendMode.srcATop),
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: enabled ? onTap : null,
        child: Container(
          width: width,
          padding:
          const EdgeInsetsDirectional.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
              border: const Border.fromBorderSide(
                  BorderSide(color: Colors.black, width: 1.5)),
              borderRadius: BorderRadius.circular(borderRadius),
              image: DecorationImage(
                  image: AssetImage(backgroundImage),
                  fit: BoxFit.cover,
                  )),
          child: Center(
            child: FittedBox(
              child: OutlinedText(
                text: label,
                fontSize: fontSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
