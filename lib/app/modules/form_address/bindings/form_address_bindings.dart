import 'package:mega_commons/mega_commons.dart';
import 'package:mega_commons_dependencies/mega_commons_dependencies.dart';

import '../../../data/providers/address_provider.dart';
import '../controllers/form_address_controller.dart';

class FormAddressBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddressProvider>(
      () => AddressProvider(
        restClientDio: Get.find<RestClientDio>(),
      ),
    );

    Get.lazyPut<FormAddressController>(
      () => FormAddressController(
        addressProvider: Get.find(),
      ),
    );
  }
}
