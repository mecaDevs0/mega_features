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
    print('🔍 [BANK_DEBUG] Response type: ${response.data.runtimeType}');
    print('🔍 [BANK_DEBUG] Response data: ${response.data}');
    
    // Verificar se response.data já é a resposta parseada ou se precisamos acessar ['data']
    List banksData;
    if (response.data is Map && response.data.containsKey('data')) {
      print('🔍 [BANK_DEBUG] Using response.data[\'data\']');
      banksData = response.data['data'] as List;
    } else {
      print('🔍 [BANK_DEBUG] Using response.data directly');
      banksData = response.data as List;
    }
    
    print('🔍 [BANK_DEBUG] Banks data length: ${banksData.length}');
    if (banksData.isNotEmpty) {
      print('🔍 [BANK_DEBUG] First bank: ${banksData.first}');
    }
    
    final banks = banksData.map((bank) => Bank.fromJson(bank)).toList();
    print('🔍 [BANK_DEBUG] Parsed banks length: ${banks.length}');
    if (banks.isNotEmpty) {
      print('🔍 [BANK_DEBUG] First parsed bank: ${banks.first.name} - ${banks.first.code}');
    }
    
    return banks;
  }

  Future<MegaResponse> updateRegisterPatch({
    required String userId,
    required BankAccount bankAccount,
    String? pathBank,
  }) async {
    final endpoint = pathBank ?? 'api/v1/Workshop/UpdateDataBank/$userId';
    print('🔍 [PROVIDER_DEBUG] Update endpoint: $endpoint');
    print('🔍 [PROVIDER_DEBUG] User ID: $userId');
    print('🔍 [PROVIDER_DEBUG] Bank account data: ${bankAccount.toJson()}');
    
    final response = await _restClientDio.patch(endpoint, data: bankAccount.toJson());
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
