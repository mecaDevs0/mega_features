import 'package:flutter/material.dart';
import 'package:mega_commons/mega_commons.dart';

import '../../../../../mega_features.dart';
import 'list_view_state.dart';

class DraggableBottomAddressContainer extends StatelessWidget {
  const DraggableBottomAddressContainer({
    Key? key,
    required this.controller,
    this.isShowListState = true,
    required this.onPressed,
    this.backgroundColor,
    this.isFilled = false,
    this.fillColor,
  }) : super(key: key);

  final FormAddressController controller;
  final bool? isShowListState;
  final Function(StateCityShortModel) onPressed;
  final Color? backgroundColor;
  final bool isFilled;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: DraggableScrollableSheet(
        initialChildSize: 1,
        minChildSize: 1,
        expand: false,
        builder: (_, draggableController) {
          return Container(
            color: backgroundColor,
            padding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 20,
            ),
            child: Column(
              children: [
                MegaTextFieldWidget(
                  controller.searchStateCityController,
                  hintText:
                      'Pesquisar ${isShowListState! ? 'Estados' : 'Cidades'}',
                  keyboardType: TextInputType.name,
                  onChanged: (value) {
                    isShowListState!
                        ? controller.searchStateByText(value)
                        : controller.searchCityByText(value);
                  },
                ),
                const Divider(),
                ListViewState(
                  controller: controller,
                  isShowListState: isShowListState!,
                  onPressed: (stateCityShort) {
                    onPressed(stateCityShort);
                  },
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
