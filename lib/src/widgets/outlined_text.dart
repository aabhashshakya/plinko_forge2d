import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OutlinedText extends StatelessWidget {
  const OutlinedText(
      {super.key,
      required this.text,
      this.isBold = true,
      this.fontSize = 18,
      this.align,
      this.color = Colors.white});

  final String text;
  final TextAlign? align;
  final Color color;
  final bool isBold;
  final int fontSize;

  @override
  Widget build(BuildContext context) {
    return _OutlinedText(
      text: Text(text,
          maxLines: 1,
          textAlign: align,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              shadows: [Shadow(color: Colors.black, offset: Offset(0, 2.h))],
              fontSize: fontSize.sp,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      strokes: [
        OutlinedTextStroke(color: Colors.black, width: 2.w),
      ],
    );
  }
}

class _OutlinedText extends StatelessWidget {
  final Text? text;
  final List<OutlinedTextStroke>? strokes;

  const _OutlinedText({super.key, this.text, this.strokes});

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    final list = strokes ?? [];
    double widthSum = 0;
    for (var i = 0; i < list.length; i++) {
      widthSum += list[i].width ?? 0;
      children.add(Text(text?.data ?? '',
          textAlign: text?.textAlign,
          style: (text?.style ?? TextStyle()).copyWith(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = widthSum
                ..color = list[i].color ?? Colors.transparent),maxLines: 1,));
    }

    return Stack(
      children: [...children.reversed, text ?? SizedBox.shrink()],
    );
  }
}

class OutlinedTextStroke {
  final Color? color;
  final double? width;

  OutlinedTextStroke({this.color, this.width});
}
