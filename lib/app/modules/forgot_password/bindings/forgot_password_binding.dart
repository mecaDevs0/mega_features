import 'package:mega_commons_dependencies/mega_commons_dependencies.dart';

import '../../../../mega_features.dart';

class ForgotPasswordBinding extends Bindings {
  final String? pathForgotPassword;

  ForgotPasswordBinding({this.pathForgotPassword});
  @override
  void dependencies() {
    Get.lazyPut<ForgotPasswordProvider>(
      () => ForgotPasswordProvider(
        restClientDio: Get.find(),
        pathForgotPassword: pathForgotPassword,
      ),
    );

    Get.lazyPut<ForgotPasswordController>(
      () => ForgotPasswordController(
        forgotPasswordProvider: Get.find(),
      ),
    );
  }
}
