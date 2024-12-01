///Created by Aabhash Shakya on 11/29/24
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../flame/components/money_multiplier.dart';
import '../../outlined_text.dart';

Widget multiplierItem(MoneyMultiplier multiplier) {
  return Container(margin: EdgeInsets.only(bottom: 3.h),
    width: 30.w,
    padding: EdgeInsets.symmetric(horizontal: 1.w,vertical: 6.h),
    decoration: BoxDecoration(
      color: moneyMultiplierAsset[multiplier.column],
      borderRadius: BorderRadius.all(Radius.circular(8.w)),
      boxShadow: [
        BoxShadow(
          color: moneyMultiplierAsset[multiplier.column].withOpacity(0.5),
          spreadRadius: 0,
          blurRadius: 0,
          offset: const Offset(0, 3), // changes position of shadow
        ),
      ],
    ),
    child: Center(
        child: FittedBox(
          child: OutlinedText(
                text: "x${multiplier.multiplier}",
                fontSize: 8,
              ),
        )),
  );
}

//total 15 colors
const moneyMultiplierAsset = [
  // Add this const
  Color(0xffFA4440),
  Color(0xffF94159),
  Color(0xffF3742D),
  Color(0xffF89120),
  Color(0xff4BAB86),
  Color(0xff92BE6F),
  Color(0xff4BAB86),
  Color(0xffF1C751), //center
  Color(0xff4BAB86),
  Color(0xff92BE6F),
  Color(0xff4BAB86),
  Color(0xffF89120),
  Color(0xffF3742D),
  Color(0xffF94159),
  Color(0xffFA4440),
];
