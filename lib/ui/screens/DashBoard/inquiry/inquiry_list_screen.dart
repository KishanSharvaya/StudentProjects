import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soleoserp/blocs/other/inquiry/inquiry_bloc.dart';
import 'package:soleoserp/models/api_request/customer/customer_search_by_id_request.dart';
import 'package:soleoserp/models/api_request/inquiry/InquiryShareModel.dart';
import 'package:soleoserp/models/api_request/inquiry/inquiry_list_request.dart';
import 'package:soleoserp/models/api_request/inquiry/inquiry_search_by_pk_id_request.dart';
import 'package:soleoserp/models/api_response/company_details/company_details_response.dart';
import 'package:soleoserp/models/api_response/customer/customer_details_api_response.dart';
import 'package:soleoserp/models/api_response/inquiry/inquiry_list_reponse.dart';
import 'package:soleoserp/models/api_response/inquiry/inquiry_no_to_product_response.dart';
import 'package:soleoserp/models/api_response/inquiry/search_inquiry_list_response.dart';
import 'package:soleoserp/models/api_response/login/login_user_details_api_response.dart';
import 'package:soleoserp/models/api_response/other/follower_employee_list_response.dart';
import 'package:soleoserp/models/common/all_name_id_list.dart';
import 'package:soleoserp/ui/res/color_resources.dart';
import 'package:soleoserp/ui/screens/base/base_screen.dart';
import 'package:soleoserp/ui/screens/DashBoard/home_screen.dart';
import 'package:soleoserp/ui/screens/DashBoard/inquiry/inquiry_add_edit.dart';
import 'package:soleoserp/ui/screens/DashBoard/inquiry/search_inquiry_screen.dart';
import 'package:soleoserp/utils/date_time_extensions.dart';
import 'package:soleoserp/utils/general_utils.dart';
import 'package:soleoserp/utils/offline_db_helper.dart';
import 'package:soleoserp/utils/shared_pref_helper.dart';

///import 'package:whatsapp_share/whatsapp_share.dart';ge:whatsapp_share/whatsapp_share.dart';

class InquiryListScreen extends BaseStatefulWidget {
  static const routeName = '/inquiryListScreen';

  @override
  _InquiryListScreenState createState() => _InquiryListScreenState();
}

