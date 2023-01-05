part of 'authentication_bloc.dart';

abstract class AuthenticationStates extends BaseStates {
  const AuthenticationStates();
}

///all states of AuthenticationStates

class AuthenticationInitialState extends AuthenticationStates {}

class ComapnyDetailsResponseState extends AuthenticationStates {
  final CompanyDetailsResponse companyDetailsResponse;

  ComapnyDetailsResponseState(this.companyDetailsResponse);
}

class LoginUserDetialsResponseState extends AuthenticationStates {
  //declare and pass request as below
  BuildContext contextfromScreen;
  LoginUserDetialsResponse response;
  LoginUserDetialsResponseState(this.contextfromScreen, this.response);
}
