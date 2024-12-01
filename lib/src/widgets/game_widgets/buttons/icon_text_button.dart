import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../outlined_text.dart';

///Created by Aabhash Shakya on 11/30/24
class IconTextButton extends StatelessWidget {
  const IconTextButton(
      {super.key, required this.icon, required this.text, required this.onTap});

  final String icon;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.w),
      child: Container(
        decoration: BoxDecoration(
            color: const Color(0xff8AE3E2),
            borderRadius: BorderRadius.circular(8.w),
            border: const Border.fromBorderSide(BorderSide(color: Colors.black))
        ),
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(icon, height: 36.h, width: 36.w,),
            SizedBox(width: 6.w,),
            Expanded(child: OutlinedText(text: text))
          ],
        ),
      ),
    );
  }
}