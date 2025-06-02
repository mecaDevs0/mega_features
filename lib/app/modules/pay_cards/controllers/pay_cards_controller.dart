import 'package:flutter/material.dart';
import 'package:mega_commons/mega_commons.dart';
import 'package:mega_commons_dependencies/mega_commons_dependencies.dart';

import '../../../../mega_features.dart';

class PayCardsController extends GetxController {
  final PayCardsProvider _payCardsProvider;
  final String? routeAddCreditCard;

  final formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController numberController =
      MaskedTextController(mask: '0000 0000 0000 0000');
  TextEditingController expiryDateController =
      MaskedTextController(mask: '00/00');
  TextEditingController cvvController = MaskedTextController(mask: '0000');

  FocusNode cvvFocusNode = FocusNode();
  FocusNode cardNumberNode = FocusNode();
  FocusNode expiryDateNode = FocusNode();
  FocusNode cardHolderNode = FocusNode();

  final RxBool _isLoadingDelete = false.obs;
  final RxBool _isLoadingList = false.obs;
  final RxBool _isCvvFocused = false.obs;
  final RxString _cardNumber = ''.obs;
  final RxString _expiryDate = ''.obs;
  final RxString _cardHolderName = ''.obs;
  final RxString _cvvCode = ''.obs;
  final RxList<CreditCard> _creditCards = <CreditCard>[].obs;
  final Rx<CreditCard> _creditCardSelected = CreditCard().obs;

  PayCardsController({
    required PayCardsProvider payCardsProvider,
    this.routeAddCreditCard,
  }) : _payCardsProvider = payCardsProvider;

  @override
  void onInit() {
    cvvFocusNode.addListener(textFieldFocusDidChange);
    onListCreditCard();
    super.onInit();
  }

  bool get isLoadingDelete => _isLoadingDelete.value;
  bool get isLoadingList => _isLoadingList.value;
  bool get isCvvFocused => _isCvvFocused.value;
  String get cardNumber => _cardNumber.value;
  String get expiryDate => _expiryDate.value;
  String get cardHolderName => _cardHolderName.value;
  String get cvvCode => _cvvCode.value;
  List<CreditCard> get creditCards => _creditCards.toList();
  CreditCard get creditCardSelected => _creditCardSelected.value;
  set creditCardSelected(CreditCard creditCard) =>
      _creditCardSelected.value = creditCard;

  set cardNumber(String cardNumber) {
    _cardNumber.value = cardNumber;
  }

  set expiryDate(String expiryDate) {
    _expiryDate.value = expiryDate;
  }

  set cardHolderName(String cardHolderName) {
    _cardHolderName.value = cardHolderName;
  }

  set cvvCode(String cvvCode) {
    _cvvCode.value = cvvCode;
  }

  void textFieldFocusDidChange() {
    _isCvvFocused.value = cvvFocusNode.hasFocus;
  }

  Future<void> onSubmit() async {
    if (formKey.currentState!.validate()) {
      _isLoadingList.value = true;
      final CreditCard creditCard = CreditCard(
        name: nameController.text,
        number: numberController.text,
        expMonth: int.parse(expiryDateController.text.split('/')[0]),
        expYear: int.parse('20${expiryDateController.text.split('/')[1]}'),
        cvv: cvvController.text,
      );
      await MegaRequestUtils.load(
        action: () async {
          final response = await _payCardsProvider.onSubmitRequest(creditCard);
          Get.back();
          _clearForm();
          MegaSnackbar.showSuccessSnackBar(response.message ?? 'Success');
          _creditCards.clear();
          await onListCreditCard();
        },
        onError: (error) {
          MegaSnackbar.showErroSnackBar(error.message ?? 'Error');
          _isLoadingList.value = false;
        },
      );
    }
  }

  void _clearForm() {
    nameController.clear();
    numberController.clear();
    expiryDateController.clear();
    cvvController.clear();
    _cardNumber.value = '';
    _expiryDate.value = '';
    _cardHolderName.value = '';
  }

  Future<void> onListCreditCard() async {
    _isLoadingList.value = true;
    await MegaRequestUtils.load(
      action: () async {
        final creditCards = await _payCardsProvider.listCreditCard();
        _creditCards.addAll(creditCards);
      },
      onFinally: () {
        _isLoadingList.value = false;
      },
    );
  }

  Future<void> onDeleteCreditCard(String creditCardId) async {
    _isLoadingDelete.value = true;
    await MegaRequestUtils.load(
      action: () async {
        await _payCardsProvider.onDeleteRequest(creditCardId);
        _creditCards.removeWhere(
          (creditCard) => creditCard.id == creditCardId,
        );
      },
      onFinally: () {
        _isLoadingDelete.value = false;
      },
    );
  }

  void callScreenPayCard() {
    Get.toNamed(RoutesMegaFeature.payCard);
  }

  bool isCreditCardSelected(CreditCard creditCard) {
    return _creditCardSelected.value == creditCard;
  }

  Color getBorderColor(Color selectedColor) {
    if (Get.theme.colorScheme.onSecondary != null) {
      return Get.theme.colorScheme.onSecondary;
    }
    return selectedColor;
  }
}
