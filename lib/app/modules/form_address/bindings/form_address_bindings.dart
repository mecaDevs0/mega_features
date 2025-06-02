import 'package:mega_commons/shared/helpers/custom_dio/rest_client_dio.dart';
import 'package:mega_commons_dependencies/mega_commons_dependencies.dart';

import '../../../data/providers/address_provider.dart';
import '../../../network/urls.dart';
import '../controllers/form_address_controller.dart';

class FormAddressBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddressProvider>(
      () => AddressProvider(
        restClientDio: RestClientDio(Urls.baseUrlMegaleios),
      ),
    );

    Get.lazyPut<FormAddressController>(
      () => FormAddressController(
        addressProvider: Get.find(),
      ),
    );
  }
}
