import 'package:flutter/material.dart';
import 'package:mega_commons/mega_commons.dart';
import 'package:mega_commons_dependencies/mega_commons_dependencies.dart';

import '../../../../mega_features.dart';

class ListPayCardView extends GetView<PayCardsController> {
  const ListPayCardView({
    Key? key,
    this.canDelete,
    this.canSelect = false,
    this.selectedColor = Colors.green,
  }) : super(key: key);

  final bool? canDelete;
  final bool? canSelect;
  final Color? selectedColor;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return MegaContainerLoading(
        isLoading: controller.isLoadingDelete,
        textLoading: 'Removendo...',
        child: Column(
          children: <Widget>[
            Obx(() {
              if (controller.isLoadingList) {
                return Expanded(
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: 10,
                      itemBuilder: (_, __) => Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        height: 56,
                        color: Colors.grey[300],
                      ),
                    ),
                  ),
                );
              }
              if (controller.creditCards.isEmpty) {
                return const Expanded(
                  child: Center(
                    child: Text('Nenhum cartão cadastrado'),
                  ),
                );
              }
              return Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: controller.creditCards.length,
                  itemBuilder: (context, index) {
                    return Obx(() {
                      return InkWell(
                        onTap: canSelect!
                            ? () => controller.creditCardSelected =
                                controller.creditCards[index]
                            : null,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 20,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 19,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Get.theme.cardColor,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              MegaCachedNetworkImage(
                                imageUrl: controller.creditCards[index].flag,
                                height: 24,
                                width: 34,
                                radius: 4,
                                borderWidth: 1,
                                borderColor: const Color(0xFFD9D9D9),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  '•••• ${controller.creditCards[index].number!.substring(
                                    controller
                                            .creditCards[index].number!.length -
                                        4,
                                  )}',
                                ),
                              ),
                              Visibility(
                                child: Icon(
                                  FontAwesomeIcons.check,
                                  color: selectedColor,
                                  size: 16,
                                ),
                                visible: canSelect! &&
                                    controller.creditCards[index] ==
                                        controller.creditCardSelected,
                              ),
                              Visibility(
                                visible: canDelete ?? true,
                                child: InkWell(
                                  onTap: () => controller.onDeleteCreditCard(
                                    controller.creditCards[index].id!,
                                  ),
                                  child: Image.asset(
                                    'assets/images/ic_remove.png',
                                    package: 'mega_features',
                                    height: 20,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    });
                  },
                ),
              );
            }),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              child: MegaBaseButton(
                'Adicionar Cartão',
                onButtonPress: () => controller.callScreenPayCard(),
                borderRadius: 0,
                buttonColor: Colors.transparent,
                border: Border.all(
                  color: Get.theme.primaryColor,
                ),
                leftIcon: Image.asset(
                  'assets/images/credit_card.png',
                  package: 'mega_features',
                  height: 24,
                ),
                iconAlignment: MegaIconAlignment.left,
                textStyle: Get.textTheme.labelLarge!.copyWith(
                  color: Get.theme.primaryColor,
                  letterSpacing: -0.41,
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      );
    });
  }
}
