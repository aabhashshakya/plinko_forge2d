///Created by Aabhash Shakya on 11/28/24
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:plinko_forge2d/src/constants/config.dart';

import '../../outlined_text.dart';

class BigButtonSlider extends StatefulWidget {
  const BigButtonSlider(
      {super.key,
      required this.backgroundImage,
      this.borderRadius = 8,
      required this.label,
      this.fontSize = 16,
      this.width,
      required this.iconImage,
      this.titleFontSize = 18,
      required this.value,
      required this.min,
      required this.max,
      required this.onSliderDragged,
      this.iconSize = 26,
      this.onIncrementOrDecrement,
      required this.buttonType});

  final BigButtonType buttonType;
  final String backgroundImage;
  final String iconImage;
  final double borderRadius;
  final String label;
  final int value;
  final int titleFontSize;
  final int fontSize;
  final double? width;
  final int iconSize;

  //controls
  final int min;
  final int max;
  final Function(int) onSliderDragged;
  final Function(bool increment)? onIncrementOrDecrement;

  @override
  State<BigButtonSlider> createState() => _BigButtonSliderState();
}

class _BigButtonSliderState extends State<BigButtonSlider> {
  late Future<ui.Image> _loadImage;

  @override
  void initState() {
    super.initState();
    _loadImage = loadImage("assets/images/obstacle.png");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ui.Image>(
        future: _loadImage,
        builder: (context, snapshot) {
          if (snapshot.hasData || snapshot.data != null) {
            return Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Column(
                    children: [
                      Container(
                        width: widget.width?.w,
                        padding: EdgeInsetsDirectional.symmetric(
                            horizontal: 4.w, vertical: 6.h),
                        decoration: BoxDecoration(
                            border: Border.fromBorderSide(
                                BorderSide(color: Colors.black, width: 1.5.w)),
                            borderRadius:
                                BorderRadius.circular(widget.borderRadius),
                            image: DecorationImage(
                                image: AssetImage(widget.backgroundImage),
                                fit: BoxFit.cover)),
                        child: IntrinsicHeight(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: (widget.onIncrementOrDecrement != null) ? MainAxisAlignment.spaceEvenly: MainAxisAlignment.center,
                                children: [
                                  if (widget.onIncrementOrDecrement != null)
                                    Material(
                                      shape: const CircleBorder(),
                                      color: Colors.transparent,
                                      child: InkWell(
                                          overlayColor: WidgetStateProperty.all<Color>(Colors.yellow.withOpacity(0.5)),
                                          customBorder: const CircleBorder(),
                                          onTap: () {
                                            widget.onIncrementOrDecrement!(
                                                 false);
                                          },
                                          child: Image.asset(
                                            "assets/images/minus.png",
                                            width: 20.w,
                                            height: 20.h,
                                          )),
                                    ),
                                  Expanded(
                                    child: FittedBox(
                                      fit:BoxFit.scaleDown,
                                      child: OutlinedText(
                                        text: widget.label,
                                        fontSize: widget.titleFontSize,
                                      ),
                                    ),
                                  ),
                                  if (widget.onIncrementOrDecrement != null)
                                    Material(
                                      shape: const CircleBorder(),
                                      color: Colors.transparent,
                                      child: InkWell(
                                          overlayColor: WidgetStateProperty.all<Color>(Colors.yellow.withOpacity(0.5)),
                                          customBorder: const CircleBorder(),
                                          onTap: () {
                                            widget.onIncrementOrDecrement!(
                                                 true);
                                          },
                                          child: Image.asset(
                                            "assets/images/plus.png",
                                            width: 20.w,
                                            height: 20.h,
                                          )),
                                    ),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: FittedBox(
                                      fit:BoxFit.scaleDown,
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 26.w,
                                            height: 26.h,
                                            child: Center(
                                              child: Image.asset(
                                                widget.iconImage,
                                                width: widget.iconSize.w,
                                                height: widget.iconSize.h,
                                              ),
                                            ),
                                          ),
                                          OutlinedText(
                                            text: widget.value.toString(),
                                            fontSize: widget.fontSize,
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
                      Padding(
                        padding:
                            EdgeInsetsDirectional.only(start: 8.w, end: 12.w),
                        child: Container(
                          height: 10.h,
                          padding: EdgeInsets.zero,
                          decoration: const BoxDecoration(
                              color: Color(0xff003343),
                              border: Border.fromBorderSide(
                                  BorderSide(color: Colors.black))),
                        ),
                      )
                    ],
                  ),
                ),
                if(widget.buttonType == BigButtonType.balls)
                Positioned(
                  bottom: -2.h,
                  left: 4.w,
                  child: _maxBallsIndicator()
                ),
                Positioned(
                  bottom: 3.h,
                  left: widget.buttonType == BigButtonType.balls ? 30.w : 4.w,
                  right: 8.w,
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 5.h,
                      trackShape: const RectangularSliderTrackShape(),
                      overlayShape:
                          RoundSliderOverlayShape(overlayRadius: 10.w),
                      thumbShape: _SliderThumbImage(snapshot.data!),
                    ),
                    child: Slider(
                        value: widget.value.toDouble(),
                        activeColor: const Color(0xFF4FEA4F),
                        inactiveColor: const Color(0xFF4FEA4F).withOpacity(0.5),
                        min: widget.min.toDouble(),
                        max: widget.max.toDouble(),
                        onChanged: (count) {
                          widget.onSliderDragged(count.toInt());
                        }),
                  ),
                )
              ],
            );
          }
          return SizedBox();
        });
  }

  Future<ui.Image> loadImage(String assetPath) async {
    ByteData data = await rootBundle.load(assetPath);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: 25.h.toInt(), targetWidth: 25.w.toInt());
    ui.FrameInfo fi = await codec.getNextFrame();

    return fi.image;
  }
}

class _SliderThumbImage extends SliderComponentShape {
  final ui.Image image;

  _SliderThumbImage(this.image) : super();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(0, 0);
  }

  @override
  void paint(PaintingContext context, Offset center,
      {required Animation<double> activationAnimation,
      required Animation<double> enableAnimation,
      required bool isDiscrete,
      required TextPainter labelPainter,
      required RenderBox parentBox,
      required SliderThemeData sliderTheme,
      required TextDirection textDirection,
      required double value,
      required double textScaleFactor,
      required Size sizeWithOverflow}) {
    final canvas = context.canvas;
    final imageWidth = image.width;
    final imageHeight = image.height;

    Offset imageOffset = Offset(
      center.dx - (imageWidth / 2),
      center.dy - (imageHeight / 2),
    );

    Paint paint = Paint()..filterQuality = FilterQuality.high;

    canvas.drawImage(image, imageOffset, paint);
  }
}

Widget _maxBallsIndicator() {
  return Container(
    height: 30.h,
    width: 25.w,
    padding: EdgeInsets.symmetric(horizontal: 5.w),
    decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage("assets/images/hexagon.png"),fit: BoxFit.contain)),
    child: Align(
      alignment: const Alignment(0.1, 0),
        child: FittedBox(
          child: OutlinedText(
                text: maxBalls.toString(),
                fontSize: 8,
              ),
        )),
  );
}

enum BigButtonType { balls, bet }
