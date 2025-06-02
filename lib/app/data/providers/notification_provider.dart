import 'package:mega_commons/mega_commons.dart';

import '../../network/urls.dart';

class NotificationProvider {
  final RestClientDio _restClientDio;
  final String? pathNotification;
  final bool? isReadNotification;

  NotificationProvider({
    required RestClientDio restClientDio,
    this.pathNotification,
    this.isReadNotification = true,
  }) : _restClientDio = restClientDio;

  Future<List<MegaNotification>> listNotification({
    required int page,
    required int limit,
  }) async {
    final response = await _restClientDio.get(
      pathNotification ?? Urls.notification,
      queryParameters: {
        'Page': page,
        'Limit': limit,
        'SetRead': isReadNotification ?? true,
      },
    );
    final notifications = (response.data as List)
        .map((e) => MegaNotification.fromJson(e))
        .toList();
    return notifications;
  }

  Future<MegaNotification> getNotificationDetail({
    required String notificationId,
  }) async {
    final response = await _restClientDio.get(
      '${pathNotification ?? Urls.notification}/$notificationId',
    );

    return MegaNotification.fromJson(response.data);
  }

  Future<MegaResponse> removeNotification({required String notificationId}) {
    final response = _restClientDio.delete(
      '${pathNotification ?? Urls.notification}/$notificationId',
    );
    return response;
  }
}
