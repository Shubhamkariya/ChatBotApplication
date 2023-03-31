import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/Utils/CheckAuth.dart';

enum DemoType {
  custom,
  gif,
  fadeIn,
  scale,
  dynamicNextScreenFadeIn,
  usingBackgroundImage,
  usingGradient,
}

// ignore: must_be_immutable
class DemoHelper extends StatefulWidget {
  DemoHelper({super.key, required this.demoType});

  DemoType demoType;

  @override
  State<DemoHelper> createState() => _DemoHelperState();
}


class _DemoHelperState extends State<DemoHelper> {

  @override
  Widget build(BuildContext context) {
    Widget child;
   return FlutterSplashScreen.gif(
          gifPath: 'assets/example.gif',
          gifWidth: 269,
          gifHeight: 474,
          defaultNextScreen: CheckAuth(),

          duration: const Duration(milliseconds: 3700),
          onInit: () async {
            debugPrint("onInit 1");
            debugPrint("onInit 2");
          },
          onEnd: () async {
            debugPrint("onEnd 1");
            debugPrint("onEnd 2");
          },

        );

  }
}