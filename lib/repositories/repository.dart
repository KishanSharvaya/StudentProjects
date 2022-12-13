import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:soleoserp/models/api_request/login/login_request.dart';
import 'package:soleoserp/models/api_request/registraion/registration_request.dart';
import 'package:soleoserp/models/api_response/login/login_response.dart';
import 'package:soleoserp/models/api_response/registraion/registration_response.dart';
import 'package:soleoserp/repositories/error_response_exception.dart';
import 'package:soleoserp/utils/shared_pref_helper.dart';

import 'api_client.dart';

// will be user for user related api calling and data processing
class Repository {
  SharedPrefHelper prefs = SharedPrefHelper.instance;
  final ApiClient apiClient;

  Repository({@required this.apiClient});

  static Repository getInstance() {
    return Repository(apiClient: ApiClient(httpClient: http.Client()));
  }

  ///add your functions of api calls as below

  Future<RegistrationResponse> getRegistrationDetailsApi(
      RegistrationRequest registrationRequest) async {
    try {
      Map<String, dynamic> json = await apiClient.apiCallPost(
          ApiClient.END_POINT_REGISTRATION, registrationRequest.toJson());

      // print("JSONARRAYRESPOVN" + json.toString());
      RegistrationResponse companyDetailsResponse =
          RegistrationResponse.fromJson(json);
      return companyDetailsResponse;
    } on ErrorResponseException catch (e) {
      rethrow;
    }
  }

  Future<LoginResponse> getLoginDetailsApi(LoginRequest loginRequest) async {
    try {
      Map<String, dynamic> json = await apiClient.apiCallPost(
          ApiClient.END_POINT_LOGIN + loginRequest.companyId.toString(),
          loginRequest.toJson());

      // print("JSONARRAYRESPOVN" + json.toString());
      LoginResponse companyDetailsResponse = LoginResponse.fromJson(json);
      return companyDetailsResponse;
    } on ErrorResponseException catch (e) {
      rethrow;
    }
  }
}
