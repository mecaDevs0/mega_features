import 'package:mega_commons_dependencies/mega_commons_dependencies.dart';

import '../../../../mega_features.dart';

class ChangePasswordBinding extends Bindings {
  final String? pathChangePassword;

  ChangePasswordBinding({this.pathChangePassword});

  @override
  void dependencies() {
    Get.lazyPut<ChangePasswordProvider>(
      () => ChangePasswordProvider(
        restClientDio: Get.find(),
        pathChangePassword: pathChangePassword,
      ),
    );

    Get.lazyPut<ChangePasswordController>(
      () => ChangePasswordController(
        changePasswordProvider: Get.find(),
      ),
    );
  }
}
