import 'package:mega_commons/mega_commons.dart';
import 'package:mega_commons_dependencies/mega_commons_dependencies.dart';

import '../../network/urls.dart';

class AddressProvider {
  final RestClientDio _restClientDio;
  final Dio _dio = Dio(); // Para chamadas externas

  AddressProvider({required RestClientDio restClientDio})
      : _restClientDio = restClientDio;

  /// Busca informações do CEP usando duas estratégias:
  /// 1. Primeiro tenta na API MecaBR (MongoDB)
  /// 2. Se falhar, usa ViaCEP como fallback
  Future<Address> onSubmitRequest(String zipCode) async {
    // Remove caracteres não numéricos
    final cleanZipCode = zipCode.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanZipCode.length != 8) {
      return Address()..zipCode = zipCode;
    }

    // Primeira tentativa: API MecaBR
    try {
      final mecaResponse = await _searchInMecaAPI(cleanZipCode);
      if (mecaResponse.streetAddress != null && mecaResponse.streetAddress!.isNotEmpty) {
        return mecaResponse;
      }
    } catch (e) {
      // Continua para o fallback
    }

    // Segunda tentativa: ViaCEP como fallback
    try {
      return await _searchInViaCEP(cleanZipCode);
    } catch (e) {
      return Address()..zipCode = zipCode;
    }
  }

  /// Busca na API MecaBR (MongoDB)
  Future<Address> _searchInMecaAPI(String zipCode) async {
    print('=== _searchInMecaAPI called with ZIP: $zipCode ===');
    final response = await _restClientDio.get('api/v1/${Urls.getInfoFromZipCode}$zipCode');
    
    Address result;
    try {
      result = Address.fromJson(response.data);
      result.zipCode = zipCode;
      
      // Se a API MecaBR não retornou os nomes, usar ViaCEP para preencher
      if (result.cityName == null || result.stateName == null) {
        print('Nomes não encontrados na API MecaBR, buscando no ViaCEP');
        final viaCepResult = await _searchInViaCEP(zipCode);
        
        // Manter o IBGE da API MecaBR mas usar os nomes do ViaCEP
        result.cityName = viaCepResult.cityName;
        result.stateName = viaCepResult.stateName;
        result.stateUf = viaCepResult.stateUf;
        
        print('Dados do ViaCEP aplicados: cityName=${result.cityName}, stateName=${result.stateName}');
      }
      
      print('MecaAPI response: ${result.toJson()}');
      print('MecaAPI stateId: ${result.stateId}');
      print('MecaAPI cityId: ${result.cityId}');
      print('=== _searchInMecaAPI finished ===');
      return result;
    } catch (e) {
      print('Error parsing MecaAPI response: $e');
      return Address()..zipCode = zipCode;
    }
  }

  /// Busca no ViaCEP como fallback
  Future<Address> _searchInViaCEP(String zipCode) async {
    print('=== _searchInViaCEP called with ZIP: $zipCode ===');
    try {
      final response = await _dio.get('https://viacep.com.br/ws/$zipCode/json/');
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        
        // Verifica se o CEP foi encontrado
        if (data['erro'] == true) {
          return Address()..zipCode = zipCode;
        }

        // Mapeia os dados do ViaCEP para o modelo Address
        final address = Address()
          ..zipCode = zipCode
          ..streetAddress = data['logradouro'] ?? ''
          ..neighborhood = data['bairro'] ?? ''
          ..cityName = data['localidade'] ?? ''
          ..stateUf = data['uf'] ?? ''
          ..stateName = _getStateNameByUf(data['uf'] ?? '');

        // Buscar os IDs corretos de estado e cidade
        try {
          final stateId = await _getStateIdByUf(data['uf'] ?? '');
          address.stateId = stateId;
          
          if (stateId != null && stateId.isNotEmpty) {
            final cityId = await _getCityIdByNameAndState(data['localidade'] ?? '', stateId);
            address.cityId = cityId;
          }
        } catch (e) {
          print('Error getting state/city IDs: $e');
        }

        print('ViaCEP response: ${address.toJson()}');
        print('ViaCEP stateId: ${address.stateId}');
        print('ViaCEP cityId: ${address.cityId}');
        print('=== _searchInViaCEP finished ===');
        return address;
      }
    } catch (e) {
      print('Error in ViaCEP: $e');
    }
    
    return Address()..zipCode = zipCode;
  }

  /// Converte UF para nome do estado
  String _getStateNameByUf(String uf) {
    const stateMap = {
      'AC': 'Acre',
      'AL': 'Alagoas',
      'AP': 'Amapá',
      'AM': 'Amazonas',
      'BA': 'Bahia',
      'CE': 'Ceará',
      'DF': 'Distrito Federal',
      'ES': 'Espírito Santo',
      'GO': 'Goiás',
      'MA': 'Maranhão',
      'MT': 'Mato Grosso',
      'MS': 'Mato Grosso do Sul',
      'MG': 'Minas Gerais',
      'PA': 'Pará',
      'PB': 'Paraíba',
      'PR': 'Paraná',
      'PE': 'Pernambuco',
      'PI': 'Piauí',
      'RJ': 'Rio de Janeiro',
      'RN': 'Rio Grande do Norte',
      'RS': 'Rio Grande do Sul',
      'RO': 'Rondônia',
      'RR': 'Roraima',
      'SC': 'Santa Catarina',
      'SP': 'São Paulo',
      'SE': 'Sergipe',
      'TO': 'Tocantins',
    };
    
    return stateMap[uf.toUpperCase()] ?? uf;
  }

  /// Busca o ID do estado pela UF
  Future<String?> _getStateIdByUf(String uf) async {
    try {
      final states = await loadStates();
      final state = states.firstWhere(
        (s) => s.uf?.toUpperCase() == uf.toUpperCase(),
        orElse: () => StateModel(),
      );
      return state.id;
    } catch (e) {
      print('Error getting state ID for UF $uf: $e');
      return null;
    }
  }

  /// Busca o ID da cidade pelo nome e ID do estado
  Future<String?> _getCityIdByNameAndState(String cityName, String stateId) async {
    try {
      final cities = await loadCities(stateId);
      final city = cities.firstWhere(
        (c) => c.name?.toLowerCase() == cityName.toLowerCase(),
        orElse: () => CityModel(),
      );
      return city.id;
    } catch (e) {
      print('Error getting city ID for $cityName in state $stateId: $e');
      return null;
    }
  }

  Future<List<CityModel>> loadCities(String stateId) async {
    print('=== loadCities called with stateId: $stateId ===');
    final response =
        await _restClientDio.get('api/v1/${Urls.getCitiesByStateId}/$stateId');

    final cities = (response.data as List)
        .map((city) => CityModel.fromJson(city))
        .toList();
    
    print('Loaded ${cities.length} cities for stateId: $stateId');
    if (cities.isNotEmpty) {
      print('First city: ${cities.first.toJson()}');
    }
    
    print('=== loadCities finished ===');
    return cities;
  }

  Future<List<StateModel>> loadStates() async {
    print('=== loadStates called for country: ${Country.brazil().id} ===');
    final response = await _restClientDio.get(
      'api/v1/${Urls.getStateByBrazilCountry}?countryId=${Country.brazil().id}',
    );

    final states = (response.data as List)
        .map((state) => StateModel.fromJson(state))
        .toList();
    
    print('Loaded ${states.length} states');
    if (states.isNotEmpty) {
      print('First state: ${states.first.toJson()}');
    }
    
    print('=== loadStates finished ===');
    return states;
  }
}
