import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mega_commons/mega_commons.dart';
import 'package:mega_commons_dependencies/mega_commons_dependencies.dart';

import '../../../../mega_features.dart';

class LoginController extends GetxController {
  final LoginProvider _loginProvider;
  final String _homeRoute;
  final bool _isAnonymous;

  late final Box isLogged;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final auth = LocalAuthentication();
  final storage = const FlutterSecureStorage();

  final RxBool _isLoading = false.obs;

  bool get isLoading => _isLoading.value;

  LoginController({
    required LoginProvider loginProvider,
    required String homeRoute,
    bool isAnonymous = false,
  })  : _loginProvider = loginProvider,
        _homeRoute = homeRoute,
        _isAnonymous = isAnonymous;

  @override
  void onInit() {
    super.onInit();
    isLogged = MegaDataCache.box<bool>();
    storage.read(key: 'authenticated').then(
      (value) async {
        if (value == 'true') {
          await _callLocalAuth();
        }
      },
    );
  }

  Future<void> save({
    bool hasLocalAuth = false,
    Function(MegaResponse)? onError,
  }) async {
    if (formKey.currentState?.validate() == false) {
      return;
    }

    _isLoading.value = true;
    formKey.currentState?.save();
    final profileToken = ProfileToken(
      email: emailController.text,
      password: passwordController.text,
    );

    await MegaRequestUtils.load(
      action: () async {
        final response = await _loginProvider.signInWithEmail(profileToken);
        final isAuthenticated = await storage.read(key: 'authenticated');
        if (isAuthenticated != null && isAuthenticated == 'true') {
          await storage.write(key: 'login', value: profileToken.email);
          await storage.write(key: 'password', value: profileToken.password);
        }

        if (hasLocalAuth) {
          await _localAuth(
            login: profileToken.email!,
            password: profileToken.password!,
          );
        }
        ProfileToken.save(profileToken);
        await _successLogin(response);
      },
      onError: (error) {
        if (onError != null) {
          onError(error);
          return;
        }
        MegaSnackbar.showErroSnackBar(
          error.message ?? 'Não foi possível realizar o login.',
        );
      },
      onFinally: () => _isLoading.value = false,
    );
  }

  Future<bool> canAuthenticate() async {
    final canCheckBiometrics = await auth.canCheckBiometrics;
    final isDeviceSupported = await auth.isDeviceSupported();
    final canAuthenticate = canCheckBiometrics || isDeviceSupported;
    return canAuthenticate;
  }

  Future<void> _localAuth({
    required String login,
    required String password,
  }) async {
    final value = await storage.read(key: 'authenticated');
    if (value == 'true') {
      return;
    }

    if (!await canAuthenticate()) {
      return;
    }

    final availableBiometrics = await auth.getAvailableBiometrics();
    if (availableBiometrics.isEmpty) {
      return;
    }

    final authenticated = await auth.authenticate(
      localizedReason: 'Autentique-se para acessar o app',
      options: const AuthenticationOptions(
        stickyAuth: true,
        biometricOnly: true,
      ),
    );
    if (authenticated) {
      await storage.write(key: 'login', value: login);
      await storage.write(key: 'password', value: password);
      await storage.write(key: 'authenticated', value: 'true');
    }
  }

  Future<void> _callLocalAuth() async {
    final authenticated = await auth.authenticate(
      localizedReason: 'Autentique-se para acessar o app',
      options: const AuthenticationOptions(
        stickyAuth: true,
      ),
    );
    if (authenticated) {
      final login = await storage.read(key: 'login');
      final password = await storage.read(key: 'password');
      final profileToken = ProfileToken(
        email: login,
        password: password,
      );
      _isLoading.value = true;
      await MegaRequestUtils.load(
        action: () async {
          final response = await _loginProvider.signInWithEmail(profileToken);
          ProfileToken.save(profileToken);
          await _successLogin(response);
        },
        onFinally: () => _isLoading.value = false,
      );
    }
  }

