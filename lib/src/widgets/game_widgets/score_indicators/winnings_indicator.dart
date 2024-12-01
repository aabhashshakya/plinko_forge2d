///Created by Aabhash Shakya on 11/29/24
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:plinko_forge2d/src/widgets/outlined_text.dart';

class WinningsIndicator extends StatelessWidget {
  const WinningsIndicator(
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
          Image.asset("assets/images/coin_framed.png"),
          Container(
            height: 28.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex:4,
                  child: Container(
                    width: 60.w,
                    padding: EdgeInsetsDirectional.only(start: 4.w, end: 10.w),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.only(
                            bottomEnd: Radius.circular(4.w),
                            topEnd: Radius.circular(4.w)),
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
                      alignment: AlignmentDirectional.centerStart,
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
                    padding: EdgeInsetsDirectional.only(start: 4.w, end: 6.w),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.only(
                            bottomEnd: Radius.circular(4.w)),
                        border: const Border.fromBorderSide(
                            BorderSide(color: Colors.black,width: 0.5)),
                        color: const Color(0xff003343)),
                    child: FittedBox(
                      alignment: AlignmentDirectional.centerStart,
                      child: OutlinedText(
                        text: title.toString(),
                        fontSize: 13,
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
