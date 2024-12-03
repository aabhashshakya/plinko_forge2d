import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:plinko_forge2d/src/screens/game_app.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
  });

  static const String routeName = 'WelcomeScreen';

  static Route getRoute(RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => const WelcomeScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            GameApp.routeName,
            arguments: false // enable/disable simulation option
          );
        },
        child: Container(
          width: double.maxFinite,
          height: double.maxFinite,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xff112F4B),
                  Color(0xff115666),
                  Color(0xff128E8E),
                ],
                stops: [
                  0.54,
                  0.84,
                  1
                ]),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/logo.png",
                height: 325.h,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/pointing_hand.png",
                    height: 20.h,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    "TAP TO PLAY",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold),
                  )
                      .animate(onPlay: (controller) => controller.repeat())
                      .fadeIn(duration: 1.seconds)
                      .then()
                      .fadeOut(duration: 1.seconds),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
