import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:soleoserp/models/api_response/company_details/company_details_response.dart';
import 'package:soleoserp/models/api_response/login/login_user_details_api_response.dart';

class SharedPrefHelper {
  final SharedPreferences prefs;
  static SharedPrefHelper instance;

  ///key names for preference data storage
  static const String IS_LOGGED_IN_DATA = "is_logged_in";
  static const String AUTH_TOKEN_STRING = "auth_token";
  static const String IS_REGISTERED = "is_registered";

  static const String IS_COMPANY_LOGGED_IN_DATA = "company_logged_in_data";
  static const String IS_LOGGED_IN_USER_DATA = "logged_User_in_data";

  SharedPrefHelper._(this.prefs);

  static Future<void> createInstance() async {
    instance = SharedPrefHelper._(await SharedPreferences.getInstance());
  }

  Future<void> putBool(String key, bool value) async {
    await prefs.setBool(key, value);
  }

  bool getBool(String key, {bool defaultValue = false}) {
    if (prefs.containsKey(key)) {
      return prefs.getBool(key);
    }
    return defaultValue;
  }

  Future<void> putDouble(String key, double value) async {
    await prefs.setDouble(key, value);
  }

  double getDouble(String key, {double defaultValue = 0.0}) {
    if (prefs.containsKey(key)) {
      return prefs.getDouble(key);
    }
    return defaultValue;
  }

  Future<void> putString(String key, String value) async {
    await prefs.setString(key, value);
  }

  String getString(String key, {String defaultValue = ""}) {
    if (prefs.containsKey(key)) {
      return prefs.getString(key);
    }
    return defaultValue;
  }

  Future<void> putInt(String key, int value) async {
    await prefs.setInt(key, value);
  }

  int getInt(String key, {int defaultValue = 0}) {
    if (prefs.containsKey(key)) {
      return prefs.getInt(key);
    }
    return defaultValue;
  }

  Future<bool> clear() async {
    return await prefs.clear();
  }

  bool isLoggedIn() {
    return getBool(IS_LOGGED_IN_DATA) ?? false;
  }

  bool isLogIn() {
    return getBool(IS_LOGGED_IN_DATA) ?? false;
  }

  bool isRegisteredIn() {
    return getBool(IS_REGISTERED) ?? false;
  }

  CompanyDetailsResponse getCompanyData() {
    return CompanyDetailsResponse.fromJson(
        json.decode(getString(IS_COMPANY_LOGGED_IN_DATA)));
  }

  setCompanyData(CompanyDetailsResponse data) async {
    await putString(IS_COMPANY_LOGGED_IN_DATA, json.encode(data));
  }

  setLoginUserData(LoginUserDetialsResponse data) async {
    await putString(IS_LOGGED_IN_USER_DATA, json.encode(data));
  }

  LoginUserDetialsResponse getLoginUserData() {
    return LoginUserDetialsResponse.fromJson(
        json.decode(getString(IS_LOGGED_IN_USER_DATA)));
  }
}
