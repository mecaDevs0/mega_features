import 'package:mega_commons_dependencies/mega_commons_dependencies.dart';

import '../../../data/providers/logout_provider.dart';
import '../controllers/logout_controller.dart';

class LogoutBindings extends Bindings {
  final String? path;

  LogoutBindings({this.path});

  @override
  void dependencies() {
    Get.lazyPut<LogoutController>(
      () => LogoutController(
        logoutProvider: Get.find(),
      ),
    );

    Get.lazyPut<LogoutProvider>(
      () => LogoutProvider(
        restClientDio: Get.find(),
        path: path,
      ),
    );
  }
}
