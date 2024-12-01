///Created by Aabhash Shakya on 11/29/24
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:plinko_forge2d/src/widgets/outlined_text.dart';

class BetIndicator extends StatelessWidget {
  const BetIndicator(
      {super.key, required this.title, required this.value});

  final String title;
  final int value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 37.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 28.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex:4,
                  child: Container(
                    width: 60.w,
                    padding: EdgeInsetsDirectional.only(start: 10.w, end: 4.w),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.only(
                            bottomStart: Radius.circular(4.w),
                            topStart: Radius.circular(4.w)),
                        border: const Border.fromBorderSide(
                            BorderSide(color: Colors.black,width: 0.5)),
                        gradient: const LinearGradient(colors: [
                          Color(0xff045f7c),
                          Color(0xff003343),
                          Color(0xff003343),
                          Color(0xff003343)
                        ], stops: [
                          0,
                          0.6,
                          0.6,
                          1.0
                        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                    child: FittedBox(
                      alignment: AlignmentDirectional.centerEnd,
                      child: OutlinedText(
                        text: value.toString(),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex:3,
                  child: Container(
                    padding: EdgeInsetsDirectional.only(start: 6.w, end: 4.w),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.only(
                            bottomStart: Radius.circular(4.w)),
                        border: const Border.fromBorderSide(
                            BorderSide(color: Colors.black,width: 0.5)),
                        color: const Color(0xff003343)),
                    child: FittedBox(
                      alignment: AlignmentDirectional.centerEnd,
                      child: OutlinedText(
                        text: title.toString(),
                        fontSize: 13,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Image.asset("assets/images/coin_framed.png"),
        ],
      ),
    );
  }
}
