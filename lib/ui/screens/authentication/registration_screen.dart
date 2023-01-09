import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soleoserp/blocs/other/authentication/authentication_bloc.dart';
import 'package:soleoserp/models/api_request/registraion/registration_request.dart';
import 'package:soleoserp/models/api_response/company_details/company_details_response.dart';
import 'package:soleoserp/ui/res/color_resources.dart';
import 'package:soleoserp/ui/res/dimen_resources.dart';
import 'package:soleoserp/ui/screens/authentication/login_screen.dart';
import 'package:soleoserp/ui/screens/base/base_screen.dart';
import 'package:soleoserp/ui/widgets/common_widgets.dart';
import 'package:soleoserp/utils/general_utils.dart';
import 'package:soleoserp/utils/shared_pref_helper.dart';

class RegistrationScreen extends BaseStatefulWidget {
  static const routeName = '/RegistrationScreen';

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends BaseState<RegistrationScreen>
    with BasicScreen, WidgetsBindingObserver {
  AuthenticationBloc _authenticationBloc;
  TextEditingController _userNameController = TextEditingController();
  int count = 0;

  //static var BaseURLFROMScreen = "";

  @override
  void initState() {
    super.initState();
    screenStatusBarColor = Colors.white;
    _authenticationBloc = AuthenticationBloc(baseBloc);
    // BaseURLFROMScreen = "http://122.169.111.101:108/";
    SharedPrefHelper.instance.setBaseURL("http://122.169.111.101:108/");
    //ApiClient.BASE_URL = "http://122.169.111.101:108/";
  }

  ///listener and builder to multiple states of bloc to handles api responses
  ///use BlocProvider if need to listen and build
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => _authenticationBloc,
      child: BlocConsumer<AuthenticationBloc, AuthenticationStates>(
        builder: (BuildContext context, AuthenticationStates state) {
          //handle states

          return super.build(context);
        },
        buildWhen: (oldState, currentState) {
          //return true for state for which builder method should be called

          return false;
        },
        listener: (BuildContext context, AuthenticationStates state) {
          //handle states
          if (state is ComapnyDetailsResponseState) {
            _onRegstrationApiResponse(state.companyDetailsResponse);
          }
        },
        listenWhen: (oldState, currentState) {
          //return true for state for which listener method should be called
          if (currentState is ComapnyDetailsResponseState) {
            return true;
          }
          return false;
        },
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context123) {
    /*edt_User_Name.text = "admin";
    edt_User_Password.text = "admin!@#";*/

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
            left: DEFAULT_SCREEN_LEFT_RIGHT_MARGIN,
            right: DEFAULT_SCREEN_LEFT_RIGHT_MARGIN,
            top: 50,
            bottom: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildTopView(), SizedBox(height: 50), _buildLoginForm()],
        ),
      ),
    );
  }

  Widget _buildTopView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.topLeft,
          // width: MediaQuery.of(context).size.width / 1.5,
          child: Icon(
            Icons.vpn_key_outlined,
            color: colorPrimary,
            size: 78,
          ),
        ),
        SizedBox(
          height: 40,
        ),
        /* Text(
          "Login",
          style: baseTheme.textTheme.headline1,
        ),*/
        Text(
          "Registration",
          style: TextStyle(
            color: Color(0xff3a3285),
            fontSize: 48,
            fontFamily: "Poppins",
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          "Register your account",
          style: TextStyle(
            color: Color(0xff019ee9),
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      child: Column(
        children: [
          SerialKeyTextField(),
          SizedBox(
            height: 25,
          ),
          Container(
            margin: EdgeInsets.all(10),
            child: getCommonButton(baseTheme, () {
              _onTapOfLogin();
            }, "Register"),
          ),
          SizedBox(
            height: 20,
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  Widget SerialKeyTextField() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(left: 10, right: 20),
            child: Text("Serial Key",
                style: TextStyle(
                    fontSize: 15,
                    color:
                        colorPrimary) // baseTheme.textTheme.headline2.copyWith(color: colorBlack),

                ),
          ),
          SizedBox(
            height: 5,
          ),
          Card(
            elevation: 5,
            color: Color(0xffE0E0E0),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Container(
              height: 60,
              padding: EdgeInsets.only(left: 20, right: 20),
              width: double.maxFinite,
              child: Row(
                children: [
                  Expanded(
                      child: TextFormField(
                          maxLength: 19,
                          controller: _userNameController,
                          cursorColor: Color(0xFFF1E6FF),
                          decoration: InputDecoration(
                            icon: Icon(
                              Icons.vpn_key,
                            ),
                            hintText: "xxxx-xxxx-xxxx-xxxx",
                            border: InputBorder.none,
                            counterStyle: TextStyle(height: double.minPositive),
                            counterText: "",
                          ),
                          onChanged: (String value) async {
                            setState(() {
                              if (count <= _userNameController.text.length &&
                                  (_userNameController.text.length == 4 ||
                                      _userNameController.text.length == 9 ||
                                      _userNameController.text.length == 14)) {
                                _userNameController.text =
                                    _userNameController.text + "-";
                                int pos = _userNameController.text.length;
                                _userNameController.selection =
                                    TextSelection.fromPosition(
                                        TextPosition(offset: pos));
                              } else if (count >=
                                      _userNameController.text.length &&
                                  (_userNameController.text.length == 4 ||
                                      _userNameController.text.length == 9 ||
                                      _userNameController.text.length == 14)) {
                                _userNameController.text =
                                    _userNameController.text.substring(
                                        0, _userNameController.text.length - 1);
                                int pos = _userNameController.text.length;
                                _userNameController.selection =
                                    TextSelection.fromPosition(
                                        TextPosition(offset: pos));
                              }
                              count = _userNameController.text.length;
                            });
                          })),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onTapOfLogin() {
    if (_userNameController.text != "") {
      _authenticationBloc.add(RegistrationRequestEvent(
          RegistrationRequest(serialKey: _userNameController.text.toString())));
    } else {
      showCommonDialogWithSingleOption(context, "Serial Key field is blank !",
          positiveButtonTitle: "OK", onTapOfPositiveButton: () {
        Navigator.pop(context);
      });
    }
    //TODO
  }

  void _onRegstrationApiResponse(CompanyDetailsResponse response) {
    if (response.details.length != 0) {
      SharedPrefHelper.instance.setCompanyData(response);
      SharedPrefHelper.instance.putBool(SharedPrefHelper.IS_REGISTERED, true);
      print("Company Details : " +
          response.details[0].companyName.toString() +
          "");
      navigateTo(context, LoginScreen.routeName, clearAllStack: true);

      ///
    } else {
      showCommonDialogWithSingleOption(context, "Invalid SerialKey",
          positiveButtonTitle: "OK");
    }
  }
}
