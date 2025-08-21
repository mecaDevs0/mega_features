import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:mega_commons_dependencies/mega_commons_dependencies.dart';

class FirebaseConfig {
  FirebaseConfig._();

  static Future<void> initialize({FirebaseOptions? options}) async {
    await Firebase.initializeApp(options: options);

    if (kIsWeb) {
      return;
    }

    try {
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(kReleaseMode);

      FlutterError.onError = (FlutterErrorDetails details) {
        FirebaseCrashlytics.instance.recordFlutterError(details);
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack);
        return true;
      };

      Isolate.current.addErrorListener(
        RawReceivePort((List<dynamic> errorAndStackTrace) {
          FirebaseCrashlytics.instance.recordError(
            errorAndStackTrace[0],
            errorAndStackTrace[1],
          );
        }).sendPort,
      );
    } catch (error) {
      debugPrint('Couldn’t load FirebaseCrashlytics. $error');
    }
  }

  static void reportError(dynamic exception, StackTrace stackTrace) {
    ErrorReport.externalFailureError(exception, stackTrace, 'CUSTOM_ERROR');
  }
}

class ErrorReport {
  ErrorReport._();

  static Future<void> _report(
    dynamic exception,
    StackTrace stackTrace,
    String tag,
  ) async {
    if (exception != null) {
      debugPrintStack(label: tag, stackTrace: stackTrace);

      await FirebaseCrashlytics.instance.setCustomKey('Error_Tag', tag);
      await FirebaseCrashlytics.instance
          .setCustomKey('Exception_Type', exception.runtimeType.toString());
      await FirebaseCrashlytics.instance
          .setCustomKey('StackTrace', stackTrace.toString());

      await FirebaseCrashlytics.instance
          .log('Error occurred: ${exception.toString()}');
      await FirebaseCrashlytics.instance.recordError(exception, stackTrace);
    }
  }

  static void externalFailureError(
    dynamic exception,
    StackTrace? stackTrace,
    String? reportTag,
  ) {
    if (stackTrace != null && reportTag != null) {
      _report(exception, stackTrace, 'EXTERNAL_FAILURE: $reportTag');
    }
  }
}
