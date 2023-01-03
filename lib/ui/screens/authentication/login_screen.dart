import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soleoserp/blocs/other/authentication/authentication_bloc.dart';
import 'package:soleoserp/models/api_request/login/login_request.dart';
import 'package:soleoserp/models/api_response/company_details/company_details_response.dart';
import 'package:soleoserp/models/api_response/login/login_user_details_api_response.dart';
import 'package:soleoserp/ui/res/dimen_resources.dart';
import 'package:soleoserp/ui/screens/authentication/registration_screen.dart';
import 'package:soleoserp/ui/screens/base/base_screen.dart';
import 'package:soleoserp/ui/screens/dashboard/home_screen.dart';
import 'package:soleoserp/ui/widgets/common_widgets.dart';
import 'package:soleoserp/utils/general_utils.dart';
import 'package:soleoserp/utils/shared_pref_helper.dart';

class LoginScreen extends BaseStatefulWidget {
  static const routeName = '/LoginScreen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends BaseState<LoginScreen>
    with BasicScreen, WidgetsBindingObserver {
  AuthenticationBloc _authenticationBloc;
  CompanyDetailsResponse _offlineCompanyData;
  int CompanyID = 0;
  bool _isObscure = true;

  TextEditingController _userNameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    screenStatusBarColor = Colors.white;
    _offlineCompanyData = SharedPrefHelper.instance.getCompanyData();
    CompanyID = _offlineCompanyData.details[0].pkId;
    _authenticationBloc = AuthenticationBloc(baseBloc);
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
          if (state is LoginUserDetialsResponseState) {
            _onLoginAPiResponse(state.response);
          }
          return super.build(context);
        },
        buildWhen: (oldState, currentState) {
          //return true for state for which builder method should be called
          if (currentState is LoginUserDetialsResponseState) {
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
  Widget buildBody(BuildContext context) {
    /*edt_User_Name.text = "admin";
    edt_User_Password.text = "admin!@#";*/

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
              left: DEFAULT_SCREEN_LEFT_RIGHT_MARGIN,
              right: DEFAULT_SCREEN_LEFT_RIGHT_MARGIN,
              top: 50,
              bottom: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopView(),
              SizedBox(height: 20),
              _buildDelaerLoginForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /* Image.asset(
          IMG_HEADER_LOGO,
          width: MediaQuery.of(context).size.width / 1.5,
          fit: BoxFit.fitWidth,
        ),*/

        Container(
          width: 200.0,
          height: 100.0,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Container(
                child: Center(
              child: Icon(Icons.account_balance),
            )),
          ),
        ),

        /* FittedBox(
            child: Image.network(
                SiteUrl + "/images/companylogo/CompanyLogo.png",
                width: 100,
                height: 150,
                fit: BoxFit.) //values(BoxFit.fitHeight,BoxFit.fitWidth)),
            ),*/
        SizedBox(
          height: 40,
        ),
        /* Text(
          "Login",
          style: baseTheme.textTheme.headline1,
        ),*/
        Text(
          "Login",
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
          "Log in to your existant account",
          style: TextStyle(
            color: Color(0xff019ee9),
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildDelaerLoginForm() {
    return Form(
      child: Column(
        children: [
          getCommonTextFormField(context, baseTheme,
              title: "Username",
              hint: "enter username",
              //labelColor: _selectedIndex == 0 ? Color(0xff3a3285) : Colors.brown,
              keyboardType: TextInputType.emailAddress,
              // titleTextStyle: TextStyle(color: Colors.brown),
              suffixIcon: Icon(Icons.person),
              controller: _userNameController, validator: (value) {
            if (value.toString().trim().isEmpty) {
              return "Please enter this field";
            }
            return null;
          }),
          SizedBox(
            height: 25,
          ),
          getCommonTextFormField(context, baseTheme,
              title: "Password",
              hint: "enter password",
              obscureText: _isObscure,
              // labelColor: _selectedIndex == 0 ? Color(0xff3a3285) : Colors.brown,
              textInputAction: TextInputAction.done,
              suffixIcon: /*ImageIcon(
                Image.asset(
                  IC_PASSWORD,
                  color: colorPrimary,
                  width: 10,
                  height: 10,
                ).image,
              ),*/
                  IconButton(
                icon: Icon(
                  _isObscure ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isObscure = !_isObscure;
                  });
                },
              ),
              controller: _passwordController, validator: (value) {
            if (value.toString().trim().isEmpty) {
              return "Please enter this field";
            }
            return null;
          }),
          SizedBox(
            height: 52,
          ),
          /*Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () {
                _onTapOfForgetPassword();
              },
              child: Text(
                "Forget Password?",
                style: baseTheme.textTheme.headline2,
              ),
            ),
          ),*/
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: getCommonButton(baseTheme, () {
                  _onTapOfLogin();
                }, "Login",
                    radius: 15,
                    backGroundColor: Color(
                        0xff3a3285) /*_selectedIndex == 0 ? Color(0xff3a3285) : Colors.brown*/),
              ),
              SizedBox(
                width: 5,
              ),
              Expanded(
                child: getCommonButton(baseTheme, () async {
                  _onTapOfRegister();
                }, "LogOut",
                    radius: 15,
                    backGroundColor: Color(
                        0xff3a3285) /*_selectedIndex == 0 ? Color(0xff3a3285) : Colors.brown*/),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _onTapOfLogin() {
    if (_userNameController.text != "") {
      if (_passwordController.text != "") {
        _authenticationBloc.add(LoginRequestEvent(LoginRequest(
            userID: _userNameController.text.toString(),
            password: _passwordController.text.toString(),
            companyId: _offlineCompanyData.details[0].pkId)));
      } else {
        showCommonDialogWithSingleOption(context, "Password is Required",
            positiveButtonTitle: "OK");
      }
    } else {
      showCommonDialogWithSingleOption(context, "UserName is Required",
          positiveButtonTitle: "OK");
    }
    //TODO
  }

  void _onTapOfRegister() {
    SharedPrefHelper.instance.putBool(SharedPrefHelper.IS_REGISTERED, false);
    navigateTo(context, RegistrationScreen.routeName, clearAllStack: true);
    // navigateTo(context, RegisterScreen.routeName, clearAllStack: true);
  }

  void _onLoginAPiResponse(LoginUserDetialsResponse response) {
    print("LoginResponse" +
        "Api Response EmployeeNAme : " +
        response.details[0].employeeName);
    SharedPrefHelper.instance.putBool(SharedPrefHelper.IS_LOGGED_IN_DATA, true);
    SharedPrefHelper.instance.setLoginUserData(response);
    _offlineCompanyData = SharedPrefHelper.instance.getCompanyData();

    navigateTo(context, HomeScreen.routeName, clearAllStack: true);
  }
}
