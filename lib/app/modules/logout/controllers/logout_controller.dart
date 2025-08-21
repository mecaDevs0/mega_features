import 'package:mega_commons/mega_commons.dart';
import 'package:mega_commons_dependencies/mega_commons_dependencies.dart';

import '../../../data/providers/logout_provider.dart';
import '../../../core/utils/auth_helper.dart';
class LogoutController extends GetxController {
  final LogoutProvider _logoutProvider;

  LogoutController({
    required LogoutProvider logoutProvider,
  }) : _logoutProvider = logoutProvider;

  Future<void> logout({
    Function()? removeUser,
  }) async {
    final String? deviceId = MegaOneSignalConfig.fromCache();
    await _logoutProvider.registerDeviceId(
      deviceId: deviceId!,
    );
    if (removeUser != null) {
      await removeUser();
    }
    AuthHelper.logout();
    await AuthToken.remove();
    // Se quiser garantir que o status de visitante seja limpo:
    // AuthHelper.clearGuestStatus();
  }
}
