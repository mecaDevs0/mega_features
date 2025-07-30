import 'package:mega_commons/shared/models/profile_token.dart';

class EmailInUseException implements Exception {
  final String message;
  final ProfileToken profileToken;

  EmailInUseException(this.message, this.profileToken);

  @override
  String toString() => 'EmailInUseException: $message';
}
