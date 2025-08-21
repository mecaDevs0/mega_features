import 'package:mega_commons/mega_commons.dart';
import 'package:mega_commons_dependencies/mega_commons_dependencies.dart';

import '../../../data/providers/bank_account_provider.dart';
import '../../../network/urls.dart';
import '../controllers/bank_account_controller.dart';

class BankAccountBinding extends Bindings {
  BankAccountBinding();

  @override
  void dependencies() {
    Get.put<BankAccountProvider>(
      BankAccountProvider(
        megaApi: RestClientDio(Urls.baseUrlMegaleios),
        restClientDio: Get.find(),
      ),
    );

    Get.put<BankAccountController>(
      BankAccountController(
        bankProvider: Get.find(),
      ),
    );
  }
}
