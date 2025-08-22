import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mega_commons/mega_commons.dart';
import 'package:mega_commons_dependencies/mega_commons_dependencies.dart';

import '../controllers/pay_cards_controller.dart';

class PayCardView extends GetView<PayCardsController> {
  const PayCardView({
    Key? key,
    this.isFilled = false,
    this.filleBorderColor,
    this.borderRadiusButton,
    this.heightButton,
    this.buttonColor,
    this.cardBgColor,
    this.fillColor,
    this.backgroundColor,
    this.fontColor,
    this.buttonTextStyle,
    this.fontCardColor,
  }) : super(key: key);

  final bool isFilled;
  final Color? filleBorderColor;
  final double? borderRadiusButton;
  final double? heightButton;
  final Color? buttonColor;
  final Color? cardBgColor;
  final Color? fillColor;
  final Color? backgroundColor;
  final Color? fontColor;
  final TextStyle? buttonTextStyle;
  final Color? fontCardColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? Colors.white,
      body: Obx(
        () => SafeArea(
          child: Column(
            children: [
              CreditCardWidget(
                onCreditCardWidgetChange: (CreditCardBrand creditCardBrand) {},
                cardHolderName: controller.cardHolderName,
                cardNumber: controller.cardNumber,
                cvvCode: controller.cvvCode,
                showBackView: controller.isCvvFocused,
                expiryDate: controller.expiryDate,
                height: 175,
                cardBgColor: cardBgColor ?? Get.theme.primaryColor,
                textStyle: TextStyle(
                  color: fontCardColor ?? Get.theme.canvasColor,
                ),
                textStyleCvv: const TextStyle(color: Colors.black),
                width: MediaQuery.of(context).size.width,
                animationDuration: const Duration(milliseconds: 1000),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: controller.formKey,
                          child: Column(
                            children: [
                              MegaTextFieldWidget(
                                controller.numberController,
                                labelText: 'Número',
                                fontColor: fontColor,
                                onEditingComplete: () {
                                  FocusScope.of(context)
                                      .requestFocus(controller.expiryDateNode);
                                },
                                onChanged: (text) {
                                  controller.cardNumber = text!;
                                },
                                textInputAction: TextInputAction.next,
                                autofillHints: const <String>[
                                  AutofillHints.creditCardNumber
                                ],
                                keyboardType: TextInputType.number,
                                validator: (String? value) {
                                  if (value!.isEmpty || value.length < 16) {
                                    return 'Número do cartão inválido';
                                  }
                                  return null;
                                },
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: MegaTextFieldWidget(
                                      controller.expiryDateController,
                                      labelText: 'Data',
                                      fontColor: fontColor,
                                      focusNode: controller.expiryDateNode,
                                      onEditingComplete: () {
                                        controller.cvvFocusNode.requestFocus();
                                      },
                                      keyboardType: TextInputType.number,
                                      textInputAction: TextInputAction.next,
                                      onChanged: (text) {
                                        controller.expiryDate = text!;
                                      },
                                      autofillHints: const <String>[
                                        AutofillHints.creditCardExpirationDate
                                      ],
                                      validator: (String? value) {
                                        if (value!.isEmpty) {
                                          return 'Data inválida';
                                        }
                                        final DateTime now = DateTime.now();
                                        final List<String> date =
                                            value.split(RegExp('/'));
                                        final int month = int.parse(date.first);
                                        final int year =
                                            int.parse('20${date.last}');
                                        final DateTime cardDate =
                                            DateTime(year, month);

                                        if (cardDate.isBefore(now) ||
                                            month > 12 ||
                                            month == 0) {
                                          return 'Data inválida';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 40),
                                  Expanded(
                                    child: MegaTextFieldWidget(
                                      controller.cvvController,
                                      focusNode: controller.cvvFocusNode,
                                      onEditingComplete: () {
                                        FocusScope.of(Get.context!)
                                            .requestFocus(
                                          controller.cardHolderNode,
                                        );
                                      },
                                      labelText: 'CVV',
                                      fontColor: fontColor,
                                      keyboardType: TextInputType.number,
                                      textInputAction: TextInputAction.next,
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(4),
                                      ],
                                      autofillHints: const <String>[
                                        AutofillHints.creditCardSecurityCode
                                      ],
                                      onChanged: (text) {
                                        controller.cvvCode = text!;
                                      },
                                      validator: (String? value) {
                                        if (value!.isEmpty ||
                                            value.length < 3) {
                                          return 'CVV inválido';
                                        }
                                        return null;
                                      },
                                    ),
                                  )
                                ],
                              ),
                              MegaTextFieldWidget(
                                controller.nameController,
                                focusNode: controller.cardHolderNode,
                                labelText: 'Nome',
                                fontColor: fontColor,
                                keyboardType: TextInputType.name,
                                textCapitalization:
                                    TextCapitalization.characters,
                                autofillHints: const <String>[
                                  AutofillHints.creditCardName
                                ],
                                onChanged: (text) {
                                  controller.cardHolderName = text!;
                                },
                                validator: (String? value) {
                                  if (value!.split(' ').length < 2 ||
                                      value.split(' ')[1].trim().isEmpty) {
                                    return 'Informe um nome correto';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Obx(
                        () {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            child: MegaBaseButton(
                              'Cadastrar Cartão',
                              onButtonPress: () async {
                                controller.onSubmit();
                              },
                              isLoading: controller.isLoadingList,
                              borderRadius: borderRadiusButton ?? 0,
                              buttonHeight: heightButton ?? 54,
                              textStyle: buttonTextStyle ??
                                  const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                              buttonColor: buttonColor ??
                                  Get.theme.colorScheme.onSecondary,
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
