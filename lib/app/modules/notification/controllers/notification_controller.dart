import 'package:flutter/material.dart' show TextButton, Text, Colors;
import 'package:mega_commons/mega_commons.dart';
import 'package:mega_commons_dependencies/mega_commons_dependencies.dart';

import '../../../data/providers/providers.dart';

class NotificationController extends GetxController {
  final String? screenNotificationDetail;
  final NotificationProvider _notificationProvider =
      Get.find<NotificationProvider>();
  final PagingController<int, MegaNotification> pagingController =
      PagingController(firstPageKey: 1);
  final RxList<MegaNotification> _notifications = <MegaNotification>[].obs;
  final RxBool _isLoading = RxBool(false);
  final RxBool _isLoadingDelete = RxBool(false);
  final Rx<PaginationFilter> _paginationFilter = PaginationFilter().obs;
  final Rx<MegaNotification> _notificationDetail = MegaNotification().obs;

  NotificationController({this.screenNotificationDetail});

  List<MegaNotification> get notifications => _notifications.toList();
  bool get isLoading => _isLoading.value;
  bool get isLoadingDelete => _isLoadingDelete.value;
  int get _limit => _paginationFilter.value.limit ?? 30;
  MegaNotification get notificationDetail => _notificationDetail.value;

  @override
  void onInit() {
    pagingController.addPageRequestListener((pageKey) {
      _requestNotifications(pageKey);
    });
    super.onInit();
  }

  Future<void> _requestNotifications(int pageKey) async {
    await MegaRequestUtils.load(
      action: () async {
        final response = await _notificationProvider.listNotification(
          page: pageKey,
          limit: _limit,
        );
        final isLastPage = response.length < _limit;
        if (isLastPage) {
          pagingController.appendLastPage(response);
        } else {
          final nextPageKey = pageKey + 1;
          pagingController.appendPage(response, nextPageKey);
        }
      },
      onError: (megaResponse) => pagingController.error = megaResponse.errors,
    );
  }

  Future<void> removeNotification(String? id) async {
    if (id == null) {
      MegaSnackbar.showErroSnackBar('Id da notificação invalido');
      return;
    }
    _isLoadingDelete.value = true;
    await MegaRequestUtils.load(
      action: () async {
        final response = await _notificationProvider.removeNotification(
          notificationId: id,
        );
        MegaSnackbar.showSuccessSnackBar(response.message ?? 'Success Message');
        pagingController.itemList!
            .removeWhere((notification) => notification.id == id);
      },
      onFinally: () {
        _isLoadingDelete.value = false;
      },
    );
  }

  Future<void> callScreen(String notificationId) async {
    if (screenNotificationDetail == null) {
      return;
    }
    _isLoading.value = true;
    await MegaRequestUtils.load(
      action: () async {
        final response = await _notificationProvider.getNotificationDetail(
          notificationId: notificationId,
        );
        _notificationDetail.value = response;
        Get.toNamed(screenNotificationDetail!);
      },
      onFinally: () => _isLoading.value = false,
    );
  }

  void callRemoveNotification(String idNotification) {
    Get.defaultDialog(
      title: 'Remover Notificação',
      middleText: 'Deseja remover esta notificação?',
      backgroundColor: Colors.white,
      actions: [
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () => Get.back(),
        ),
        TextButton(
          child: const Text('Confirmar'),
          onPressed: () {
            removeNotification(idNotification);
            Get.back();
          },
        ),
      ],
    );
  }
}
