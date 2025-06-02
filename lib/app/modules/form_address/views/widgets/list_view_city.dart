import 'package:flutter/material.dart';
import 'package:mega_commons_dependencies/mega_commons_dependencies.dart';

import '../../../../../mega_features.dart';

class ListViewCity extends StatelessWidget {
  const ListViewCity({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final FormAddressController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Expanded(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: controller.listCities.length,
          itemBuilder: (_, index) {
            return InkWell(
              onTap: () {
                Get.back();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                ),
                child: Text(
                  controller.listCities[index].name!,
                  style: Get.textTheme.displaySmall!.copyWith(
                    fontSize: 20,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
