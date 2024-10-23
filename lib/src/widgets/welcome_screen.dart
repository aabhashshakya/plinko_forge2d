import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:plinko_forge2d/src/game_app.dart';

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
        onTap: (){
          Navigator.pushNamed(context,
              GameApp.routeName,
             );
        },
        child: Container(
          width: double.maxFinite,
          height: double.maxFinite,
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/bg.jpeg"),
                  fit: BoxFit.cover)),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Z O N E   P L I N K O",
                style: TextStyle(color: Colors.orange,fontSize: 30,fontWeight: FontWeight.bold),
              ).animate().slideY(duration: 750.ms, begin: -2, end: 0),
              const SizedBox(height: 30),
              const Text(
                "T A P   T O   P L A Y",
                style: TextStyle(color: Colors.white,fontSize: 14,fontWeight: FontWeight.bold),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .fadeIn(duration: 1.seconds)
                  .then()
                  .fadeOut(duration: 1.seconds),
            ],
          ),
        ),
      ),
    );
  }
}