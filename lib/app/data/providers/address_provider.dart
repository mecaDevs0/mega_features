import 'package:mega_commons/mega_commons.dart';

import '../../network/urls.dart';

class AddressProvider {
  final RestClientDio _restClientDio;

  AddressProvider({required RestClientDio restClientDio})
      : _restClientDio = restClientDio;

  Future<Address> onSubmitRequest(String zipCode) async {
    final response =
        await _restClientDio.get('${Urls.getInfoFromZipCode}$zipCode');

    Address result;
    try {
      result = Address.fromJson(response.data);
    } catch (e) {
      result = Address();
    }

    return result;
  }

  Future<List<CityModel>> loadCities(String stateId) async {
    final response =
        await _restClientDio.get('${Urls.getCitiesByStateId}/$stateId');

    return (response.data as List)
        .map((city) => CityModel.fromJson(city))
        .toList();
  }

  Future<List<StateModel>> loadStates() async {
    final response = await _restClientDio.get(
      '${Urls.getStateByBrazilCountry}?countryId=${Country.brazil().id}',
    );

    return (response.data as List)
        .map((state) => StateModel.fromJson(state))
        .toList();
  }
}
