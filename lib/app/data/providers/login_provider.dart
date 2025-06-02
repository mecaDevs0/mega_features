import 'package:mega_commons/mega_commons.dart';

import '../../network/urls.dart';

class LoginProvider {
  final RestClientDio _restClientDio;
  final String? pathLogin;
  final String? pathRegister;

  LoginProvider({
    required RestClientDio restClientDio,
    this.pathLogin,
    this.pathRegister,
  }) : _restClientDio = restClientDio;

  Future<AuthToken> signInWithEmail(ProfileToken profileToken) async {
    final MegaResponse result = await _restClientDio.post(
      pathLogin ?? Urls.token,
      data: {
        'email': profileToken.email,
        'password': profileToken.password,
      },
    );
    return AuthToken.fromJson(result.data);
  }

  Future<AuthToken> authenticateUserBySocial(ProfileToken profileToken) async {
    final MegaResponse result = await _restClientDio.post(
      pathLogin ?? Urls.token,
      data: {
        'providerId': profileToken.providerId,
        'typeProvider': profileToken.typeProvider,
      },
    );
    return AuthToken.fromJson(result.data);
  }

  Future<AuthToken> registerUserBySocial(ProfileToken profileToken) async {
    final MegaResponse result = await _restClientDio.post(
      pathRegister ?? Urls.register,
      data: profileToken.toJson(),
    );
    return AuthToken.fromJson(result.data);
  }
}
