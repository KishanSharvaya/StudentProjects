import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_shine/flutter_shine.dart';
import 'package:soleoserp/blocs/other/authentication/authentication_bloc.dart';
import 'package:soleoserp/models/api_request/registraion/registration_request.dart';
import 'package:soleoserp/models/api_response/company_details/company_details_response.dart';
import 'package:soleoserp/models/api_response/login/login_user_details_api_response.dart';
import 'package:soleoserp/ui/res/color_resources.dart';
import 'package:soleoserp/ui/screens/authentication/login_screen.dart';
import 'package:soleoserp/ui/screens/base/base_screen.dart';
import 'package:soleoserp/ui/screens/DashBoard/Customer/customer_list_screen.dart';
import 'package:soleoserp/ui/screens/DashBoard/inquiry/inquiry_list_screen.dart';
import 'package:soleoserp/ui/widgets/common_widgets.dart';
import 'package:soleoserp/utils/general_utils.dart';
import 'package:soleoserp/utils/shared_pref_helper.dart';

//Commit from Master
class HomeScreen extends BaseStatefulWidget {
  static const routeName = '/HomeScreen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends BaseState<HomeScreen>
    with BasicScreen, WidgetsBindingObserver {
  AuthenticationBloc _authenticationBloc;
  CompanyDetailsResponse _offlineCompanyData;
  int CompanyID = 0;
  bool _isObscure = true;
  LoginUserDetialsResponse _offlineLoggedInData;

  @override
  void initState() {
    super.initState();
    screenStatusBarColor = Colors.white;
    _offlineCompanyData = SharedPrefHelper.instance.getCompanyData();
    _offlineLoggedInData = SharedPrefHelper.instance.getLoginUserData();
    CompanyID = _offlineCompanyData.details[0].pkId;
    _authenticationBloc = AuthenticationBloc(baseBloc);
    _authenticationBloc.add(RegistrationRequestEvent(RegistrationRequest(
        serialKey: _offlineLoggedInData.details[0].serialKey)));
  }

  ///listener and builder to multiple states of bloc to handles api responses
  ///use BlocProvider if need to listen and build
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => _authenticationBloc
        ..add(RegistrationRequestEvent(RegistrationRequest(
            serialKey: _offlineLoggedInData.details[0].serialKey))),
      child: BlocConsumer<AuthenticationBloc, AuthenticationStates>(
        builder: (BuildContext context, AuthenticationStates state) {
          //handle states
          if (state is ComapnyDetailsResponseState) {
            getCompanyDataResponse(state);
          }

          return super.build(context);
        },
        buildWhen: (oldState, currentState) {
          //return true for state for which builder method should be called

          if (currentState is ComapnyDetailsResponseState) {
            return true;
          }
          return false;
        },
        listener: (BuildContext context, AuthenticationStates state) {
          //handle states
        },
        listenWhen: (oldState, currentState) {
          //return true for state for which listener method should be called
          return false;
        },
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context123) {
    /*edt_User_Name.text = "admin";
    edt_User_Password.text = "admin!@#";*/

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => Container(
            margin: EdgeInsets.only(top: 14, left: 10),
            child: IconButton(
              iconSize: 35,
              icon: Icon(Icons.menu),
            ),
          ),
        ),
        title: Container(
          margin: EdgeInsets.only(top: 20),
          child: FlutterShine(
            light: Light(intensity: 1, position: Point(5, 5)),
            builder: (BuildContext context, ShineShadow shineShadow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Text(
                    "DashBoard",
                    style: TextStyle(
                      color: colorPrimary,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        backgroundColor: colorVeryLightGray,
        foregroundColor: colorPrimary,
        elevation: 0,
        primary: false,
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              UserProfileDialog(context1: context);
            },
            child: Container(
              padding: EdgeInsets.only(top: 20, right: 20),
              child: Icon(
                Icons.person_pin_rounded,
                size: 30,
                color: colorPrimary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              SharedPrefHelper.instance
                  .putBool(SharedPrefHelper.IS_LOGGED_IN_DATA, false);

              navigateTo(context, LoginScreen.routeName, clearAllStack: true);
            },
            child: Container(
              padding: EdgeInsets.only(top: 20, right: 20),
              child: Icon(
                Icons.login,
                size: 30,
                color: colorPrimary,
              ),
            ),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          navigateTo(context, HomeScreen.routeName, clearAllStack: true);
        },
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(left: 40, right: 40, top: 50, bottom: 50),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          onTap: () {
                            navigateTo(context, CustomerListScreen.routeName,
                                clearAllStack: true);
                          },
                          child: Column(
                            children: [
                              Icon(
                                Icons.people,
                                size: 42,
                              ),
                              Text("Customer")
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            navigateTo(context, InquiryListScreen.routeName);
                          },
                          child: Column(
                            children: [
                              Icon(
                                Icons.call,
                                size: 42,
                              ),
                              Text("Inquiry")
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Center(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Icon(
                              Icons.follow_the_signs,
                              size: 42,
                            ),
                            Text("Followup")
                          ],
                        ),
                        Column(
                          children: [
                            Icon(
                              Icons.add_task,
                              size: 42,
                            ),
                            Text("ToDo")
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  UserProfileDialog({BuildContext context1}) {
    showDialog(
      barrierDismissible: false,
      context: context1,
      builder: (BuildContext context123) {
        return SimpleDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32.0))),
          children: [
            SizedBox(
                width: MediaQuery.of(context123).size.width,
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: EdgeInsets.all(8), // Border width
                      decoration: BoxDecoration(
                          color: colorLightGray, shape: BoxShape.circle),
                      child: ClipOval(
                        child: SizedBox.fromSize(
                          size: Size.fromRadius(80), // Image radius
                          child: Icon(Icons.person),
                        ),
                      ),
                    ),
                    /*Center(
                      child: Image.network(
                        ImgFromTextFiled.text,
                        key: ValueKey(new Random().nextInt(100)),
                        height: 200,
                        width: 200,
                        errorBuilder: (BuildContext context, Object exception,
                            StackTrace stackTrace) {
                          return Image.network(
                              "https://img.icons8.com/color/2x/no-image.png",
                              height: 48,
                              width: 48);
                        },
                      ),
                    ),*/
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 25),
                      child: Row(
                        children: [
                          Container(
                            child: Text(
                              "User : ",
                              style: TextStyle(
                                  color: colorPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic),
                            ),
                          ),
                          Container(
                              child: Text(
                                  _offlineLoggedInData.details[0].employeeName,
                                  style: TextStyle(
                                    color: colorBlack,
                                  ))),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 25),
                      child: Row(
                        children: [
                          Container(
                            child: Text(
                              "Role : ",
                              style: TextStyle(
                                  color: colorPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic),
                            ),
                          ),
                          Container(
                            child:
                                Text(_offlineLoggedInData.details[0].roleName,
                                    style: TextStyle(
                                      color: colorBlack,
                                    )),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 25),
                      child: Row(
                        children: [
                          Container(
                            child: Text(
                              "State : ",
                              style: TextStyle(
                                  color: colorPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic),
                            ),
                          ),
                          Container(
                            child:
                                Text(_offlineLoggedInData.details[0].StateName,
                                    style: TextStyle(
                                      color: colorBlack,
                                    )),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 10, right: 10),
                      child: getCommonButton(baseTheme, () {
                        Navigator.pop(context123);
                      }, "Close", backGroundColor: colorPrimary, radius: 25.0),
                    ),
                  ],
                )),
          ],
        );
      },
    );
  }

  void getCompanyDataResponse(ComapnyDetailsResponseState state) {
    print("CompanyData" + state.companyDetailsResponse.details[0].companyName);
  }
}
