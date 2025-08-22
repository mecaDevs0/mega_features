import 'package:flutter/material.dart';
import 'package:mega_commons/mega_commons.dart';
import 'package:mega_commons/shared/models/person_type.dart';
import 'package:mega_commons_dependencies/mega_commons_dependencies.dart';

import '../../../data/providers/bank_account_provider.dart';

class BankAccountController extends GetxController {
  final BankAccountProvider _bankProvider;

  final accountableName = TextEditingController();
  final accountableCpf = TextEditingController();
  final bankAgency = TextEditingController();
  final bankAccountController = TextEditingController();
  final bankController = TextEditingController();
  final typeAccount = TextEditingController();
  final personTypeController = TextEditingController();
  final bankCnpjController = TextEditingController();
  final pixKeyController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  BankAccountController({
    required BankAccountProvider bankProvider,
  }) : _bankProvider = bankProvider;

  final _isLoading = RxBool(false);
  final _listBanks = RxList<Bank>.empty();
  final _labelLoading = RxString('Buscando dados...');
  final _selectedBank = Rx<Bank>(Bank());
  final _bankAccount = Rx<BankAccount>(BankAccount());
  final _isLegalPerson = RxBool(false);

  bool get isLoading => _isLoading.value;
  List<Bank> get listBanks => _listBanks.toList();
  String get labelLoading => _labelLoading.value;
  Bank get selectedBank => _selectedBank.value;
  BankAccount get bankAccount => _bankAccount.value;
  bool get isLegalPerson => _isLegalPerson.value;

  set selectedBank(Bank value) => _selectedBank.value = value;
  set isLegalPerson(bool value) => _isLegalPerson.value = value;

  TypeAccount? selectedTypeAccount;
  PersonType? selectedPersonType;

  // Constantes para o ambiente de sandbox da Stripe
  // Esses valores são usados para preencher os campos de teste
  static const String _sandboxBankCode = '110';
  static const String _sandboxBankName = 'Stripe Testes';
  static const String _sandboxAgency = '0000';
  static const String _sandboxAccount = '0001234';

  @override
  Future<void> onInit() async {
    super.onInit();
    ever(_selectedBank, (_) {
      bankController.text = selectedBank.name ?? '';
    });
  }

  /// Inicializa o módulo de contas bancárias.
  ///
  /// Este método carrega a lista de bancos disponíveis e,
  /// caso o `userId` seja fornecido, também carrega os dados
  /// da conta bancária atual do usuário.
  ///
  /// - [userId]: ID do usuário para buscar a conta bancária atual (opcional).
  /// - [pathBank]: Caminho para o recurso de bancos (opcional).
  /// - [pathBankGet]: Caminho para buscar a conta bancária do usuário (opcional).
  /// - [isSandBox]: Define se o ambiente é de sandbox. Padrão é `false`.
  ///
  /// Exemplo de uso:
  /// ```dart
  /// await controller.initialize(
  ///   userId: '12345',
  ///   pathBank: '/bancos',
  ///   pathBankGet: '/conta-bancaria',
  ///   isSandBox: true,
  /// );
  /// ```
  ///
  Future<void> initialize({
    String? userId,
    String? pathBank,
    String? pathBankGet,
    bool isSandBox = false,
  }) async {
    await _loadBanks();
    if (userId != null) {
      await loadCurrentBankAccount(
        userId: userId,
        pathBankGet: pathBankGet,
        isSandBox: isSandBox,
      );
    }
  }

  void setSandboxMode() {
    selectedBank = Bank(
      code: _sandboxBankCode,
      name: _sandboxBankName,
    );
    bankAgency.text = _sandboxAgency;
    bankAccountController.text = _sandboxAccount;
    accountableName.text = 'Teste Stripe';
    accountableCpf.text = UtilBrasilFields.gerarCPF();
  }

