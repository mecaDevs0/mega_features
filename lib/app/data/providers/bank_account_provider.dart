import 'package:mega_commons/mega_commons.dart';

import '../../../mega_features.dart';

class BankAccountProvider {
  final RestClientDio _megaApi;
  final RestClientDio _restClientDio;

  BankAccountProvider({
    required RestClientDio megaApi,
    required RestClientDio restClientDio,
  })  : _restClientDio = restClientDio,
        _megaApi = megaApi;

  Future<List<Bank>> onSubmitRequest() async {
    final response = await _megaApi.get(Urls.bank);
    // Verificar se response.data já é a resposta parseada ou se precisamos acessar ['data']
    List banksData;
    if (response.data is Map && response.data.containsKey('data')) {
      banksData = response.data['data'] as List;
    } else {
      banksData = response.data as List;
    }
    return banksData.map((bank) => Bank.fromJson(bank)).toList();
  }

  Future<MegaResponse> updateRegisterPatch({
    required String userId,
    required BankAccount bankAccount,
    String? pathBank,
  }) async {
    final response = await _restClientDio.patch(
        pathBank != null ? '$pathBank/$userId' : '${Urls.bank}/$userId',
        data: bankAccount.toJson());
    return response;
  }

  Future<MegaResponse> updateRegisterPost({
    required BankAccount bankAccount,
    String? pathBank,
  }) async {
    final response = await _restClientDio.post(
      pathBank ?? Urls.bank,
      data: bankAccount.toJson(),
    );
    return response;
  }

  Future<BankAccount> getAllBankAccount({
    required String userId,
    String? pathBankGet,
  }) async {
    final response = await _restClientDio.get(
        pathBankGet != null ? '$pathBankGet/$userId' : '${Urls.bank}/$userId');
    return BankAccount.fromJson(response.data);
  }
}
