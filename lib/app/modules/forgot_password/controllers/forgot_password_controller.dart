import 'package:flutter/material.dart';
import 'package:mega_commons/mega_commons.dart';
import 'package:mega_commons_dependencies/mega_commons_dependencies.dart';

import '../../../../mega_features.dart';

class ForgotPasswordController extends GetxController {
  final ForgotPasswordProvider _forgotPasswordProvider;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final RxBool _isLoading = false.obs;

  ForgotPasswordController({
    required ForgotPasswordProvider forgotPasswordProvider,
  }) : _forgotPasswordProvider = forgotPasswordProvider;

  bool get isLoading => _isLoading.value;

  set isSendByEmail(bool value) => _isLoading.value = value;

  Future<bool> onSubmit({
    bool isSendByEmail = true,
    bool isBackScreen = true,
  }) async {
    bool isSuccess = false;
    if (formKey.currentState!.validate()) {
      _isLoading.value = true;
      await MegaRequestUtils.load(
        action: () async {
          final megaResponse = await _forgotPasswordProvider.onSubmitRequest(
            isSendByEmail: isSendByEmail,
            email: emailController.text,
            phone: phoneController.text,
          );

          if (isBackScreen) {
            Get.back();
            MegaSnackbar.showSuccessSnackBar(megaResponse.message!);
          }

          isSuccess = true;
        },
        onError: (megaResponse) {
          MegaSnackbar.showErroSnackBar(megaResponse.message!);
          isSuccess = false;
        },
        onFinally: () {
          _isLoading.value = false;
        },
      );
    }
    return isSuccess;
  }
}