  Future<void> updateRegister({
    required String userId,
    String? pathBank,
    bool isPost = false,
  }) async {
    if (formKey.currentState?.validate() == true) {
      _isLoading.value = true;
      _labelLoading.value = 'Salvando dados...';
      await MegaRequestUtils.load(
        action: () async {
          final bankAccount = BankAccount(
            accountableName: accountableName.text,
            accountableCpf: accountableCpf.text,
            bankAgency: bankAgency.text,
            bankAccount: bankAccountController.text,
            bank: selectedBank.code,
            typeAccount: selectedTypeAccount?.value,
            personType: selectedPersonType?.index ?? 2,
            bankName: bankController.text,
            bankCnpj: bankCnpjController.text.isEmpty
                ? null
                : bankCnpjController.text,
          );
          final result = isPost
              ? await _bankProvider.updateRegisterPost(
                  bankAccount: bankAccount,
                  pathBank: pathBank,
                )
              : await _bankProvider.updateRegisterPatch(
                  userId: userId,
                  bankAccount: bankAccount,
                  pathBank: pathBank,
                );
          Get.back(result: true);
          MegaSnackbar.showSuccessSnackBar(
            result.message ?? 'Dados salvos',
            title: 'Dados Bancários',
          );
        },
        onFinally: () => _isLoading.value = false,
      );
    }
  }

  Future<void> _loadBanks() async {
    _isLoading.value = true;
    _labelLoading.value = 'Buscando bancos...';
    await MegaRequestUtils.load(
      action: () async {
        final response = await _bankProvider.onSubmitRequest();
        _listBanks.assignAll(response);
      },
      onFinally: () => _isLoading.value = false,
    );
  }

  Future<void> loadCurrentBankAccount({
    required String userId,
    String? pathBankGet,
    bool isSandBox = false,
  }) async {
    _isLoading.value = true;
    _labelLoading.value = 'Buscando dados...';
    await MegaRequestUtils.load(
      action: () async {
        final response = await _bankProvider.getAllBankAccount(
          userId: userId,
          pathBankGet: pathBankGet,
        );
        _bankAccount.value = response;
        if (response.id != null) {
          populateBankAccount(isSandBox: isSandBox);
        }
      },
      onFinally: () => _isLoading.value = false,
    );
  }

  String _validCpf(String? cpf) {
    if (cpf == null) {
      return '';
    }
    if (cpf.length == 11) {
      return UtilBrasilFields.obterCpf(cpf);
    }
    return cpf;
  }

  Bank get _validBank {
    if (bankAccount.bank == null) {
      return Bank();
    }
    return listBanks.firstWhere(
      (bank) => bank.code == bankAccount.bank,
      orElse: () => Bank(),
    );
  }

  void populateBankAccount({bool isSandBox = false}) {
    accountableName.text = _bankAccount.value.accountableName ?? '';
    accountableCpf.text = _validCpf(_bankAccount.value.accountableCpf);
    bankAgency.text = _bankAccount.value.bankAgency ?? '';
    bankAccountController.text = _bankAccount.value.bankAccount ?? '';
    typeAccount.text = TypeAccount.values
        .firstWhere((type) => type.value == _bankAccount.value.typeAccount)
        .name;
    selectedBank = _validBank;
    personTypeController.text = PersonType.values
        .firstWhere((type) => type.index == _bankAccount.value.personType)
        .description;
    selectedTypeAccount = TypeAccount.values.firstWhere(
      (type) => type.value == _bankAccount.value.typeAccount,
      orElse: () => TypeAccount.values.first,
    );
    selectedPersonType = PersonType.values.firstWhere(
      (type) => type.index == _bankAccount.value.personType,
      orElse: () => PersonType.values.first,
    );

    /// Preenche os campos com dados de teste para Stripe em sandbox
    if (isSandBox) {
      setSandboxMode();
    }
  }

  String getBankName() {
    try {
      final bank = listBanks.firstWhere(
        (element) => element.code == bankAccount.bank,
        orElse: () => Bank(name: 'Banco não encontrado'),
      );
      return bank.name ?? 'Banco não encontrado';
    } catch (e) {
      return 'Banco não encontrado';
    }
  }

  @override
  void onClose() {
    accountableName.dispose();
    accountableCpf.dispose();
    bankAgency.dispose();
    bankAccountController.dispose();
    bankController.dispose();
    typeAccount.dispose();
    personTypeController.dispose();
    bankCnpjController.dispose();
    pixKeyController.dispose();
    super.onClose();
  }
}
