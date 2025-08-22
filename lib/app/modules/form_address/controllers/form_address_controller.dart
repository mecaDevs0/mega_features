import 'package:flutter/material.dart';
import 'package:mega_commons/mega_commons.dart';
import 'package:mega_commons_dependencies/mega_commons_dependencies.dart';

import '../../../data/providers/providers.dart';

class FormAddressController extends GetxController {
  final AddressProvider _addressProvider;

  FormAddressController({
    required AddressProvider addressProvider,
  }) : _addressProvider = addressProvider;

  final formKey = GlobalKey<FormState>();
  final zipCodeController = TextEditingController();
  final addressController = TextEditingController();
  final numberController = TextEditingController();
  final complementController = TextEditingController();
  final neighborhoodController = TextEditingController();
  final searchStateCityController = TextEditingController();
  final stateController = TextEditingController();
  final cityController = TextEditingController();

  final localAddress = Address().obs;
  final _listStates = <StateModel>[].obs;
  final _listCities = <CityModel>[].obs;
  final _isLading = false.obs;
  List<StateModel> states = [];
  List<CityModel> cities = [];

  Address get address {
    print('=== FormAddressController address getter called ===');
    print('localAddress.value: ${localAddress.value.toJson()}');
    return localAddress.value;
  }
  List<StateModel> get listStates => _listStates;
  List<CityModel> get listCities => _listCities;
  bool get isLoading => _isLading.value;

  @override
  Future<void> onInit() async {
    super.onInit();
    print('=== FormAddressController onInit called ===');
    await loadStates();
    print('=== FormAddressController onInit finished ===');
  }

  Future<void> loadStates() async {
    states = await _addressProvider.loadStates();
    _listStates.addAll(states);
  }

  Future<void> loadAddressByZipCode({bool isUpperCase = false}) async {
    print('=== loadAddressByZipCode called with ZIP: ${zipCodeController.text} ===');
    if (zipCodeController.text.length == 10) {
      _isLading.toggle();
      await MegaRequestUtils.load(
        action: () async {
          final response =
              await _addressProvider.onSubmitRequest(zipCodeController.text);
          localAddress.value = response;
          print('Address loaded from ZIP: ${response.toJson()}');
          print('stateId from ZIP: ${response.stateId}');
          print('cityId from ZIP: ${response.cityId}');
          addressController.text = isUpperCase
              ? response.streetAddress!.toUpperCase()
              : response.streetAddress!;
          numberController.text = response.number ?? '';
          complementController.text = response.complement ?? '';
          neighborhoodController.text = isUpperCase
              ? response.neighborhood!.toUpperCase()
              : response.neighborhood!;
          stateController.text = response.stateName ?? '';
          cityController.text = response.cityName ?? '';
          if (response.stateId != null && response.stateId!.isNotEmpty) {
            cities = await _addressProvider.loadCities(response.stateId!);
            print('Loaded ${cities.length} cities for state ${response.stateId}');
          }
          _listStates.addAll(states);
          _listCities.addAll(cities);
        },
        onError: (error) {
          localAddress.value = Address();
          localAddress.value.zipCode = zipCodeController.text;
          addressController.text = '';
          numberController.text = '';
          complementController.text = '';
          neighborhoodController.text = '';
          cities = [];
          states = [];
          _listStates.addAll(states);
          MegaSnackbar.showErroSnackBar(error.message!);
        },
        onFinally: () {
          _isLading.toggle();
        },
      );
    }
  }

  Future<void> changeState(StateCityShortModel state) async {
    print('=== changeState called with: ${state.id}, ${state.name}, ${state.uf} ===');
    localAddress.value.stateId = state.id;
    localAddress.value.stateName = state.name;
    localAddress.value.stateUf = state.uf;
    stateController.text = state.name ?? '';
    _listCities.clear();
    if (state.id != null && state.id!.trim().isNotEmpty) {
      cities = await _addressProvider.loadCities(state.id!);
      print('Loaded ${cities.length} cities for state ${state.id}');
    }
    _listCities.addAll(cities);
    localAddress.refresh();
    print('Address after changeState: ${localAddress.value.toJson()}');
    print('=== changeState finished ===');
  }

  void changeCity(StateCityShortModel city) {
    print('=== changeCity called with: ${city.id}, ${city.name} ===');
    localAddress.value.cityId = city.id;
    localAddress.value.cityName = city.name;
    cityController.text = city.name!;
    localAddress.refresh();
    print('Address after changeCity: ${localAddress.value.toJson()}');
    print('=== changeCity finished ===');
  }

  void searchStateByText(String? stateName) {
    if (stateName!.isEmpty) {
      _listStates.clear();
      _listStates.addAll(states);
    } else {
      _listStates.clear();
      _listStates.addAll(
        states
            .where(
              (state) => state.name!.toLowerCase().contains(
                    stateName.toLowerCase(),
                  ),
            )
            .toList(),
      );
    }
  }

  void searchCityByText(String? cityName) {
    if (cityName!.isEmpty) {
      _listCities.clear();
      _listCities.addAll(cities);
    } else {
      _listCities.clear();
      _listCities.addAll(
        cities
            .where(
              (city) => city.name!.toLowerCase().contains(
                    cityName.toLowerCase(),
                  ),
            )
            .toList(),
      );
    }
  }

  void setAddress(Address address) {
    print('=== setAddress called with: ${address.toJson()} ===');
    localAddress.value = address;
    zipCodeController.text = address.zipCode ?? '';
    addressController.text = address.streetAddress ?? '';
    numberController.text = address.number ?? '';
    complementController.text = address.complement ?? '';
    neighborhoodController.text = address.neighborhood ?? '';
    cityController.text = address.cityName ?? '';
    stateController.text = address.stateName ?? '';
    
    // Se temos stateId, vamos carregar as cidades e definir a cidade correta
    if (address.stateId != null && address.stateId!.isNotEmpty) {
      print('Setting state with ID: ${address.stateId}');
      changeState(StateCityShortModel(
        id: address.stateId,
        name: address.stateName,
        uf: address.stateUf,
      )).then((_) {
        // Após carregar as cidades, vamos procurar e definir a cidade correta
        if (address.cityId != null && address.cityId!.isNotEmpty) {
          print('Setting city with ID: ${address.cityId}');
          final city = cities.firstWhere(
            (c) => c.id == address.cityId,
            orElse: () => CityModel(),
          );
          if (city.id != null) {
            changeCity(StateCityShortModel(
              id: city.id,
              name: city.name,
            ));
          }
        }
      });
    }
    print('=== setAddress finished ===');
  }

  void clear() {
    zipCodeController.text = '';
    addressController.text = '';
    numberController.text = '';
    complementController.text = '';
    neighborhoodController.text = '';
    cityController.text = '';
    stateController.text = '';
    localAddress.value = Address();
  }
}
