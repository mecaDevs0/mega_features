import 'dart:async';
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
    try {
      if (kDebugMode) {
        print('🔧 [LOGIN_PROVIDER] Iniciando signInWithEmail');
        print('🔧 [LOGIN_PROVIDER] Email: ${profileToken.email}');
        print('🔧 [LOGIN_PROVIDER] Password: ${profileToken.password != null ? '***' : 'null'}');
        print('🔧 [LOGIN_PROVIDER] URL: ${pathLogin ?? Urls.token}');
      }
      
      final MegaResponse result = await _restClientDio.post(
        pathLogin ?? Urls.token,
        data: {
          'email': profileToken.email,
          'password': profileToken.password,
        },
      );
      
      if (kDebugMode) {
        print('🔧 [LOGIN_PROVIDER] Response status: ${result.statusCode}');
        print('🔧 [LOGIN_PROVIDER] Response data: ${result.data}');
      }
      
      // Verificar se result.data não é null antes de tentar criar AuthToken
      if (result.data == null) {
        if (kDebugMode) {
          print('🔧 [LOGIN_PROVIDER] ERRO: result.data é null');
        }
        throw MegaResponse(
          message: 'Resposta inválida do servidor. Tente novamente.',
          statusCode: 500,
          erro: true,
        );
      }
      
      final authToken = AuthToken.fromJson(result.data);
      if (kDebugMode) {
        print('🔧 [LOGIN_PROVIDER] AuthToken criado com sucesso');
        print('🔧 [LOGIN_PROVIDER] Token: ${authToken.accessToken != null ? '***' : 'null'}');
      }
      
      return authToken;
    } on DioException catch (e) {
      // Tratamento específico para timeout do MongoDB
      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        if (errorData != null && errorData is Map<String, dynamic>) {
          final messageEx = errorData['messageEx'] as String?;
          if (messageEx?.contains('timeout') == true || 
              messageEx?.contains('MongoDB') == true ||
              messageEx?.contains('CompositeServerSelector') == true) {
            if (kDebugMode) {
              print('🔧 Timeout do MongoDB detectado no login');
            }
            throw MegaResponse(
              message: 'Servidor temporariamente sobrecarregado. Tente novamente em alguns minutos.',
              statusCode: 400,
              erro: true,
            );
          }
        }
      }
      
      // Re-throw outros erros
      rethrow;
    } catch (e) {
      // Tratamento para outros tipos de erro
      if (kDebugMode) {
        print('🔧 Erro inesperado no login: $e');
      }
      throw MegaResponse(
        message: 'Erro inesperado. Tente novamente.',
        statusCode: 500,
        erro: true,
      );
    }
  }

  Future<AuthToken> authenticateUserBySocial(ProfileToken profileToken) async {
    try {
      final MegaResponse result = await _restClientDio.post(
        pathLogin ?? Urls.token,
        data: {
          'providerId': profileToken.providerId,
          'typeProvider': profileToken.typeProvider,
        },
      );
      return AuthToken.fromJson(result.data);
    } on DioException catch (e) {
      // Tratamento específico para timeout do MongoDB
      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        if (errorData != null && errorData is Map<String, dynamic>) {
          final messageEx = errorData['messageEx'] as String?;
          if (messageEx?.contains('timeout') == true || 
              messageEx?.contains('MongoDB') == true ||
              messageEx?.contains('CompositeServerSelector') == true) {
            if (kDebugMode) {
              print('🔧 Timeout do MongoDB detectado na autenticação social');
            }
            throw MegaResponse(
              message: 'Servidor temporariamente sobrecarregado. Tente novamente em alguns minutos.',
              statusCode: 400,
              erro: true,
            );
          }
        }
      }
      
      // Re-throw outros erros
      rethrow;
    }
  }

  Future<AuthToken> registerUserBySocial(ProfileToken profileToken) async {
    try {
      final MegaResponse result = await _restClientDio.post(
        pathRegister ?? Urls.register,
        data: profileToken.toJson(),
      );
      return AuthToken.fromJson(result.data);
    } on DioException catch (e) {
      // Tratamento específico para timeout do MongoDB
      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        if (errorData != null && errorData is Map<String, dynamic>) {
          final messageEx = errorData['messageEx'] as String?;
          if (messageEx?.contains('timeout') == true || 
              messageEx?.contains('MongoDB') == true ||
              messageEx?.contains('CompositeServerSelector') == true) {
            if (kDebugMode) {
              print('🔧 Timeout do MongoDB detectado no registro social');
            }
            throw MegaResponse(
              message: 'Servidor temporariamente sobrecarregado. Tente novamente em alguns minutos.',
              statusCode: 400,
              erro: true,
            );
          }
        }
      }
      
      // Re-throw outros erros
      rethrow;
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
    try {
      final MegaResponse result = await _restClientDio.post(
        Urls.linkSocialAccount,
        data: {
          'email': profileToken.email,
          'providerId': profileToken.providerId,
          'typeProvider': profileToken.typeProvider,
        },
      );
      return AuthToken.fromJson(result.data);
    } on DioException catch (e) {
      // Tratamento específico para timeout do MongoDB
      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        if (errorData != null && errorData is Map<String, dynamic>) {
          final messageEx = errorData['messageEx'] as String?;
          if (messageEx?.contains('timeout') == true || 
              messageEx?.contains('MongoDB') == true ||
              messageEx?.contains('CompositeServerSelector') == true) {
            if (kDebugMode) {
              print('🔧 Timeout do MongoDB detectado na vinculação de conta social');
            }
            throw MegaResponse(
              message: 'Servidor temporariamente sobrecarregado. Tente novamente em alguns minutos.',
              statusCode: 400,
              erro: true,
            );
          }
        }
      }
      
      // Re-throw outros erros
      rethrow;
    }
  }
}

