import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mega_commons/mega_commons.dart';
import 'package:mega_features/app/data/exceptions/email_in_use_exception.dart';

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
    try {
      final MegaResponse result = await _restClientDio.post(
        pathRegister ?? Urls.register,
        data: profileToken.toJson(),
      );
      return AuthToken.fromJson(result.data);
    } catch (e, s) { // Catching generic exception with stack trace
      if (kDebugMode) {
        print('Exception caught in registerUserBySocial. Type: ${e.runtimeType}');
        print('Exception details: $e');
        print('Stack trace: $s');
      }

      // Check if the caught exception is a MegaResponse
      if (e is MegaResponse) {
        if (kDebugMode) {
          print('Caught MegaResponse. Message: ${e.message}');
          print('Trimmed message: ${e.message?.trim()}'); // Log trimmed message
          print('Comparison result: ${e.message?.trim() == 'E-mail em uso.'}'); // Log comparison result
        }

        // If the error message is "E-mail em uso.", it means a profile with that email
        // already exists. We proceed to call the authentication endpoint to link
        // the new social credential to the existing profile.
        if (e.message?.trim() == 'E-mail em uso.') { // Use trim() for comparison
          if (kDebugMode) {
            print('"E-mail em uso" detected. Throwing EmailInUseException.');
          }
          throw EmailInUseException(e.message!, profileToken);
        }
      } else if (e is DioException) {
        // Keep DioException check for other potential Dio errors not wrapped in MegaResponse
        if (kDebugMode) {
          print('Caught DioException (not wrapped in MegaResponse). Response data: ${e.response?.data}');
        }
        // You might want to add specific handling for other DioException types here if needed
      }

      // If the exception is not the one we are handling, rethrow it to be
      // managed by the upper layers of the application.
      if (kDebugMode) {
        print('Rethrowing unhandled exception.');
      }
      rethrow;
    }
  }

  Future<AuthToken> linkSocialAccount(ProfileToken profileToken) async {
    final MegaResponse result = await _restClientDio.post(
      Urls.linkSocialAccount,
      data: {
        'email': profileToken.email,
        'providerId': profileToken.providerId,
        'typeProvider': profileToken.typeProvider,
      },
    );
    return AuthToken.fromJson(result.data);
  }
}

