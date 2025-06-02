import 'package:flutter/material.dart';
import 'package:mega_commons_dependencies/mega_commons_dependencies.dart';

import '../controllers/splash_screen_controller.dart';

class SplashScreenView extends GetView<SplashScreenController> {
  const SplashScreenView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => controller.bodyContainer),
    );
  }
}
