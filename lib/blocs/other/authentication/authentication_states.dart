part of 'authentication_bloc.dart';

abstract class AuthenticationStates extends BaseStates {
  const AuthenticationStates();
}

///all states of AuthenticationStates

class AuthenticationInitialState extends AuthenticationStates {}

class RegistrationResponseState extends AuthenticationStates {
  //declare and pass request as below
  RegistrationResponse response;
  RegistrationResponseState(this.response);
}

class LoginResponseState extends AuthenticationStates {
  //declare and pass request as below
  LoginResponse response;
  LoginResponseState(this.response);
}
