import 'package:mega_commons/mega_commons.dart';

import '../../network/urls.dart';

class ForgotPasswordProvider {
  final RestClientDio _restClientDio;
  final String? pathForgotPassword;

  ForgotPasswordProvider({
    required RestClientDio restClientDio,
    this.pathForgotPassword,
  }) : _restClientDio = restClientDio;

  Future<MegaResponse> onSubmitRequest({
    required bool isSendByEmail,
    String? email,
    String? phone,
  }) async {
    final response = await _restClientDio.post(
      pathForgotPassword ?? Urls.forgotPassword,
      data: isSendByEmail ? {'email': email} : {'phone': phone},
    );
    return response;
  }
}
