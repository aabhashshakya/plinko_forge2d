import 'package:flutter/material.dart';
import 'package:plinko_forge2d/src/utils/routes.dart';
import 'package:plinko_forge2d/src/widgets/welcome_screen.dart';

void main() {
  runApp(const MaterialApp(
    home: WelcomeScreen(),
    onGenerateRoute: AppRoutes.onGenerateRoute,
  ));
}
