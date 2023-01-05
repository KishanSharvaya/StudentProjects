import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:soleoserp/models/api_request/customer/customer_add_edit_api_request.dart';
import 'package:soleoserp/models/api_request/customer/customer_category_request.dart';
import 'package:soleoserp/models/api_request/customer/customer_delete_request.dart';
import 'package:soleoserp/models/api_request/customer/customer_label_value_request.dart';
import 'package:soleoserp/models/api_request/customer/customer_paggination_request.dart';
import 'package:soleoserp/models/api_request/customer/customer_search_by_id_request.dart';
import 'package:soleoserp/models/api_request/customer/customer_source_list_request.dart';
import 'package:soleoserp/models/api_request/inquiry/inqiory_header_save_request.dart';
import 'package:soleoserp/models/api_request/inquiry/inquiry_list_request.dart';
import 'package:soleoserp/models/api_request/inquiry/inquiry_no_to_delete_product.dart';
import 'package:soleoserp/models/api_request/inquiry/inquiry_no_to_product_list_request.dart';
import 'package:soleoserp/models/api_request/inquiry/inquiry_product_search_request.dart';
import 'package:soleoserp/models/api_request/inquiry/inquiry_search_by_pk_id_request.dart';
import 'package:soleoserp/models/api_request/inquiry/inquiry_status_list_request.dart';
import 'package:soleoserp/models/api_request/inquiry/search_inquiry_fillter_request.dart';
import 'package:soleoserp/models/api_request/inquiry/search_inquiry_list_by_name_request.dart';
import 'package:soleoserp/models/api_request/inquiry/search_inquiry_list_by_number_request.dart';
import 'package:soleoserp/models/api_request/login/login_request.dart';
import 'package:soleoserp/models/api_request/other/city_list_request.dart';
import 'package:soleoserp/models/api_request/other/closer_reason_list_request.dart';
import 'package:soleoserp/models/api_request/other/country_list_request.dart';
import 'package:soleoserp/models/api_request/other/follower_employee_list_request.dart';
import 'package:soleoserp/models/api_request/other/state_list_request.dart';
import 'package:soleoserp/models/api_request/registraion/registration_request.dart';
import 'package:soleoserp/models/api_response/company_details/company_details_response.dart';
import 'package:soleoserp/models/api_response/customer/customer_add_edit_response.dart';
import 'package:soleoserp/models/api_response/customer/customer_category_list.dart';
import 'package:soleoserp/models/api_response/customer/customer_delete_response.dart';
import 'package:soleoserp/models/api_response/customer/customer_details_api_response.dart';
import 'package:soleoserp/models/api_response/customer/customer_label_value_response.dart';
import 'package:soleoserp/models/api_response/customer/customer_source_response.dart';
import 'package:soleoserp/models/api_response/inquiry/inquiry_header_save_response.dart';
import 'package:soleoserp/models/api_response/inquiry/inquiry_list_reponse.dart';
import 'package:soleoserp/models/api_response/inquiry/inquiry_no_to_delete_product_response.dart';
import 'package:soleoserp/models/api_response/inquiry/inquiry_no_to_product_response.dart';
import 'package:soleoserp/models/api_response/inquiry/inquiry_product_save_response.dart';
import 'package:soleoserp/models/api_response/inquiry/inquiry_product_search_response.dart';
import 'package:soleoserp/models/api_response/inquiry/inquiry_status_list_response.dart';
import 'package:soleoserp/models/api_response/inquiry/search_inquiry_list_response.dart';
import 'package:soleoserp/models/api_response/login/login_user_details_api_response.dart';
import 'package:soleoserp/models/api_response/other/city_api_response.dart';
import 'package:soleoserp/models/api_response/other/closer_reason_list_response.dart';
import 'package:soleoserp/models/api_response/other/country_list_response.dart';
import 'package:soleoserp/models/api_response/other/country_list_response_for_packing_checking.dart';
import 'package:soleoserp/models/api_response/other/follower_employee_list_response.dart';
import 'package:soleoserp/models/api_response/other/state_list_response.dart';
import 'package:soleoserp/models/common/inquiry_product_model.dart';
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

  Future<CompanyDetailsResponse> getRegistrationDetailsApi(
      RegistrationRequest registrationRequest) async {
    try {
      Map<String, dynamic> json = await apiClient.apiCallPost(
          ApiClient.END_POINT_REGISTRATION, registrationRequest.toJson());

      // print("JSONARRAYRESPOVN" + json.toString());
      CompanyDetailsResponse companyDetailsResponse =
          CompanyDetailsResponse.fromJson(json);
      return companyDetailsResponse;
    } on ErrorResponseException catch (e) {
      rethrow;
    }
  }

  Future<LoginUserDetialsResponse> getLoginDetailsApi(
      LoginRequest loginRequest) async {
    try {
      Map<String, dynamic> json = await apiClient.apiCallPost(
          ApiClient.END_POINT_LOGIN + loginRequest.companyId.toString(),
          loginRequest.toJson());

      // print("JSONARRAYRESPOVN" + json.toString());
      LoginUserDetialsResponse companyDetailsResponse =
          LoginUserDetialsResponse.fromJson(json);
      return companyDetailsResponse;
    } on ErrorResponseException catch (e) {
      rethrow;
    }
  }

  Future<CustomerDetailsResponse> getCustomerList(
      int pageNo, CustomerPaginationRequest customerPaginationRequest) async {
    //todo due to one api bug temporary adding following key
    try {
      Map<String, dynamic> json = await apiClient.apiCallPost(
          "${ApiClient.END_POINT_CUSTOMER_PAGINATION}/$pageNo-10",
          customerPaginationRequest
              .toJson() /*jsontemparray: customerPaginationRequest.lstcontact*/);
      print(
          "ToJSONRESPONSFG : " + customerPaginationRequest.toJson().toString());
      CustomerDetailsResponse response = CustomerDetailsResponse.fromJson(json);

      return response;
    } on ErrorResponseException catch (e) {
      rethrow;
    }
  }

  Future<CustomerDetailsResponse> getCustomerListSearchByNumber(
      CustomerSearchByIdRequest request) async {
    try {
      Map<String, dynamic> json = await apiClient.apiCallPost(
          ApiClient.END_POINT_CUSTOMER_SEARCH_BY_ID + request.CustomerID,
          request.toJson());
      CustomerDetailsResponse response = CustomerDetailsResponse.fromJson(json);

      return response;
    } on ErrorResponseException catch (e) {
      rethrow;
    }
  }

  Future<CustomerLabelvalueRsponse> getCustomerListSearchByName(
      CustomerLabelValueRequest request) async {
    try {
      Map<String, dynamic> json = await apiClient.apiCallPost(
          ApiClient.END_POINT_CUSTOMER_SEARCH, request.toJson());
      CustomerLabelvalueRsponse response =
          CustomerLabelvalueRsponse.fromJson(json);

      return response;
    } on ErrorResponseException catch (e) {
      rethrow;
    }
  }

  Future<CustomerCategoryResponse> customer_Category_List_call(
      CustomerCategoryRequest categoryResponse) async {
    try {
      Map<String, dynamic> json = await apiClient.apiCallPost(
          ApiClient.END_POINT_CUSTOMER_CATEGORY, categoryResponse.toJson());
      CustomerCategoryResponse companyDetailsResponse =
          CustomerCategoryResponse.fromJson(json);
      return companyDetailsResponse;
    } on ErrorResponseException catch (e) {
      rethrow;
    }
  }

  Future<CountryListResponse> country_list_call(
      CountryListRequest countryListRequest) async {
    try {
      /*  String jsonString = await apiClient.apiCallPost(
          ApiClient.END_POINT_COUNTRYLIST, categoryRequest.toJson());
      print("json - $jsonString");
      // var list = json.decode(jsonString);
      return jsonString; //CustomerCategoryResponseFromJson(list);
      //  return LoginApiResponse.fromJson(list[0]);
      */ /* Future<CustomerCategoryResponse> itemsList = (await Future<CustomerCategoryResponse>.from(list.map((i) => LoginApiResponse.fromJson(i)))) as Future<CustomerCategoryResponse>;
      return itemsList;*/

      Map<String, dynamic> json = await apiClient.apiCallPost(
          ApiClient.END_POINT_COUNTRYLIST, countryListRequest.toJson());
      CountryListResponse countryListResponse =
          CountryListResponse.fromJson(json);
      return countryListResponse;
    } on ErrorResponseException catch (e) {
      rethrow;
    }
  }

  Future<StateListResponse> state_list_call(
      StateListRequest stateListRequest) async {
    try {
      Map<String, dynamic> json = await apiClient.apiCallPost(
          ApiClient.END_POINT_STATELIST, stateListRequest.toJson());
      StateListResponse stateListResponse = StateListResponse.fromJson(json);
      return stateListResponse;
    } on ErrorResponseException catch (e) {
      rethrow;
    }
  }

  Future<CityApiRespose> city_list_details(
      CityApiRequest talukaApiRequest) async {
    try {
      Map<String, dynamic> json = await apiClient.apiCallPost(
          ApiClient.END_POINT_CITY_LIST, talukaApiRequest.toJson());
      CityApiRespose cityApiRespose = CityApiRespose.fromJson(json);
      return cityApiRespose;
    } on ErrorResponseException catch (e) {
      rethrow;
    }
  }

  Future<CustomerAddEditApiResponse> customer_add_edit_details(
      CustomerAddEditApiRequest customerAddEditApiRequest) async {
    print("fdhfkjh" + customerAddEditApiRequest.toJson().toString());
    try {
      Map<String, dynamic> json = await apiClient.apiCallPost(
          ApiClient.END_POINT_CUSTOMER_ADD_EDIT +
              customerAddEditApiRequest.customerID +
              "/Save",
          customerAddEditApiRequest.toJson());
      CustomerAddEditApiResponse customerAddEditApiResponse =
          CustomerAddEditApiResponse.fromJson(json);
      return customerAddEditApiResponse;
    } on ErrorResponseException catch (e) {
      rethrow;
    }
  }

  Future<CustomerDeleteResponse> deleteCustomer(
      int id, CustomerDeleteRequest customerDeleteRequest) async {
    try {
      /* await apiClient.apiCallPost(
          "${ApiClient.END_POINT_CUSTOMER_DELETE}/${id}/Delete", customerDeleteRequest.toJson());*/
      Map<String, dynamic> json = await apiClient.apiCallPost(
          "${ApiClient.END_POINT_CUSTOMER_DELETE}/${id}/Delete",
          customerDeleteRequest.toJson(),
          showSuccessDialog: true);
      CustomerDeleteResponse response = CustomerDeleteResponse.fromJson(json);

      return response;
    } on ErrorResponseException catch (e) {
      rethrow;
    }
  }

  Future<CustomerSourceResponse> customer_Source_List_call(
      CustomerSourceRequest sourceRequest) async {
    try {
      Map<String, dynamic> json = await apiClient.apiCallPost(
          ApiClient.END_POINT_CUSTOMER_SOURCE, sourceRequest.toJson());
      CustomerSourceResponse customerSourceResponse =
          CustomerSourceResponse.fromJson(json);
      return customerSourceResponse;
    } on ErrorResponseException catch (e) {
      rethrow;
    }
  }

  Future<InquiryListResponse> getInquiryList(
      int pageNo, InquiryListApiRequest inquiryListApiRequest) async {
    //todo due to one api bug temporary adding following key
    try {
      Map<String, dynamic> json = await apiClient.apiCallPost(
          "${ApiClient.END_POINT_INQUIRY}/$pageNo-10",
          inquiryListApiRequest.toJson());
      InquiryListResponse response = InquiryListResponse.fromJson(json);

      return response;
    } on ErrorResponseException catch (e) {
      rethrow;
    }
  }

  Future<InquiryListResponse> getInquiryListSearchByNumber(
      SearchInquiryListByNumberRequest request) async {
    try {
      Map<String, dynamic> json = await apiClient.apiCallPost(
          ApiClient.END_POINT_INQUIRY_SEARCH_BY_INQUIRY_NO, request.toJson());
      InquiryListResponse response = InquiryListResponse.fromJson(json);

      return response;
    } on ErrorResponseException catch (e) {
      rethrow;
    }
  }

  Future<SearchInquiryListResponse> getInquiryListSearchByName(
      SearchInquiryListByNameRequest request) async {
    try {
      Map<String, dynamic> json = await apiClient.apiCallPost(
          ApiClient.END_POINT_INQUIRY_SEARCH_BY_NAME, request.toJson());
      SearchInquiryListResponse response =
          SearchInquiryListResponse.fromJson(json);

      return response;
    } on ErrorResponseException catch (e) {
      rethrow;
    }
  }

  Future<InquiryProductSearchResponse> getInquiryProductSearchList(
      InquiryProductSearchRequest inquiryProductSearchRequest) async {
    //todo due to one api bug temporary adding following key
    try {
      Map<String, dynamic> json = await apiClient.apiCallPost(
          ApiClient.END_POINT_PRODUCT_SEARCH,
          inquiryProductSearchRequest.toJson());
      InquiryProductSearchResponse response =
          InquiryProductSearchResponse.fromJson(json);

      return response;
    } on ErrorResponseException catch (e) {
      rethrow;
    }
  }

  Future<InquiryHeaderSaveResponse> getInquiryHeaderSave(
      int pkID, InquiryHeaderSaveRequest inquiryHeaderSaveRequest) async {
    //todo due to one api bug temporary adding following key
    try {
      Map<String, dynamic> json = await apiClient.apiCallPost(
          ApiClient.END_POINT_INQUIRY_HEADER_SAVE + pkID.toString() + "/Save",
          inquiryHeaderSaveRequest.toJson());
      InquiryHeaderSaveResponse response =
          InquiryHeaderSaveResponse.fromJson(json);

      return response;
    } on ErrorResponseException catch (e) {
      rethrow;
    }
  }

  Future<InquiryProductSaveResponse> inquiryProductSaveDetails(
      List<InquiryProductModel> inquiryProductModel) async {
    try {
      Map<String, dynamic> json =
          await apiClient.apiCallPostforMultipleJSONArray(
              ApiClient.END_POINT_INQUIRY_PRODUCT_SAVE, inquiryProductModel);
      InquiryProductSaveResponse inquiryProductSaveResponse =
          InquiryProductSaveResponse.fromJson(json);
      return inquiryProductSaveResponse;
    } on ErrorResponseException catch (e) {
      rethrow;
    }
  }

  Future<InquiryNoToProductResponse> getInquiryNoToProductList(
      InquiryNoToProductListRequest inquiryNoToProductListRequest) async {
    //todo due to one api bug temporary adding following key
    try {
      Map<String, dynamic> json = await apiClient.apiCallPost(
          ApiClient.END_POINT_INQUIRY_NO_TO_PRODUCT_LIST,
          inquiryNoToProductListRequest.toJson());
      InquiryNoToProductResponse response =
          InquiryNoToProductResponse.fromJson(json);

      return response;
    } on ErrorResponseException catch (e) {
      rethrow;
    }
  }

  Future<InquiryNoToDeleteProductResponse> getInquiryNoToDeleteProductList(
      String InqNo,
      InquiryNoToDeleteProductRequest inquiryNoToDeleteProductRequest) async {
    //todo due to one api bug temporary adding following key
    try {
      Map<String, dynamic> json = await apiClient.apiCallPost(
          ApiClient.END_POINT_INQUIRY_NO_TO_DELETE_PRODUCT_LIST +
              InqNo +
              "/MultiProductDelete",
          inquiryNoToDeleteProductRequest.toJson());
      InquiryNoToDeleteProductResponse response =
          InquiryNoToDeleteProductResponse.fromJson(json);

      return response;
    } on ErrorResponseException catch (e) {
      rethrow;
    }
  }

  Future<InquiryListResponse> getInquiryByPkID(String pkID,
      InquirySearchByPkIdRequest inquirySearchByPkIdRequest) async {
    //todo due to one api bug temporary adding following key
    try {
      Map<String, dynamic> json = await apiClient.apiCallPost(
          ApiClient.END_POINT_INQUIRY_SEARCH_BY_PKID + pkID,
          inquirySearchByPkIdRequest.toJson());
      InquiryListResponse response = InquiryListResponse.fromJson(json);

      return response;
    } on ErrorResponseException catch (e) {
      rethrow;
    }
  }

  Future<InquiryStatusListResponse> getFollowupInquiryStatusList(
      FollowupInquiryStatusTypeListRequest request) async {
    try {
      Map<String, dynamic> json = await apiClient.apiCallPost(
          ApiClient.END_POINT_FOLLOWUP_TYPE_LIST, request.toJson());
      InquiryStatusListResponse response =
          InquiryStatusListResponse.fromJson(json);

      return response;
    } on ErrorResponseException catch (e) {
      rethrow;
    }
  }

  Future<FollowerEmployeeListResponse> getFollowerEmployeeList(
      FollowerEmployeeListRequest followerEmployeeListRequest) async {
    //todo due to one api bug temporary adding following key
    try {
      Map<String, dynamic> json = await apiClient.apiCallPost(
          ApiClient.END_POINT_FOLLOWER_EMPLOYEE_LIST,
          followerEmployeeListRequest.toJson());
      FollowerEmployeeListResponse response =
          FollowerEmployeeListResponse.fromJson(json);

      return response;
    } on ErrorResponseException catch (e) {
      rethrow;
    }
  }

  Future<CloserReasonListResponse> getCloserReasonStatusList(
      CloserReasonTypeListRequest request) async {
    try {
      Map<String, dynamic> json = await apiClient.apiCallPost(
          ApiClient.END_POINT_FOLLOWUP_TYPE_LIST, request.toJson());
      CloserReasonListResponse response =
          CloserReasonListResponse.fromJson(json);

      return response;
    } on ErrorResponseException catch (e) {
      rethrow;
    }
  }

  Future<CountryListResponseForPacking> country_list_call_For_Packing(
      CountryListRequest countryListRequest) async {
    try {
      Map<String, dynamic> json = await apiClient.apiCallPost(
          ApiClient.END_POINT_COUNTRYLIST, countryListRequest.toJson());
      CountryListResponseForPacking countryListResponse =
          CountryListResponseForPacking.fromJson(json);
      return countryListResponse;
    } on ErrorResponseException catch (e) {
      rethrow;
    }
  }

  Future<InquiryListResponse> getInquiryListSearchByNameFillter(
      SearchInquiryListFillterByNameRequest request) async {
    try {
      Map<String, dynamic> json = await apiClient.apiCallPost(
          ApiClient.END_POINT_INQUIRY_SEARCH_BY_FILLTER, request.toJson());
      InquiryListResponse response = InquiryListResponse.fromJson(json);

      return response;
    } on ErrorResponseException catch (e) {
      rethrow;
    }
  }
}
