import 'package:mega_commons/mega_commons.dart';

import '../../network/urls.dart';

class LogoutProvider {
  final RestClientDio _restClientDio;
  final String _path;

  LogoutProvider({required RestClientDio restClientDio, String? path})
      : _restClientDio = restClientDio,
        _path = path ?? Urls.registerUnregister;

  Future<void> logout() async {
    await _restClientDio.post(_path);
  }

  Future<void> registerDeviceId({
    required String deviceId,
  }) async {
    await _restClientDio.post(
      _path,
      data: {
        'deviceId': deviceId,
        'isRegister': false,
      },
    );
  }
}
