import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mega_commons/mega_commons.dart';
import 'package:mega_commons_dependencies/mega_commons_dependencies.dart';

class SplashScreenController extends GetxController {
  final _bodyContainer = Rx<Widget>(Container());

  final String homeRoute;
  final Widget body;
  final bool isAnonymous;

  SplashScreenController({
    required this.homeRoute,
    required this.body,
    this.isAnonymous = false,
  });

  Widget get bodyContainer => _bodyContainer.value;

  @override
  void onInit() {
    _bodyContainer.value = body;
    startTimer();
    super.onInit();
  }

  Timer startTimer() {
    const Duration _duration = Duration(milliseconds: 3200);
    return Timer(_duration, navigate);
  }

  void navigate() {
    final AuthToken? accessTokenData = AuthToken.fromCache();

    if (isAnonymous) {
      Get.offAllNamed(homeRoute);
      return;
    }

    if (accessTokenData == null) {
      Get.offAllNamed('/login');
      return;
    }

    Get.offAllNamed(homeRoute);
  }
}
