import 'package:mega_commons/mega_commons.dart';

import '../../network/urls.dart';

class ChangePasswordProvider {
  final RestClientDio _restClientDio;
  final String? pathChangePassword;

  ChangePasswordProvider({
    required RestClientDio restClientDio,
    this.pathChangePassword,
  }) : _restClientDio = restClientDio;

  Future<MegaResponse> onSubmitRequest(
    ChangePasswordParams changePasswordParams,
  ) async {
    final response = await _restClientDio.post(
      pathChangePassword ?? Urls.changePassword,
      data: {
        'currentPassword': changePasswordParams.currentPassword,
        'newPassword': changePasswordParams.newPassword,
      },
    );
    return response;
  }
}

class ChangePasswordParams {
  final String currentPassword;
  final String newPassword;

  ChangePasswordParams({
    required this.currentPassword,
    required this.newPassword,
  });
}
