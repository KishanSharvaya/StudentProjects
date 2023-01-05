part of 'authentication_bloc.dart';

@immutable
abstract class AuthenticationEvent {}

///all events of AuthenticationEvents

class RegistrationRequestEvent extends AuthenticationEvent {
  //declare and pass request as below
  RegistrationRequest request;
  RegistrationRequestEvent(this.request);
}

class LoginRequestEvent extends AuthenticationEvent {
  //declare and pass request as below

  BuildContext context;
  LoginRequest request;
  LoginRequestEvent(this.context, this.request);
}
