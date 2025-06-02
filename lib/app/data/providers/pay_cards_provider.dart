import 'package:mega_commons/mega_commons.dart';

import '../../network/urls.dart';

class PayCardsProvider {
  final RestClientDio _restClientDio;

  PayCardsProvider({required RestClientDio restClientDio})
      : _restClientDio = restClientDio;

  Future<MegaResponse> onSubmitRequest(CreditCard creditCard) async {
    final response = await _restClientDio.post(
      Urls.creditCardRegister,
      data: creditCard.toJson(),
    );
    return response;
  }

  Future<List<CreditCard>> listCreditCard() async {
    final response = await _restClientDio.get(
      Urls.listCreditCard,
    );
    final creditCards = (response.data as List)
        .map((creditCard) => CreditCard.fromJson(creditCard))
        .toList();
    return creditCards;
  }

  Future<MegaResponse> onDeleteRequest(String creditCardId) async {
    final response = await _restClientDio.post(
      '${Urls.listCreditCard}/$creditCardId',
    );
    return response;
  }
}