  Future<void> _successLogin(AuthToken authToken) async {
    await authToken.save();
    await isLogged.put(
      'isLogged',
      true,
    );
    if (_isAnonymous) {
      Get.back(result: true);
    } else {
      Get.offAllNamed(_homeRoute);
    }
  }

  Future<void> loginWithApple({Function(MegaResponse)? onError}) async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    if (appleCredential.email != null &&
        appleCredential.userIdentifier != null) {
      final appleModel = AppleModel(
        givenName: appleCredential.givenName ?? '',
        userIdentifier: appleCredential.userIdentifier!,
        email: appleCredential.email!,
      );
      await AppleModel.save(appleModel);
    }

    final localAppleCredential = AppleModel.fromCache;
    if (localAppleCredential == null) {
      MegaSnackbar.showErroSnackBar('Erro ao entrar com a Apple.');
      return;
    }
    _isLoading.toggle();
    final ProfileToken profileToken = ProfileToken(
      fullName: localAppleCredential.givenName,
      providerId: localAppleCredential.userIdentifier,
      email: localAppleCredential.email,
      typeProvider: 2,
    );
    await MegaRequestUtils.load(
      action: () async {
        final token =
            await _loginProvider.authenticateUserBySocial(profileToken);
        await _successLogin(token);
        ProfileToken.save(profileToken);
      },
      onError: (error) {
        if (error.data != null && error.data['isRegister'] as bool == true) {
          _registerProfile(profileToken);
          return;
        }
        if (onError != null) {
          onError(error);
          return;
        }
        MegaSnackbar.showErroSnackBar('Erro ao entrar com a Apple.');
      },
      onFinally: _isLoading.toggle,
    );
  }

  Future<void> loginWithGoogle({
    Function(MegaResponse)? onError,
  }) async {
    final _googleSignIn = GoogleSignIn(scopes: ['profile', 'email']);
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser != null) {
      _isLoading.toggle();
      final profileToken = ProfileToken(
        fullName: googleUser.displayName,
        email: googleUser.email,
        providerId: googleUser.id,
        typeProvider: 3,
      );
      await MegaRequestUtils.load(
        action: () async {
          final token =
              await _loginProvider.authenticateUserBySocial(profileToken);
          await _successLogin(token);
          ProfileToken.save(profileToken);
        },
        onError: (error) async {
          if (error.data != null && error.data['isRegister'] as bool == true) {
            await _registerProfile(profileToken);
            return;
          }
          if (onError != null) {
            onError(error);
            return;
          }
          MegaSnackbar.showErroSnackBar('Erro ao entrar com a Google.');
        },
        onFinally: () => _isLoading.toggle(),
      );
    }
  }

  Future<void> loginWithFacebook({
    Function(MegaResponse)? onError,
  }) async {
    final LoginResult loginResult = await FacebookAuth.instance.login();

    if (loginResult.status == LoginStatus.success) {
      final userData = await FacebookAuth.instance.getUserData();
      _isLoading.toggle();
      final ProfileToken profileToken = ProfileToken(
        providerId: loginResult.accessToken?.userId,
        typeProvider: 1,
        fullName: userData['name'],
        email: userData['email'],
      );
      await MegaRequestUtils.load(
        action: () async {
          final token =
              await _loginProvider.authenticateUserBySocial(profileToken);
          await _successLogin(token);
          ProfileToken.save(profileToken);
        },
        onError: (error) {
          if (error.data != null && error.data['isRegister'] as bool == true) {
            _registerProfile(profileToken);
            return;
          }
          if (onError != null) {
            onError(error);
            return;
          }
          MegaSnackbar.showErroSnackBar('Erro ao entrar com o Facebook');
        },
        onFinally: () => _isLoading.toggle(),
      );
    }
  }

  Future<void> _registerProfile(ProfileToken profileToken) async {
    await MegaRequestUtils.load(
      action: () async {
        final token = await _loginProvider.registerUserBySocial(profileToken);
        await _successLogin(token);
      },
    );
  }
}
