import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mega_commons/mega_commons.dart';
import 'package:mega_commons/shared/models/person_type.dart';
import 'package:mega_commons_dependencies/mega_commons_dependencies.dart';

import '../../../../mega_features.dart';
import 'bank_search_dropdown.dart';

class FormBankAccountView extends GetView<BankAccountController> {
  const FormBankAccountView({
    Key? key,
    this.isDataBankRequired,
    this.isFilled = false,
    this.fillColor,
    this.isRounded = false,
    this.filleBorderColor,
    required this.actionButton,
    this.isWithTitle = false,
    this.fontColor,
    this.hasPix = false,
  }) : super(key: key);

  final bool? isDataBankRequired;
  final bool isFilled;
  final Color? fillColor;
  final bool isRounded;
  final Color? filleBorderColor;
  final Widget actionButton;
  final bool isWithTitle;
  final Color? fontColor;
  final bool hasPix;

  String _getAgencyHelpHint(Bank bank) {
    String hint = '9 é o número da agência';
    if (bank.agencyMask!.contains('D')) {
      hint = '$hint | D é o digito verificador';
    }
    return hint;
  }

  String _getAccountHelpHint(Bank bank) {
    String hint = '9 é o número da conta';
    if (bank.accountMask!.contains('X')) {
      hint = '$hint | X é a operação';
    }
    if (bank.accountMask!.contains('D')) {
      hint = '$hint | D é o digito verificador';
    }
    return hint;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isWithTitle)
              TitleWidget(
                title: 'Banco',
                fontColor: fontColor,
              ),
            BankSearchDropdown(
              controller: controller.bankController,
              banks: controller.listBanks,
              label: isWithTitle ? null : 'Banco',
              hintText: isWithTitle ? 'Selecione seu banco' : null,
              isRequired: true,
              onBankSelected: (bank) {
                controller.selectedBank = bank;
                controller.bankAccountController.clear();
                controller.bankAgency.clear();
              },
            ),
            if (isWithTitle)
              TitleWidget(
                title: 'Agência',
                fontColor: fontColor,
              ),
            MegaTextFieldWidget(
              controller.bankAgency,
              labelText: isWithTitle ? null : 'Agência',
              keyboardType: TextInputType.number,
              isRequired: true,
              hintText:
                  controller.selectedBank.agencyMask ?? 'Digite sua agência',
              helperText: controller.selectedBank.id != null
                  ? _getAgencyHelpHint(controller.selectedBank)
                  : null,
              inputFormatters: [
                LengthLimitingTextInputFormatter(
                    controller.selectedBank.agencyMask?.length),
                MegaDataBankInputFormatter(
                  mask: controller.selectedBank.agencyMask ?? '',
                ),
              ],
            ),
            if (isWithTitle)
              TitleWidget(
                title: 'Conta',
                fontColor: fontColor,
              ),
            MegaTextFieldWidget(
              controller.bankAccountController,
              labelText: isWithTitle ? null : 'Conta',
              keyboardType: TextInputType.number,
              isRequired: true,
              hintText:
                  controller.selectedBank.accountMask ?? 'Digite sua conta',
              helperText: controller.selectedBank.id != null
                  ? _getAccountHelpHint(controller.selectedBank)
                  : null,
              inputFormatters: [
                LengthLimitingTextInputFormatter(
                    controller.selectedBank.accountMask?.length),
                MegaDataBankInputFormatter(
                  mask: controller.selectedBank.accountMask ?? '',
                ),
              ],
            ),
            if (isWithTitle)
              TitleWidget(
                title: 'Tipo de Conta',
                fontColor: fontColor,
              ),
            MegaDropDownWidget<TypeAccount>(
              controller: controller.typeAccount,
              label: isWithTitle ? null : 'Tipo de Conta',
              hintText: isWithTitle ? 'Selecione o tipo de conta' : null,
              title: 'Selecione o tipo de Conta',
              isRequired: true,
              listDropDownItem: TypeAccount.values
                  .map(
                    (typeAccount) => MegaItemWidget<TypeAccount>(
                      value: typeAccount,
                      itemLabel: typeAccount.name,
                    ),
                  )
                  .toList(),
              onChanged: (typeAccount) {
                controller.typeAccount.text = typeAccount.name;
                controller.selectedTypeAccount = typeAccount;
              },
            ),
            if (isWithTitle)
              TitleWidget(
                title: 'Nome do Titular',
                fontColor: fontColor,
              ),
            MegaTextFieldWidget(
              controller.accountableName,
              labelText: isWithTitle ? null : 'Nome do Titular',
              hintText: isWithTitle ? 'Digite o nome do titular' : null,
              isRequired: true,
              keyboardType: TextInputType.name,
            ),
            if (isWithTitle)
              TitleWidget(
                title: 'Tipo de Pessoa',
                fontColor: fontColor,
              ),
            MegaDropDownWidget<PersonType>(
              controller: controller.personTypeController,
              label: isWithTitle ? null : 'Tipo de Pessoa',
              listDropDownItem: PersonType.values
                  .map(
                    (personType) => MegaItemWidget<PersonType>(
                      value: personType,
                      itemLabel: personType.description,
                    ),
                  )
                  .toList(),
              onChanged: (typePerson) {
                controller.personTypeController.text = typePerson.description;
                controller.selectedPersonType = typePerson;
                controller.personTypeController.text = typePerson.description;
                controller.isLegalPerson = typePerson == PersonType.legalPerson;
              },
              hintText: 'Tipo de Pessoa',
              title: 'Selecione o tipo de Pessoa',
              isRequired: true,
            ),
            Visibility(
              visible: controller.isLegalPerson,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isWithTitle)
                    TitleWidget(
                      title: 'CNPJ do titular',
                      fontColor: fontColor,
                    ),
                  MegaTextFieldWidget(
                    controller.bankCnpjController,
                    onTap: () {
                      if (kDebugMode) {
                        controller.bankCnpjController.text =
                            UtilBrasilFields.gerarCNPJ();
                      }
                    },
                    isRequired: true,
                    hintText: 'Digite o CNPJ',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      CnpjInputFormatter(),
                    ],
                    validator: Validatorless.multiple(
                      [
                        Validatorless.required('Informe o CNPJ do titular'),
                        Validatorless.cnpj('CNPJ inválido'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isWithTitle)
              TitleWidget(
                title: 'CPF do Titular',
                fontColor: fontColor,
              ),
            MegaTextFieldWidget(
              controller.accountableCpf,
              onTap: () {
                if (kDebugMode) {
                  controller.accountableCpf.text = UtilBrasilFields.gerarCPF();
                }
              },
              labelText: isWithTitle ? null : 'CPF do Titular',
              hintText: isWithTitle ? 'Digite o CPF do titular' : null,
              isRequired: true,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CpfInputFormatter(),
              ],
              validator: Validatorless.multiple([
                Validatorless.required('Campo obrigatório'),
                Validatorless.cpf('CPF inválido'),
              ]),
            ),
            if (isWithTitle && hasPix)
              TitleWidget(
                title: 'Chave Pix',
                fontColor: fontColor,
              ),
            Visibility(
              visible: hasPix,
              child: MegaTextFieldWidget(
                controller.pixKeyController,
                keyboardType: TextInputType.text,
                isRequired: true,
                labelText: isWithTitle ? null : 'Chave Pix',
                hintText: controller.pixKeyController != null &&
                        controller.pixKeyController.text.isNotEmpty
                    ? controller.pixKeyController.text
                    : 'Digite a chave pix',
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            actionButton,
          ],
        ),
      ),
    );
  }
}

class TitleWidget extends StatelessWidget {
  const TitleWidget({
    super.key,
    required this.title,
    this.fontColor,
  });

  final String title;
  final Color? fontColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Text(
        title,
        style: TextStyle(
          color: fontColor,
          fontWeight: FontWeight.w400,
          height: 0.5,
        ),
      ),
    );
  }
}
