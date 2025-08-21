import 'package:mega_commons_dependencies/mega_commons_dependencies.dart';

import '../../../../mega_features.dart';

class LoginBinding extends Bindings {
  final String _homeRoute;
  final String? pathLogin;
  final String registerRoute;
  final bool isAnonymous;

  LoginBinding({
    required String homeRoute,
    this.pathLogin,
    this.registerRoute = '',
    this.isAnonymous = false,
  }) : _homeRoute = homeRoute;

  @override
  void dependencies() {
    Get.lazyPut<LoginProvider>(
      () => LoginProvider(
        restClientDio: Get.find(),
        pathLogin: pathLogin,
      ),
    );

    Get.lazyPut<LoginController>(
      () => LoginController(
        loginProvider: Get.find(),
        homeRoute: _homeRoute,
        isAnonymous: isAnonymous,
      ),
    );
  }
}
