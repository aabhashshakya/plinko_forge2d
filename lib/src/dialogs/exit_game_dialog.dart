///Created by Aabhash Shakya on 11/30/24
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:plinko_forge2d/src/widgets/game_widgets/buttons/icon_text_button.dart';
import 'package:plinko_forge2d/src/widgets/game_widgets/buttons/rounded_button.dart';
import 'package:plinko_forge2d/src/widgets/outlined_text.dart';

class ExitGameDialog extends StatelessWidget {
  const ExitGameDialog({
    super.key,
     this.onYesTapped,
    this.onNoTapped,
  });

  final VoidCallback? onYesTapped;
  final VoidCallback? onNoTapped;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: const Color(0xff008A88),
            borderRadius: BorderRadius.all(Radius.circular(16.w)),
            boxShadow:  [
              BoxShadow(
                color: const Color(0xff014f4d),
                spreadRadius: 0,
                blurRadius: 0,
                offset: Offset(0, 6.h), // changes position of shadow
              )
            ]),
        child: Padding(
          padding: EdgeInsetsDirectional.only(start:8.w,end:8.w,top:8.w,bottom:0.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Expanded(child: Center(child: OutlinedText(text: "EXIT GAME?",align: TextAlign.center,))),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        onNoTapped?.call();
                        Navigator.of(context).pop();
                      },
                      child: Image.asset(
                        "assets/images/cancel.png",
                        height: 20.h,
                        width: 20.h,
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 16.h),
              Container(
                  decoration: BoxDecoration(
                      color: const Color(0xffE6F9F9),
                      borderRadius: BorderRadius.all(Radius.circular(16.w))),
                  child: Padding(
                    padding:  EdgeInsets.symmetric(horizontal: 20.w,vertical: 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Are you sure you want to leave Zone Plinko?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                              color: const Color(0xffB3261E)),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RoundedButton(
                              borderRadius: 8,
                                backgroundImage: "assets/images/green_button_bg.png",
                                label: "YES",
                                onTap: (){
                                  onYesTapped?.call();
                                  exit(0);
                                },
                                width: 90.w),
                            SizedBox(width: 8.w),
                            RoundedButton(
                                borderRadius: 8,
                                backgroundImage: "assets/images/grey_button_bg.png",
                                label: "CANCEL",
                                onTap: (){
                                  onNoTapped?.call();
                                  Navigator.of(context).pop();
                                },
                                width: 90.w),
                          ],
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ));
  }
}