class _InquiryListScreenState extends BaseState<InquiryListScreen>
    with BasicScreen, WidgetsBindingObserver {
  InquiryBloc _inquiryBloc;
  int _pageNo = 0;
  InquiryListResponse _inquiryListResponse;
  bool expanded = true;
  var color = Color(0xFFFCFCFC);

  double sizeboxsize = 12;
  double _fontSize_Label = 9;
  double _fontSize_Title = 11;
  int label_color = 0xff0066b3; //0x66666666;
  int title_color = 0xff0066b3;
  SearchInquiryDetails _searchDetails;
  CompanyDetailsResponse _offlineCompanyData;
  LoginUserDetialsResponse _offlineLoggedInData;

  int CompanyID = 0;
  String LoginUserID = "";
  var _url = "https://api.whatsapp.com/send?phone=91";
  bool isDeleteVisible = true;
  GlobalKey<NavigatorState> _yourKey = GlobalKey<NavigatorState>();
  List<InquiryShareModel> arr_ALL_Name_ID_For_Folowup_EmplyeeList = [];
  FollowerEmployeeListResponse _offlineFollowerEmployeeListData;

  double DEFAULT_HEIGHT_BETWEEN_WIDGET = 3;

  String INQ = "";
  CustomerDetails customerDetails = CustomerDetails();

  bool IsAddRights = true;
  bool IsEditRights = true;
  bool IsDeleteRights = true;

  @override
  void initState() {
    super.initState();
    screenStatusBarColor = colorPrimary;
    _offlineLoggedInData = SharedPrefHelper.instance.getLoginUserData();
    _offlineCompanyData = SharedPrefHelper.instance.getCompanyData();

    CompanyID = _offlineCompanyData.details[0].pkId;
    LoginUserID = _offlineLoggedInData.details[0].userID;
    _inquiryBloc = InquiryBloc(baseBloc);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => _inquiryBloc
        ..add(InquiryListCallEvent(
            1,
            InquiryListApiRequest(
                CompanyId: CompanyID.toString(),
                LoginUserID: LoginUserID.toString(),
                PkId: ""))),
      child: BlocConsumer<InquiryBloc, InquiryStates>(
        builder: (BuildContext context, InquiryStates state) {
          if (state is InquiryListCallResponseState) {
            _onInquiryListCallSuccess(state);
          }
          if (state is InquirySearchByPkIDResponseState) {
            _onInquiryListByNumberCallSuccess(state);
          }

          return super.build(context);
        },
        buildWhen: (oldState, currentState) {
          if (currentState is InquiryListCallResponseState ||
              currentState is InquirySearchByPkIDResponseState) {
            return true;
          }
          return false;
        },
        listener: (BuildContext context, InquiryStates state) {
          if (state is InquiryDeleteCallResponseState) {
            _onInquiryDeleteCallSucess(state, context);
          }

          if (state is InquiryShareResponseState) {
            _OnInquiryShareResponseSucess(state);
          }

          if (state is SearchCustomerListByNumberCallResponseState) {
            _ONOnlyCustomerDetails(state);
          }

          if (state is InquiryNotoProductResponseState) {
            _OnInquiryNoToProductListResponse(state);
          }
          return super.build(context);
        },
        listenWhen: (oldState, currentState) {
          if (currentState is InquiryDeleteCallResponseState ||
              currentState is InquiryShareResponseState ||
              currentState is InquiryShareEmpListResponseState ||
              currentState is SearchCustomerListByNumberCallResponseState ||
              currentState is InquiryNotoProductResponseState) {
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
      onWillPop: () {
        navigateTo(context, HomeScreen.routeName, clearAllStack: true);
        return new Future(() => false);
      },
      child: Scaffold(
        backgroundColor: colorVeryLightCardBG,
        appBar: AppBar(
          title: Text('Inquiry List'),
          actions: <Widget>[
            GestureDetector(
                onTap: () {
                  // _buildSearchView();
                  _onTaptoSearchInquiryView();
                },
                child: Icon(Icons.search)),
            SizedBox(
              width: 10,
            ),
            IconButton(
                icon: Icon(
                  Icons.water_damage_sharp,
                  color: colorWhite,
                ),
                onPressed: () {
                  //_onTapOfLogOut();
                  navigateTo(context, HomeScreen.routeName,
                      clearAllStack: true);
                })
          ],
        ),
        body: Container(
          child: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    _inquiryBloc.add(InquiryListCallEvent(
                        1,
                        InquiryListApiRequest(
                            CompanyId: CompanyID.toString(),
                            LoginUserID: LoginUserID.toString(),
                            PkId: "")));
                  },
                  child: Container(
                    padding: EdgeInsets.only(
                      left: 5,
                      right: 5,
                      top: 10,
                    ),
                    margin: EdgeInsets.only(bottom: 10),
                    child: Column(
                      children: [Expanded(child: _buildInquiryList())],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: IsAddRights == true
            ? FloatingActionButton(
                onPressed: () async {
                  await _onTapOfDeleteALLProduct();

                  navigateTo(context, InquiryAddEditScreen.routeName);
                },
                child: Icon(Icons.add),
                heroTag: "fab2",
                backgroundColor: colorPrimary,
              )
            : Container(),
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

  ///builds inquiry row items title and value's common view
  Widget _buildTitleWithValueView(
      String title, String value, String InquirySource, InquiryDetails model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: _fontSize_Label,
                color: model.InquirySourceName == "India Mart"
                    ? Color(label_color)
                    : Color(label_color),
                fontStyle: FontStyle
                    .italic) // baseTheme.textTheme.headline2.copyWith(color: colorBlack),
            ),
        SizedBox(
          height: 3,
        ),
        ColorCombination(value, InquirySource, model),
      ],
    );
  }

  ///updates data of inquiry list
  void _onInquiryListCallSuccess(InquiryListCallResponseState state) {
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
    _inquiryBloc.add(InquiryListCallEvent(
        _pageNo + 1,
        InquiryListApiRequest(
            CompanyId: CompanyID.toString(),
            LoginUserID: LoginUserID.toString(),
            PkId: "")));
  }

  ExpantionCustomer(BuildContext context, int index) {
    InquiryDetails model = _inquiryListResponse.details[index];

    return Container(
      padding: EdgeInsets.all(15),
      child: ExpansionTileCard(
        initialElevation: 5.0,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        elevation: 1,
        elevationCurve: Curves.easeInOut,
        shadowColor: Color(0xFF504F4F),
        baseColor: Color(0xFFFCFCFC),
        expandedColor: colorTileBG,
        title: /*Text(
          model.customerName,
          style: TextStyle(
              color: model.InquirySourceName == "India Mart"
                  ? Color(0xFF8A2CE2)
                  : Color(0xFF8A2CE2)), //8A2CE2)),
        ),*/
            Row(
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
        subtitle: Container(
          padding: EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 2),
          child: Row(
            children: [
              Icon(
                Icons.confirmation_num,
                color: Color(0xff108dcf),
                size: 18,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                model.inquiryNo,
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
        children: <Widget>[
          Divider(
            thickness: 1.0,
            height: 1.0,
          ),
          Container(
            margin: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: DEFAULT_HEIGHT_BETWEEN_WIDGET,
                ),
                Card(
                  color: colorBackGroundGray,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Container(
                    padding:
                        EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Flexible(
                            child: Row(
                              children: [
                                Column(
                                  children: [
                                    Icon(
                                      Icons.confirmation_num,
                                      color: colorCardBG,
                                    ),
                                    Text("Lead",
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
                                      model
                                          .inquiryNo, //put your own long text here.
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
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Icon(
                                      Icons.calendar_today_outlined,
                                      color: colorCardBG,
                                    ),
                                    Text("Inquiry",
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
                                      model.inquiryDate.getFormattedDate(
                                              fromFormat: "yyyy-MM-ddTHH:mm:ss",
                                              toFormat: "dd-MM-yyyy") ??
                                          "-",
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
                  height: DEFAULT_HEIGHT_BETWEEN_WIDGET,
                ),
                Card(
                  color: colorBackGroundGray,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Container(
                    padding:
                        EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      model.InquirySourceName.replaceAll(
                                              " ", "") ??
                                          "-", //put your own long text here.
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
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Icon(
                                      Icons.category,
                                      color: colorCardBG,
                                    ),
                                    Text("Status",
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
                                  child: Text(model.inquiryStatus ?? "-",
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
                  height: DEFAULT_HEIGHT_BETWEEN_WIDGET,
                ),
                Card(
                  color: colorBackGroundGray,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Container(
                    padding:
                        EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Column(
                          children: [
                            Icon(
                              Icons.assignment_ind,
                              color: colorCardBG,
                            ),
                            Text("Ref.",
                                style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: colorCardBG,
                                    fontSize: 7,
                                    letterSpacing: .3))
                          ],
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          child: Text(
                              model.referenceName == "" ||
                                      model.referenceName == null
                                  ? '-'
                                  : model
                                      .referenceName, //put your own long text here.
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
                  height: DEFAULT_HEIGHT_BETWEEN_WIDGET,
                ),
                Card(
                  color: colorBackGroundGray,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Container(
                    padding:
                        EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          _inquiryListResponse.details[index].followupDate == ''
                              ? Flexible(
                                  child: Row(
                                    children: [
                                      Column(
                                        children: [
                                          Icon(
                                            Icons.calendar_today_outlined,
                                            color: colorCardBG,
                                          ),
                                          Text("FollowUp",
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
                                            model.followupDate.getFormattedDate(
                                                    fromFormat:
                                                        "yyyy-MM-ddTHH:mm:ss",
                                                    toFormat: "dd-MM-yyyy") ??
                                                "-", //put your own long text here.
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
                              : Container(),
                          Flexible(
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Icon(
                                      Icons.calendar_today_outlined,
                                      color: colorCardBG,
                                    ),
                                    Text("Create",
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
                                      model.createdDate.getFormattedDate(
                                          fromFormat: "yyyy-MM-ddTHH:mm:ss",
                                          toFormat: "dd-MM-yyyy"),
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
                  height: DEFAULT_HEIGHT_BETWEEN_WIDGET,
                ),
                Card(
                  color: colorBackGroundGray,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Container(
                    padding:
                        EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Column(
                          children: [
                            Icon(
                              Icons.perm_contact_cal_rounded,
                              color: colorCardBG,
                            ),
                            Text("By",
                                style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: colorCardBG,
                                    fontSize: 7,
                                    letterSpacing: .3))
                          ],
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          child: Text(
                              model.createdBy, //put your own long text here.
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
                  height: DEFAULT_HEIGHT_BETWEEN_WIDGET,
                ),
              ],
            ),
          ),
          Divider(
            thickness: 1.0,
            height: 1.0,
          ),
          SizedBox(
            height: 10,
          ),
          IsEditRights == false && IsDeleteRights == false
              ? Container()
              : Card(
                  color: colorCardBG,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Container(
                    width: 300,
                    height: 50,
                    child: ButtonBar(
                        alignment: MainAxisAlignment.center,
                        buttonHeight: 52.0,
                        buttonMinWidth: 90.0,
                        children: <Widget>[
                          IsEditRights == true
                              ? Container(
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 10,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          // _onTapOfEditCustomer(model);

                                          _onTapOfEditInquiry(model);
                                        },
                                        child: Row(
                                          children: <Widget>[
                                            Icon(Icons.edit),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 2.0),
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
                                    ],
                                  ),
                                )
                              : Container(),
                          IsDeleteRights == true
                              ? GestureDetector(
                                  onTap: () {
                                    _onTapOfDeleteInquiry(model.pkID);
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
      ),
    );
  }

  ///updates data of inquiry list
  void _onInquiryListByNumberCallSuccess(
      InquirySearchByPkIDResponseState state) {
    _inquiryListResponse = state.response;
  }

  void _onTapOfEditInquiry(InquiryDetails model) {
    navigateTo(context, InquiryAddEditScreen.routeName,
            arguments: AddUpdateInquiryScreenArguments(model))
        .then((value) {
      _inquiryBloc
        ..add(InquiryListCallEvent(
            1,
            InquiryListApiRequest(
                CompanyId: CompanyID.toString(),
                LoginUserID: LoginUserID.toString(),
                PkId: "")));
    });
  }

  void _onTapOfDeleteInquiry(int id) {
    showCommonDialogWithTwoOptions(
        context, "Are you sure you want to delete this Inquiry Request ?",
        negativeButtonTitle: "No",
        positiveButtonTitle: "Yes", onTapOfPositiveButton: () {
      Navigator.of(context).pop();
      //_collapse();
    });
  }

  void _onInquiryDeleteCallSucess(
      InquiryDeleteCallResponseState state, BuildContext buildContext123) {
    /* _FollowupListResponse.details
        .removeWhere((element) => element.pkID == state.id);*/
    print("CustomerDeleted" +
        state.inquiryDeleteResponse.details[0].column1.toString() +
        "");
    // baseBloc.refreshScreen();
    navigateTo(buildContext123, InquiryListScreen.routeName,
        clearAllStack: true);
  }

  Future<void> _onTapOfDeleteALLProduct() async {
    await OfflineDbHelper.getInstance().deleteALLInquiryProduct();
  }

  Widget ColorCombination(
      String value, String inquirySource, InquiryDetails model) {
    if (inquirySource == "Close - Success") {
      return Text(value,
          style: TextStyle(
              fontSize: _fontSize_Title,
              color:
                  colorGreen) // baseTheme.textTheme.headline2.copyWith(color: colorBlack),
          );
    } else if (inquirySource == "Work In Progress") {
      return Text(value,
          style:
              TextStyle(fontSize: _fontSize_Title, color: Color(0xFF0E0EFF)));
    } else {
      return Text(value,
          style: TextStyle(
              fontSize: _fontSize_Title,
              color: model.InquirySourceName == "India Mart"
                  ? colorGrayDark
                  : colorGrayDark));
    }
  }

  void _OnInquiryShareResponseSucess(InquiryShareResponseState state) {
    for (var i = 0; i < state.inquiryShareResponse.details.length; i++) {
      print("ResponseMsgShare" +
          "Column1 : " +
          state.inquiryShareResponse.details[0].column1.toString() +
          "\n" +
          "Column2 : " +
          state.inquiryShareResponse.details[0].column2);
    }
  }

  showcustomdialogWithCheckBox(
      {List<InquiryShareModel> values,
      BuildContext context1,
      /*TextEditingController controller,
      TextEditingController controllerID,
      TextEditingController controller2,*/
      List<ALL_Name_ID> all_name_id,
      String lable,
      bool isChecked12 = false}) async {
    await showDialog(
      barrierDismissible: false,
      context: context1,
      builder: (BuildContext context123) {
        return SimpleDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32.0))),
          title: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: colorPrimary, //                   <--- border color
                ),
                borderRadius: BorderRadius.all(Radius.circular(
                        15.0) //                 <--- border radius here
                    ),
              ),
              child: Container(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    lable,
                    style: TextStyle(
                        color: colorPrimary, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ))),
          children: [
            SizedBox(
                width: MediaQuery.of(context123).size.width,
                child: Column(
                  children: [
                    SingleChildScrollView(
                        physics: ScrollPhysics(),
                        child: Column(children: <Widget>[
                          new ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: values.length,
                              itemBuilder: (BuildContext context, int index) {
                                return new Card(
                                  child: new Container(
                                    padding: new EdgeInsets.all(10.0),
                                    child: Column(
                                      children: <Widget>[
                                        new CheckboxListTile(
                                            activeColor: Colors.pink[300],
                                            dense: true,
                                            //font change
                                            title: new Text(
                                              values[index].EmployeeName,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0.5),
                                            ),
                                            value: values[index].ISCHECKED,
                                            secondary: Container(
                                              height: 50,
                                              width: 50,
                                            ),
                                            onChanged: (bool val) {
                                              setState(() {
                                                itemChange(val, index, values);
                                              });
                                            })
                                      ],
                                    ),
                                  ),
                                );
                              }),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              fixedSize: Size(90, 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(24.0),
                                ),
                              ),
                            ),
                            child: Text("Share Inquiry"),
                            onPressed: () => {generateShare(values)},
                          ),
                        ])),
                  ],
                )),
          ],
        );
      },
    );
  }

  generateShare(List<InquiryShareModel> all_name_id) {
    for (var i = 0; i < all_name_id.length; i++) {
      print("MessageStorate" +
          "EMpName" +
          all_name_id[i].EmployeeName +
          "ISChecked" +
          all_name_id[i].ISCHECKED.toString());
    }
  }

  void itemChange(bool val, int index, List<InquiryShareModel> values) {
    setState(() {
      values[index].ISCHECKED = val;
    });
  }

  void _onTaptoSearchInquiryView() {
    navigateTo(context, SearchInquiryScreen.routeName).then((value) {
      if (value != null) {
        SearchInquiryDetails model = value;

        /* _inquiryBloc.add(SearchInquiryListByNumberCallEvent(
            SearchInquiryListByNumberRequest(
                searchKey: _searchDetails.label,CompanyId:CompanyID.toString(),LoginUserID: LoginUserID.toString())));*/
        _inquiryBloc.add(InquirySearchByPkIDCallEvent(
            model.pkID.toString(),
            InquirySearchByPkIdRequest(
                CompanyId: CompanyID.toString(), LoginUserID: LoginUserID)));
      }
    });
  }

  void FetchCustomerDetails(int customerID321) {
    _inquiryBloc.add(SearchCustomerListByNumberCallEvent(
        CustomerSearchByIdRequest(
            companyId: CompanyID,
            loginUserID: LoginUserID,
            CustomerID: customerID321.toString())));
  }

  void _ONOnlyCustomerDetails(
      SearchCustomerListByNumberCallResponseState state) {
    for (int i = 0; i < state.response.details.length; i++) {
      print("CustomerDetailsw" +
          "CustomerName : " +
          state.response.details[i].customerName +
          " Customer ID : " +
          state.response.details[i].customerID.toString());
    }

    customerDetails = CustomerDetails();
    customerDetails.customerName = state.response.details[0].customerName;
    customerDetails.customerType = state.response.details[0].customerType;
    customerDetails.customerSourceName =
        state.response.details[0].customerSourceName;
    customerDetails.contactNo1 = state.response.details[0].contactNo1;
    customerDetails.emailAddress = state.response.details[0].emailAddress;
    customerDetails.address = state.response.details[0].address;
    customerDetails.area = state.response.details[0].area;
    customerDetails.pinCode = state.response.details[0].pinCode;
    customerDetails.countryName = state.response.details[0].countryName;
    customerDetails.stateName = state.response.details[0].stateName;
    customerDetails.cityName = state.response.details[0].cityName;
    customerDetails.cityName = state.response.details[0].cityName;

    showcustomdialog(
      context1: context,
      customerDetails123: customerDetails,
    );
  }

  showcustomdialog({
    BuildContext context1,
    CustomerDetails customerDetails123,
  }) async {
    await showDialog(
      barrierDismissible: false,
      context: context1,
      builder: (BuildContext context123) {
        return SimpleDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32.0))),
          title: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: colorPrimary, //                   <--- border color
                ),
                borderRadius: BorderRadius.all(Radius.circular(
                        15.0) //                 <--- border radius here
                    ),
              ),
              child: Container(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "Customer Details",
                    style: TextStyle(
                        color: colorPrimary, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ))),
          children: [
            SizedBox(
                width: MediaQuery.of(context123).size.width,
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 20, right: 20),
                      child: Row(
                        //crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              customerDetails123.customerName,
                              style: TextStyle(color: colorBlack),
                            ),
                          )
                        ],
                      ),
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
                                  Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Expanded(
                                            flex: 1,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text("Category  ",
                                                    style: TextStyle(
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        color:
                                                            Color(label_color),
                                                        fontSize:
                                                            _fontSize_Label,
                                                        letterSpacing: .3)),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                    customerDetails123
                                                        .customerType
                                                        .toString(),
                                                    style: TextStyle(
                                                        color:
                                                            Color(title_color),
                                                        fontSize:
                                                            _fontSize_Title,
                                                        letterSpacing: .3)),
                                              ],
                                            )),
                                        Expanded(
                                            flex: 1,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text("Source",
                                                    style: TextStyle(
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        color:
                                                            Color(label_color),
                                                        fontSize:
                                                            _fontSize_Label,
                                                        letterSpacing: .3)),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                    customerDetails123
                                                                .customerSourceName ==
                                                            "--Not Available--"
                                                        ? "N/A"
                                                        : customerDetails123
                                                            .customerSourceName,
                                                    style: TextStyle(
                                                        color:
                                                            Color(title_color),
                                                        fontSize:
                                                            _fontSize_Title,
                                                        letterSpacing: .3)),
                                              ],
                                            )),
                                      ]),
                                  SizedBox(
                                    height: sizeboxsize,
                                  ),
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text("Contact No1.",
                                                      style: TextStyle(
                                                          fontStyle:
                                                              FontStyle.italic,
                                                          color: Color(
                                                              label_color),
                                                          fontSize:
                                                              _fontSize_Label,
                                                          letterSpacing: .3)),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                      customerDetails123
                                                                  .contactNo1 ==
                                                              ""
                                                          ? "N/A"
                                                          : customerDetails123
                                                              .contactNo1,
                                                      style: TextStyle(
                                                          color: Color(
                                                              title_color),
                                                          fontSize:
                                                              _fontSize_Title,
                                                          letterSpacing: .3))
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: sizeboxsize,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text("Email",
                                                style: TextStyle(
                                                    fontStyle: FontStyle.italic,
                                                    color: Color(label_color),
                                                    fontSize: _fontSize_Label,
                                                    letterSpacing: .3)),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                                customerDetails123
                                                            .emailAddress ==
                                                        ""
                                                    ? "N/A"
                                                    : customerDetails123
                                                        .emailAddress,
                                                style: TextStyle(
                                                    color: Color(title_color),
                                                    fontSize: _fontSize_Title,
                                                    letterSpacing: .3)),
                                          ],
                                        )
                                      ]),
                                  SizedBox(
                                    height: sizeboxsize,
                                  ),
                                  Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Expanded(
                                            flex: 1,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text("Address",
                                                    style: TextStyle(
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        color:
                                                            Color(label_color),
                                                        fontSize:
                                                            _fontSize_Label,
                                                        letterSpacing: .3)),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                    customerDetails123
                                                                .address ==
                                                            ""
                                                        ? "N/A"
                                                        : customerDetails123
                                                            .address,
                                                    style:
                                                        TextStyle(
                                                            color: Color(
                                                                title_color),
                                                            fontSize:
                                                                _fontSize_Title,
                                                            letterSpacing: .3)),
                                              ],
                                            ))
                                      ]),
                                  SizedBox(
                                    height: sizeboxsize,
                                  ),
                                  Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Expanded(
                                            flex: 1,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text("Area",
                                                    style: TextStyle(
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        color:
                                                            Color(label_color),
                                                        fontSize:
                                                            _fontSize_Label,
                                                        letterSpacing: .3)),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                    customerDetails123.area ==
                                                            ""
                                                        ? "N/A"
                                                        : customerDetails123
                                                            .area,
                                                    style: TextStyle(
                                                        color:
                                                            Color(title_color),
                                                        fontSize:
                                                            _fontSize_Title,
                                                        letterSpacing: .3)),
                                              ],
                                            )),
                                        Expanded(
                                            flex: 1,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text("Pin-Code",
                                                    style: TextStyle(
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        color:
                                                            Color(label_color),
                                                        fontSize:
                                                            _fontSize_Label,
                                                        letterSpacing: .3)),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                    customerDetails123
                                                                .pinCode ==
                                                            ""
                                                        ? "N/A"
                                                        : customerDetails123
                                                            .pinCode,
                                                    style:
                                                        TextStyle(
                                                            color: Color(
                                                                title_color),
                                                            fontSize:
                                                                _fontSize_Title,
                                                            letterSpacing: .3)),
                                              ],
                                            )),
                                      ]),
                                  SizedBox(
                                    height: sizeboxsize,
                                  ),
                                  Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Expanded(
                                            flex: 1,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text("Country",
                                                    style: TextStyle(
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        color:
                                                            Color(label_color),
                                                        fontSize:
                                                            _fontSize_Label,
                                                        letterSpacing: .3)),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                    customerDetails123
                                                                .countryName
                                                                .toString() ==
                                                            ""
                                                        ? "N/A"
                                                        : customerDetails123
                                                            .countryName
                                                            .toString(),
                                                    style: TextStyle(
                                                        color:
                                                            Color(title_color),
                                                        fontSize:
                                                            _fontSize_Title,
                                                        letterSpacing: .3)),
                                              ],
                                            )),
                                        Expanded(
                                            flex: 1,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text("State",
                                                    style: TextStyle(
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        color:
                                                            Color(label_color),
                                                        fontSize:
                                                            _fontSize_Label,
                                                        letterSpacing: .3)),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                    customerDetails123.stateName
                                                                .toString() ==
                                                            ""
                                                        ? "N/A"
                                                        : customerDetails123
                                                            .stateName
                                                            .toString(),
                                                    style: TextStyle(
                                                        color:
                                                            Color(title_color),
                                                        fontSize:
                                                            _fontSize_Title,
                                                        letterSpacing: .3)),
                                              ],
                                            )),
                                      ]),
                                  SizedBox(
                                    height: sizeboxsize,
                                  ),
                                  Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Expanded(
                                            flex: 1,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text("City",
                                                    style: TextStyle(
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        color:
                                                            Color(label_color),
                                                        fontSize:
                                                            _fontSize_Label,
                                                        letterSpacing: .3)),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                    customerDetails123
                                                                .cityName ==
                                                            null
                                                        ? "N/A"
                                                        : customerDetails123
                                                            .cityName,
                                                    style: TextStyle(
                                                        color:
                                                            Color(title_color),
                                                        fontSize:
                                                            _fontSize_Title,
                                                        letterSpacing: .3)),
                                              ],
                                            )),
                                      ]),
                                  SizedBox(
                                    height: sizeboxsize,
                                  ),
                                  GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context1);
                                      },
                                      child: Center(
                                          child: Text(
                                        "Close",
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: colorPrimary,
                                            fontWeight: FontWeight.bold),
                                      )))
                                ],
                              ),
                            ),
                          ],
                        ))),
                  ],
                )),
          ],
        );
      },
    );
  }

  void _OnInquiryNoToProductListResponse(
      InquiryNotoProductResponseState state) {
    List<InquiryProductDetails> arr_ProductListArray = [];

    for (var i = 0; i < state.inquiryNoToProductResponse.details.length; i++) {
      /* String LoginUserID="abc";
    String CompanyId="0";
    String InquiryNo="0";*/

      InquiryProductDetails inquiryProductDetails = InquiryProductDetails();

      inquiryProductDetails.productName =
          state.inquiryNoToProductResponse.details[i].productName;

      inquiryProductDetails.quantity =
          state.inquiryNoToProductResponse.details[i].quantity;
      inquiryProductDetails.unitPrice =
          state.inquiryNoToProductResponse.details[i].unitPrice;
      //double totamnt = double.parse(Quantity) * double.parse(UnitPrice);
      // String TotalAmount = totamnt.toString();
      arr_ProductListArray.add(inquiryProductDetails);
    }

    showcustomdialogWithOnlyName(
        values: arr_ProductListArray,
        context1: context,
        lable: "Product Details");
  }

  showcustomdialogWithOnlyName(
      {List<InquiryProductDetails> values,
      BuildContext context1,
      String lable}) async {
    await showDialog(
      barrierDismissible: false,
      context: context1,
      builder: (BuildContext context123) {
        return SimpleDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32.0))),
          title: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: colorPrimary, //                   <--- border color
                ),
                borderRadius: BorderRadius.all(Radius.circular(
                        15.0) //                 <--- border radius here
                    ),
              ),
              child: Container(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    lable,
                    style: TextStyle(
                        color: colorPrimary, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ))),
          children: [
            SizedBox(
                width: MediaQuery.of(context123).size.width,
                child: Column(
                  children: [
                    SingleChildScrollView(
                        physics: ScrollPhysics(),
                        child: Column(children: <Widget>[
                          ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (ctx, index) {
                              return InkWell(
                                onTap: () {
                                  Navigator.of(context1).pop();
                                  //controller.text = values[index].Name;
                                },
                                child: Container(
                                  margin: EdgeInsets.only(
                                      left: 25, top: 10, bottom: 10, right: 10),
                                  child: Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: colorPrimary), //Change color
                                        width: 10.0,
                                        height: 10.0,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 1.5),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Text(
                                        values[index].productName,
                                        style: TextStyle(color: colorPrimary),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Text(
                                        values[index]
                                            .quantity
                                            .toStringAsFixed(2),
                                        style: TextStyle(color: colorPrimary),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            itemCount: values.length,
                          ),
                        ])),
                  ],
                )),
          ],
        );
      },
    );
  }
}
