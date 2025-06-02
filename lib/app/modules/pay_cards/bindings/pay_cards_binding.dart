import 'package:mega_commons_dependencies/mega_commons_dependencies.dart';

import '../../../data/providers/pay_cards_provider.dart';
import '../controllers/pay_cards_controller.dart';

class PayCardsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PayCardsProvider>(
      () => PayCardsProvider(
        restClientDio: Get.find(),
      ),
    );
    Get.put<PayCardsController>(
      PayCardsController(
        payCardsProvider: Get.find(),
      ),
    );
  }
}
