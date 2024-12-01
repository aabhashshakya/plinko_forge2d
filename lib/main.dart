import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plinko_forge2d/src/constants/shared_prefs.dart';
import 'package:plinko_forge2d/src/utils/routes.dart';
import 'package:plinko_forge2d/src/screens/welcome_screen.dart';

void main() async{
  var widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefs.init();
  runApp( ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) {
      return  MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme().apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
        ),
        builder: (context, child) {
          return MediaQuery.withNoTextScaling(
            child: child!,
          );
        },
        home: WelcomeScreen(),
        onGenerateRoute: AppRoutes.onGenerateRoute,
      );
    }
  ));
}
