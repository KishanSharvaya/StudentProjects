import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soleoserp/blocs/other/customer/customer_bloc.dart';
import 'package:soleoserp/models/api_request/customer/customer_delete_request.dart';
import 'package:soleoserp/models/api_request/customer/customer_paggination_request.dart';
import 'package:soleoserp/models/api_request/customer/customer_search_by_id_request.dart';
import 'package:soleoserp/models/api_response/company_details/company_details_response.dart';
import 'package:soleoserp/models/api_response/customer/customer_details_api_response.dart';
import 'package:soleoserp/models/api_response/customer/customer_label_value_response.dart';
import 'package:soleoserp/models/api_response/login/login_user_details_api_response.dart';
import 'package:soleoserp/ui/res/color_resources.dart';
import 'package:soleoserp/ui/screens/DashBoard/Customer/CustomerAdd_Edit/customer_add_edit.dart';
import 'package:soleoserp/ui/screens/DashBoard/Customer/search_customer_screen.dart';
import 'package:soleoserp/ui/screens/DashBoard/home_screen.dart';
import 'package:soleoserp/ui/screens/base/base_screen.dart';
import 'package:soleoserp/utils/general_utils.dart';
import 'package:soleoserp/utils/shared_pref_helper.dart';

class CustomerListScreen extends BaseStatefulWidget {
  static const routeName = '/CustomerListScreen';

  @override
  _CustomerListScreenState createState() => _CustomerListScreenState();
}

enum Share {
  facebook,
  twitter,
  whatsapp,
  whatsapp_personal,
  whatsapp_business,
  share_system,
  share_instagram,
  share_telegram
}

