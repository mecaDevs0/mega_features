import 'package:flutter/material.dart';
import 'package:mega_commons/mega_commons.dart';
import 'package:mega_commons_dependencies/mega_commons_dependencies.dart';

import '../../../../../mega_features.dart';

class ListViewState extends StatelessWidget {
  const ListViewState({
    Key? key,
    required this.controller,
    required this.isShowListState,
    required this.onPressed,
  }) : super(key: key);

  final FormAddressController controller;
  final bool isShowListState;
  final Function(StateCityShortModel) onPressed;

  @override
  Widget build(BuildContext context) {
    bool _checkIsShowListState() {
      if (isShowListState && controller.listStates.isNotEmpty) {
        return true;
      }
      if (!isShowListState && controller.listCities.isNotEmpty) {
        return true;
      }
      return false;
    }

    return Obx(
      () => Expanded(
        child: Visibility(
          visible: _checkIsShowListState(),
          replacement: Center(
            child: Text(
              'Nenhum item encontrado',
              style: Get.textTheme.headlineMedium!.copyWith(fontSize: 20),
            ),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: isShowListState
                ? controller.listStates.length
                : controller.listCities.length,
            itemBuilder: (_, index) {
              return InkWell(
                onTap: () {
                  itemStateCityPressed(index);
                  Get.back();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                  ),
                  child: Text(
                    isShowListState
                        ? controller.listStates[index].name!
                        : controller.listCities[index].name!,
                    style: Get.textTheme.displaySmall!.copyWith(
                      fontSize: 20,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void itemStateCityPressed(int index) {
    onPressed(
      isShowListState
          ? StateCityShortModel(
              id: controller.listStates[index].id,
              name: controller.listStates[index].name,
              uf: controller.listStates[index].uf,
            )
          : StateCityShortModel(
              id: controller.listCities[index].id,
              name: controller.listCities[index].name,
            ),
    );
  }
}
