import 'package:mega_commons_dependencies/mega_commons_dependencies.dart';

import '../../../data/providers/providers.dart';
import '../controllers/notification_controller.dart';

class NotificationBinding extends Bindings {
  final String? pathNotification;
  final String? screenNotificationDetail;

  NotificationBinding({
    this.pathNotification,
    this.screenNotificationDetail,
  });
  @override
  void dependencies() {
    Get.lazyPut<NotificationProvider>(
      () => NotificationProvider(
        restClientDio: Get.find(),
        pathNotification: pathNotification,
      ),
    );

    Get.lazyPut<NotificationController>(
      () => NotificationController(
        screenNotificationDetail: screenNotificationDetail,
      ),
    );
  }
}