class _CustomerListScreenState extends BaseState<CustomerListScreen>
    with BasicScreen, WidgetsBindingObserver {
  CustomerBloc _CustomerBloc;
  int _pageNo = 0;
  CustomerDetailsResponse _inquiryListResponse;
  bool expanded = true;

  double sizeboxsize = 12;
  double _fontSize_Label = 9;
  double _fontSize_Title = 11;
  int label_color = 0xff4F4F4F; //0x66666666;
  int title_color = 0xff362d8b;
  SearchDetails _searchDetails;
  String foos = 'One';
  int selected = 0; //attention
  bool isExpand = false;

  CompanyDetailsResponse _offlineCompanyData;
  LoginUserDetialsResponse _offlineLoggedInData;
  int CompanyID = 0;
  String LoginUserID = "";

  bool isDeleteVisible = true;

  @override
  void initState() {
    super.initState();

    screenStatusBarColor = colorDarkYellow;
    _offlineLoggedInData = SharedPrefHelper.instance.getLoginUserData();
    _offlineCompanyData = SharedPrefHelper.instance.getCompanyData();

    CompanyID = _offlineCompanyData.details[0].pkId;
    LoginUserID = _offlineLoggedInData.details[0].userID;

    _CustomerBloc = CustomerBloc(baseBloc);

    isExpand = false;
    _CustomerBloc
      ..add(CustomerListCallEvent(
          1,
          CustomerPaginationRequest(
            companyId: CompanyID,
            loginUserID: LoginUserID,
            CustomerID: "",
            ListMode: "L",
          )));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => _CustomerBloc
        ..add(CustomerListCallEvent(
            _pageNo + 1,
            CustomerPaginationRequest(
              companyId: CompanyID,
              loginUserID: LoginUserID,
              CustomerID: "",
              ListMode: "L",
            ))),
      child: BlocConsumer<CustomerBloc, CustomerStates>(
        builder: (BuildContext context, CustomerStates state) {
          if (state is CustomerListCallResponseState) {
            _onInquiryListCallSuccess(state);
          }
          if (state is SearchCustomerListByNumberCallResponseState) {
            _onInquiryListByNumberCallSuccess(state);
          }

          return super.build(context);
        },
        buildWhen: (oldState, currentState) {
          if (currentState is CustomerListCallResponseState ||
              currentState is SearchCustomerListByNumberCallResponseState) {
            return true;
          }
          return false;
        },
        listener: (BuildContext context, CustomerStates state) {
          if (state is CustomerDeleteCallResponseState) {
            _onCustomerDeleteCallSucess(state, context);
          }

          return super.build(context);
        },
        listenWhen: (oldState, currentState) {
          if (currentState is CustomerDeleteCallResponseState) {
            return true;
          }
          return false;
        },
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: colorWhite,
        appBar: AppBar(
          title: Text('Customer List Updated MErge '),
          actions: <Widget>[
            GestureDetector(
                onTap: () {
                  _onTapOfSearchView();
                },
                child: Icon(
                  Icons.search,
                  size: 30,
                )),
            SizedBox(
              width: 10,
            ),
            IconButton(
                icon: Icon(
                  Icons.water_damage_sharp,
                  color: colorWhite,
                  size: 30,
                ),
                onPressed: () {
                  //_onTapOfLogOut();
                  navigateTo(context, HomeScreen.routeName,
                      clearAllStack: true);
                }),
          ],
        ),
        body: Container(
          child: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    _CustomerBloc.add(CustomerListCallEvent(
                        1,
                        CustomerPaginationRequest(
                            companyId: CompanyID,
                            loginUserID: LoginUserID,
                            CustomerID: "",
                            ListMode: "L")));
                  },
                  child: Container(
                    padding: EdgeInsets.only(
                      left: 5,
                      right: 5,
                      top: 10,
                    ),
                    child: Column(
                      children: [
                        // _buildSearchView(),
                        Expanded(child: _buildInquiryList())
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () async {
                navigateTo(context, Customer_ADD_EDIT.routeName);
              },
              child: Icon(Icons.add),
              backgroundColor: colorPrimary,
            )
          ],
        ),
        /*drawer: build_Drawer(
            context: context, UserName: "KISHAN", RolCode: "Admin"),*/
      ),
    );
  }

  ///builds header and title view
  Widget _buildSearchView() {
    return InkWell(
      onTap: () {
        _onTapOfSearchView();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 5,
            color: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: Container(
              height: 60,
              width: MediaQuery.of(context).size.width - 70,
              margin: EdgeInsets.only(left: 20, right: 20),
              padding: EdgeInsets.only(right: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _searchDetails == null
                        ? "Tap to search customer"
                        : _searchDetails.label,
                    style: baseTheme.textTheme.headline3.copyWith(
                        color: _searchDetails == null
                            ? colorGrayDark
                            : colorBlack),
                  ),
                  Spacer(),
                  Spacer(),
                  Icon(
                    Icons.search,
                    color: colorGrayDark,
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  ///builds inquiry list
  Widget _buildInquiryList() {
    if (_inquiryListResponse == null) {
      return Container();
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (shouldPaginate(
              scrollInfo,
            ) &&
            _searchDetails == null) {
          _onInquiryListPagination();
          return true;
        } else {
          return false;
        }
      },
      child: ListView.builder(
        key: Key('selected $selected'),
        itemBuilder: (context, index) {
          return _buildInquiryListItem(index);
        },
        shrinkWrap: true,
        itemCount: _inquiryListResponse.details.length,
      ),
    );
  }

  ///builds row item view of inquiry list
  Widget _buildInquiryListItem(int index) {
    return ExpantionCustomer(context, index);
  }

  ///updates data of inquiry list
  void _onInquiryListCallSuccess(CustomerListCallResponseState state) {
    if (_pageNo != state.newPage || state.newPage == 1) {
      //checking if new data is arrived
      if (state.newPage == 1) {
        //resetting search
        _searchDetails = null;
        _inquiryListResponse = state.response;
      } else {
        _inquiryListResponse.details.addAll(state.response.details);
      }
      _pageNo = state.newPage;
    }
  }

  ///checks if already all records are arrive or not
  ///calls api with new page
  void _onInquiryListPagination() {
    _CustomerBloc.add(CustomerListCallEvent(
        _pageNo + 1,
        CustomerPaginationRequest(
          companyId: CompanyID,
          loginUserID: LoginUserID,
          CustomerID: "",
          ListMode: "L",
        )));
  }

  ExpantionCustomer(BuildContext context, int index) {
    CustomerDetails model = _inquiryListResponse.details[index];

    return Container(
        padding: EdgeInsets.all(15),
        child: ExpansionTileCard(
          // key:Key(index.toString()),
          initialElevation: 5.0,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          elevation: 1,
          elevationCurve: Curves.easeInOut,
          shadowColor: Color(0xFF504F4F),
          baseColor: Color(0xFFFCFCFC),
          expandedColor: colorTileBG,

          title: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(top: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.assignment_ind,
                      color: Color(0xff108dcf),
                      size: 24,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 5,
              ),
              Container(
                margin: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.keyboard_arrow_right,
                  color: Color(0xff108dcf),
                  size: 24,
                ),
              ),
              SizedBox(
                width: 3,
              ),
              Flexible(
                child: Text(
                  model.customerName,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.black,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),

          subtitle: Card(
            elevation: 5,
            color: colorBackGroundGray,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Container(
              padding: EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 2),
              child: Row(
                children: [
                  Icon(
                    Icons.mobile_friendly,
                    color: Color(0xff108dcf),
                    size: 24,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    model.contactNo1,
                    style: TextStyle(
                      color: Color(0xFF504F4F),
                      fontSize: _fontSize_Title,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                ],
              ),
            ),
          ),
          children: <Widget>[
            Divider(
              thickness: 1.0,
              height: 1.0,
            ),
            Container(
                margin: EdgeInsets.all(20),
                child: Container(
                    child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Card(
                            color: colorBackGroundGray,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: Container(
                              padding: EdgeInsets.only(
                                  left: 10, right: 10, top: 5, bottom: 5),
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Flexible(
                                      child: Row(
                                        children: [
                                          Column(
                                            children: [
                                              Icon(
                                                Icons.source,
                                                color: colorCardBG,
                                              ),
                                              Text("Category",
                                                  style: TextStyle(
                                                    fontStyle: FontStyle.italic,
                                                    color: colorCardBG,
                                                    fontSize: 7,
                                                  ))
                                            ],
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Flexible(
                                            child: Text(
                                                model.customerType == ""
                                                    ? "N/A"
                                                    : model
                                                        .customerType, //put your own long text here.
                                                maxLines: 3,
                                                overflow: TextOverflow.clip,
                                                style: TextStyle(
                                                    color: Color(title_color),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: _fontSize_Title)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Flexible(
                                      child: Row(
                                        children: [
                                          Column(
                                            children: [
                                              Icon(
                                                Icons.category,
                                                color: colorCardBG,
                                              ),
                                              Text("Source",
                                                  style: TextStyle(
                                                    fontStyle: FontStyle.italic,
                                                    color: colorCardBG,
                                                    fontSize: 7,
                                                  ))
                                            ],
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Flexible(
                                            child: Text(
                                                model.customerSourceName ==
                                                        "--Not Available--"
                                                    ? "N/A"
                                                    : model
                                                        .customerSourceName, //put your own long text here.
                                                maxLines: 3,
                                                overflow: TextOverflow.clip,
                                                style: TextStyle(
                                                    color: Color(title_color),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: _fontSize_Title)),
                                          ),
                                        ],
                                      ),
                                    )
                                  ]),
                            ),
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Card(
                                  color: colorBackGroundGray,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        left: 10, right: 10, top: 5, bottom: 5),
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.mobile_friendly,
                                          color: colorCardBG,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                            model.contactNo1 == ""
                                                ? "N/A"
                                                : model.contactNo1,
                                            style: TextStyle(
                                                color: Color(title_color),
                                                fontWeight: FontWeight.bold,
                                                fontSize: _fontSize_Title,
                                                letterSpacing: .3))
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 3,
                                ),
                                Card(
                                  color: colorBackGroundGray,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        left: 10, right: 10, top: 5, bottom: 5),
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.email,
                                          color: colorCardBG,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                            model.emailAddress == ""
                                                ? "N/A"
                                                : model.emailAddress,
                                            style: TextStyle(
                                                color: Color(title_color),
                                                fontWeight: FontWeight.bold,
                                                fontSize: _fontSize_Title,
                                                letterSpacing: .3)),
                                      ],
                                    ),
                                  ),
                                ),
                              ]),
                          SizedBox(
                            height: 3,
                          ),
                          Card(
                            color: colorBackGroundGray,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: Container(
                              padding: EdgeInsets.only(
                                  left: 10, right: 10, top: 5, bottom: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Column(
                                    children: [
                                      Icon(
                                        Icons.home_work,
                                        color: colorCardBG,
                                      ),
                                      Text("Address",
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            color: colorCardBG,
                                            fontSize: 7,
                                          ))
                                    ],
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Flexible(
                                    child: Text(
                                        model.address == ""
                                            ? "N/A"
                                            : model.address +
                                                "," +
                                                model
                                                    .area, //put your own long text here.
                                        maxLines: 3,
                                        overflow: TextOverflow.clip,
                                        style: TextStyle(
                                            color: Color(title_color),
                                            fontWeight: FontWeight.bold,
                                            fontSize: _fontSize_Title)),
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Card(
                            color: colorBackGroundGray,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: Container(
                              padding: EdgeInsets.only(
                                  left: 10, right: 10, top: 5, bottom: 5),
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Flexible(
                                      child: Row(
                                        children: [
                                          Column(
                                            children: [
                                              Icon(
                                                Icons.home_work,
                                                color: colorCardBG,
                                              ),
                                              Text("City",
                                                  style: TextStyle(
                                                    fontStyle: FontStyle.italic,
                                                    color: colorCardBG,
                                                    fontSize: 7,
                                                  ))
                                            ],
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Flexible(
                                            child: Text(
                                                model.cityName == ""
                                                    ? "N/A"
                                                    : model
                                                        .cityName, //put your own long text here.
                                                maxLines: 3,
                                                overflow: TextOverflow.clip,
                                                style: TextStyle(
                                                    color: Color(title_color),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: _fontSize_Title)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Flexible(
                                      child: Row(
                                        children: [
                                          Column(
                                            children: [
                                              Icon(
                                                Icons.pin_drop,
                                                color: colorCardBG,
                                              ),
                                              Text("PinCode",
                                                  style: TextStyle(
                                                    fontStyle: FontStyle.italic,
                                                    color: colorCardBG,
                                                    fontSize: 7,
                                                  ))
                                            ],
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Flexible(
                                            child: Text(
                                                model.pinCode == ""
                                                    ? "N/A"
                                                    : model
                                                        .pinCode, //put your own long text here.
                                                maxLines: 3,
                                                overflow: TextOverflow.clip,
                                                style: TextStyle(
                                                    color: Color(title_color),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: _fontSize_Title)),
                                          ),
                                        ],
                                      ),
                                    )
                                  ]),
                            ),
                          ),
                          Card(
                            color: colorBackGroundGray,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: Container(
                              padding: EdgeInsets.only(
                                  left: 10, right: 10, top: 5, bottom: 5),
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Flexible(
                                      child: Row(
                                        children: [
                                          Column(
                                            children: [
                                              Icon(
                                                Icons.account_balance,
                                                color: colorCardBG,
                                              ),
                                              Text("State",
                                                  style: TextStyle(
                                                    fontStyle: FontStyle.italic,
                                                    color: colorCardBG,
                                                    fontSize: 7,
                                                  ))
                                            ],
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Flexible(
                                            child: Text(
                                                model.stateName == ""
                                                    ? "N/A"
                                                    : model
                                                        .stateName, //put your own long text here.
                                                maxLines: 3,
                                                overflow: TextOverflow.clip,
                                                style: TextStyle(
                                                    color: Color(title_color),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: _fontSize_Title)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Flexible(
                                      child: Row(
                                        children: [
                                          Column(
                                            children: [
                                              Icon(
                                                Icons.home_work,
                                                color: colorCardBG,
                                              ),
                                              Text("Country",
                                                  style: TextStyle(
                                                    fontStyle: FontStyle.italic,
                                                    color: colorCardBG,
                                                    fontSize: 7,
                                                  ))
                                            ],
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Flexible(
                                            child: Text(
                                                model.countryName == ""
                                                    ? "N/A"
                                                    : model
                                                        .countryName, //put your own long text here.
                                                maxLines: 3,
                                                overflow: TextOverflow.clip,
                                                style: TextStyle(
                                                    color: Color(title_color),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: _fontSize_Title)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ))),
            Divider(
              thickness: 1.0,
              height: 1.0,
            ),
            SizedBox(
              height: 10,
            ),
            Card(
              color: colorCardBG,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Container(
                width: 300,
                height: 50,
                child: ButtonBar(
                    alignment: MainAxisAlignment.spaceBetween,
                    buttonHeight: 52.0,
                    buttonMinWidth: 90.0,
                    children: <Widget>[
                      SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          _onTapOfEditCustomer(model);
                        },
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.edit),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2.0),
                            ),
                            Text(
                              'Update',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: colorWhite),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      isDeleteVisible == true
                          ? GestureDetector(
                              onTap: () {
                                _onTapOfDeleteInquiry(model.customerID);
                              },
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.delete),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 2.0),
                                  ),
                                  Text(
                                    'Delete',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: colorWhite),
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                      SizedBox(
                        width: 10,
                      ),
                    ]),
              ),
            ),
            SizedBox(
              height: 10,
            )
          ],
        ));
  }

  Future<bool> _onBackPressed() {
    navigateTo(context, HomeScreen.routeName, clearAllStack: true);
  }

  ///navigates to search list screen
  Future<void> _onTapOfSearchView() async {
    navigateTo(context, SearchCustomerScreen.routeName).then((value) {
      if (value != null) {
        _searchDetails = value;
        _CustomerBloc.add(SearchCustomerListByNumberCallEvent(
            CustomerSearchByIdRequest(
                companyId: CompanyID,
                loginUserID: LoginUserID,
                CustomerID: _searchDetails.value.toString())));
      }
    });
  }

  ///updates data of inquiry list
  void _onInquiryListByNumberCallSuccess(
      SearchCustomerListByNumberCallResponseState state) {
    _inquiryListResponse = state.response;
  }

  void _onCustomerDeleteCallSucess(
      CustomerDeleteCallResponseState state, BuildContext context) {
    /* _inquiryListResponse.details
        .removeWhere((element) => element.customerID == state.id);*/

    print("CustomerDeleted" +
        state.customerDeleteResponse.details[0].column1.toString() +
        "");
    //baseBloc.refreshScreen();
    navigateTo(context, CustomerListScreen.routeName, clearAllStack: true);
  }

  void _onTapOfEditCustomer(CustomerDetails model) {
    navigateTo(context, Customer_ADD_EDIT.routeName,
            arguments: AddUpdateCustomerScreenArguments(model))
        .then((value) {
      _CustomerBloc
        ..add(CustomerListCallEvent(
            1,
            CustomerPaginationRequest(
                companyId: CompanyID,
                loginUserID: LoginUserID,
                CustomerID: "",
                ListMode: "L")));
    });
  }

  void _onTapOfDeleteInquiry(int id) {
    print("CUSTID" + id.toString());
    showCommonDialogWithTwoOptions(
        context, "Are you sure you want to delete this Customer?",
        negativeButtonTitle: "No",
        positiveButtonTitle: "Yes", onTapOfPositiveButton: () {
      Navigator.of(context).pop();
      //_collapse();
      _CustomerBloc.add(CustomerDeleteByNameCallEvent(
          id, CustomerDeleteRequest(CompanyID: CompanyID.toString())));
      // _CustomerBloc..add(CustomerListCallEvent(1,CustomerPaginationRequest(companyId: CompanyID,loginUserID: LoginUserID,CustomerID: "",ListMode: "L")));
    });
  }
}
