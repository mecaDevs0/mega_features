import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mega_commons/mega_commons.dart';
import 'package:mega_commons_dependencies/mega_commons_dependencies.dart';

import '../controllers/form_address_controller.dart';
import 'widgets/draggable_bottom_address_container.dart';

class FormAddressView extends GetView<FormAddressController> {
  const FormAddressView({
    Key? key,
    this.isAddressRequired,
    this.isFilled = false,
    this.fillColor,
    this.isRounded = false,
    this.filleBorderColor,
    this.backgroundColor,
    this.fontColor,
    this.isUpperCase = false,
    this.isWithTitle = false,
    this.onZipCodeChanged,
  }) : super(key: key);

  final bool? isAddressRequired;
  final bool isFilled;
  final Color? fillColor;
  final bool isRounded;
  final Color? filleBorderColor;
  final Color? backgroundColor;
  final Color? fontColor;
  final bool isUpperCase;
  final bool isWithTitle;
  final Function(String?)? onZipCodeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isWithTitle)
                    Text(
                      'Cep',
                      style: TextStyle(
                        color: fontColor,
                        fontWeight: FontWeight.w400,
                        height: 0.5,
                      ),
                    ),
                  MegaTextFieldWidget(
                    controller.zipCodeController,
                    labelText: isWithTitle ? null : 'Cep',
                    hintText: isWithTitle ? 'Digite seu CEP' : null,
                    isRequired: isAddressRequired ?? false,
                    keyboardType: TextInputType.number,
                    fontColor: fontColor,
                    inputFormatters: [
                      if (isUpperCase) UpperCaseTextFormatter(),
                      FilteringTextInputFormatter.digitsOnly,
                      CepInputFormatter(),
                    ],
                    onChanged: (value) {
                      controller.loadAddressByZipCode(isUpperCase: isUpperCase);
                      onZipCodeChanged?.call(value);
                    },
                  ),
                ],
              ),
              if (controller.isLoading)
                Positioned(
                  top: 0,
                  right: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      height: 18,
                      width: 18,
                      margin: const EdgeInsets.only(right: 10),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
        if (isWithTitle)
          TitleTextField(
            fontColor: fontColor,
            title: 'Endereço',
          ),
        MegaTextFieldWidget(
          controller.addressController,
          labelText: isWithTitle ? null : 'Endereço',
          hintText: isWithTitle ? 'Digite seu endereço' : null,
          isRequired: isAddressRequired ?? false,
          keyboardType: TextInputType.streetAddress,
          fontColor: fontColor,
          topPadding: isWithTitle ? 0 : null,
          onChanged: (address) {
            controller.address.streetAddress = address;
            controller.localAddress.refresh();
          },
          inputFormatters: [
            if (isUpperCase) UpperCaseTextFormatter(),
          ],
        ),
        if (isWithTitle)
          TitleTextField(
            fontColor: fontColor,
            title: 'Número',
          ),
        MegaTextFieldWidget(
          controller.numberController,
          labelText: isWithTitle ? null : 'Número',
          hintText: isWithTitle ? 'Digite o número' : null,
          topPadding: isWithTitle ? 0 : null,
          isRequired: isAddressRequired ?? false,
          fontColor: fontColor,
          onChanged: (value) {
            controller.localAddress.value.number = value;
            controller.localAddress.refresh();
          },
          inputFormatters: [
            if (isUpperCase) UpperCaseTextFormatter(),
          ],
        ),
        if (isWithTitle)
          TitleTextField(
            fontColor: fontColor,
            title: 'Complemento',
          ),
        MegaTextFieldWidget(
          controller.complementController,
          labelText: isWithTitle ? null : 'Complemento',
          hintText: isWithTitle ? 'Digite o complemento' : null,
          topPadding: isWithTitle ? 0 : null,
          fontColor: fontColor,
          onChanged: (complement) {
            controller.localAddress.value.complement = complement;
            controller.localAddress.refresh();
          },
          inputFormatters: [
            if (isUpperCase) UpperCaseTextFormatter(),
          ],
        ),
        if (isWithTitle)
          TitleTextField(
            fontColor: fontColor,
            title: 'Bairro',
          ),
        MegaTextFieldWidget(
          controller.neighborhoodController,
          labelText: isWithTitle ? null : 'Bairro',
          hintText: isWithTitle ? 'Digite o bairro' : null,
          topPadding: isWithTitle ? 0 : null,
          isRequired: isAddressRequired ?? false,
          fontColor: fontColor,
          keyboardType: TextInputType.name,
          onChanged: (neighborhood) {
            controller.localAddress.value.neighborhood = neighborhood;
            controller.localAddress.refresh();
          },
          inputFormatters: [
            if (isUpperCase) UpperCaseTextFormatter(),
          ],
        ),
        if (isWithTitle)
          TitleTextField(
            fontColor: fontColor,
            title: 'Estado',
          ),
        MegaTextFieldWidget(
          controller.stateController,
          labelText: isWithTitle ? null : 'Estado',
          hintText: isWithTitle ? 'Selecione o estado' : null,
          topPadding: isWithTitle ? 0 : null,
          isRequired: isAddressRequired ?? false,
          isReadOnly: true,
          fontColor: fontColor,
          suffixIcon: const Icon(
            FontAwesomeIcons.chevronDown,
            size: 12,
          ),
          inputFormatters: [
            if (isUpperCase) UpperCaseTextFormatter(),
          ],
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) {
                return DraggableBottomAddressContainer(
                  controller: controller,
                  backgroundColor: backgroundColor,
                  fillColor: fillColor,
                  isFilled: isFilled,
                  onPressed: (stateCityShort) async {
                    await controller.changeState(stateCityShort);
                  },
                );
              },
            );
          },
        ),
        if (isWithTitle)
          TitleTextField(
            fontColor: fontColor,
            title: 'Cidade',
          ),
        MegaTextFieldWidget(
          controller.cityController,
          labelText: isWithTitle ? null : 'Cidade',
          hintText: isWithTitle ? 'Selecione a cidade' : null,
          topPadding: isWithTitle ? 0 : null,
          isRequired: isAddressRequired ?? false,
          isReadOnly: true,
          fontColor: fontColor,
          suffixIcon: const Icon(
            FontAwesomeIcons.chevronDown,
            size: 12,
          ),
          inputFormatters: [
            if (isUpperCase) UpperCaseTextFormatter(),
          ],
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) {
                return DraggableBottomAddressContainer(
                  controller: controller,
                  backgroundColor: backgroundColor,
                  isShowListState: false,
                  fillColor: fillColor,
                  isFilled: isFilled,
                  onPressed: (stateCityShort) {
                    controller.changeCity(stateCityShort);
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class TitleTextField extends StatelessWidget {
  const TitleTextField({
    super.key,
    required this.fontColor,
    this.title = '',
  });

  final Color? fontColor;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Text(
          title,
          style: TextStyle(
            color: fontColor,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
