///Created by Aabhash Shakya on 11/30/24
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:plinko_forge2d/src/widgets/game_widgets/buttons/icon_text_button.dart';

import '../constants/shared_prefs.dart';

class PauseMenu extends StatefulWidget {
  const PauseMenu({
    super.key,
    required this.onResumeTapped,
    required this.onVolumeTapped,
    required this.onExitGameTapped,
  });

  final VoidCallback onResumeTapped;
  final Function(bool isSoundEnabled) onVolumeTapped;
  final VoidCallback onExitGameTapped;

  @override
  State<PauseMenu> createState() => _PauseMenuState();
}

class _PauseMenuState extends State<PauseMenu> {
  late bool isSoundEnabled;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isSoundEnabled = SharedPrefs.isSoundEnabled();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: const Color(0xff008A88),
            borderRadius: BorderRadius.all(Radius.circular(16.w)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xff014f4d),
                spreadRadius: 0,
                blurRadius: 0,
                offset: Offset(0, 7.h), // changes position of shadow
              )
            ]),
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Container(
              decoration: BoxDecoration(
                  color: const Color(0xffE6F9F9),
                  borderRadius: BorderRadius.all(Radius.circular(16.w))),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 46.w, vertical: 16.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // IconTextButton(
                    //     icon: "assets/images/resume.png",
                    //     text: "RESUME",
                    //     onTap: () {
                    //       widget.onResumeTapped();
                    //     }),
                    // SizedBox(height: 8.h),
                    IconTextButton(
                        icon: isSoundEnabled
                            ? "assets/images/volume.png"
                            : "assets/images/volume_off.png",
                        text: isSoundEnabled ? "SOUND ON" : "SOUND OFF",
                        onTap: () {
                          setState(() {
                            isSoundEnabled = !isSoundEnabled;
                          });
                          SharedPrefs.setSoundEnabled(isSoundEnabled);
                          widget.onVolumeTapped(isSoundEnabled);
                        }),
                    SizedBox(height: 8.h),
                    IconTextButton(
                        icon: "assets/images/cancel.png",
                        text: "EXIT GAME",
                        onTap: () {
                          widget.onExitGameTapped();
                        }),
                  ],
                ),
              )),
        ));
  }
}
