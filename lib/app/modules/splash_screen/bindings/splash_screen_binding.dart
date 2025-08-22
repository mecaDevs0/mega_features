import 'package:flutter/material.dart';
import 'package:mega_commons_dependencies/mega_commons_dependencies.dart';

import '../controllers/splash_screen_controller.dart';

class SplashScreenBinding extends Bindings {
  final String homeRoute;
  final Widget body;
  final bool isAnonymous;

  SplashScreenBinding({
    required this.homeRoute,
    required this.body,
    this.isAnonymous = false,
  });
  @override
  void dependencies() {
    Get.put<SplashScreenController>(
      SplashScreenController(
        homeRoute: homeRoute,
        body: body,
        isAnonymous: isAnonymous,
      ),
    );
  }
}
