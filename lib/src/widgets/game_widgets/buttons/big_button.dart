///Created by Aabhash Shakya on 11/28/24
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../outlined_text.dart';

class BigButton extends StatelessWidget {
  const BigButton(
      {super.key,
      required this.backgroundImage,
      this.borderRadius = 8,
      required this.label,
      this.fontSize = 16,
      this.onTap,
      this.width,
      required this.iconImage,
      this.titleFontSize = 18,
      required this.value});

  final String backgroundImage;
  final String iconImage;
  final double borderRadius;
  final String label;
  final int value;
  final int titleFontSize;
  final int fontSize;
  final VoidCallback? onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(borderRadius),
      onTap: onTap,
      child: Container(
        width: width?.w,
        padding:
            EdgeInsetsDirectional.symmetric(horizontal: 4.w, vertical: 6.h),
        decoration: BoxDecoration(
            border: Border.fromBorderSide(
                BorderSide(color: Colors.black, width: 1.5.w)),
            borderRadius: BorderRadius.circular(borderRadius),
            image: DecorationImage(
                image: AssetImage(backgroundImage), fit: BoxFit.cover)),
        child: IntrinsicHeight(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: OutlinedText(
                  text: label,
                  fontSize: titleFontSize,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        children: [
                          Image.asset(
                            iconImage,
                            width: 26.w,
                            height: 26.h,
                          ),
                          OutlinedText(
                            text: value.toString(),
                            fontSize: fontSize,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
