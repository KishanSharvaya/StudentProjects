import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soleoserp/blocs/base/base_bloc.dart';
import 'package:soleoserp/models/api_request/login/login_request.dart';
import 'package:soleoserp/models/api_request/registraion/registration_request.dart';
import 'package:soleoserp/models/api_response/login/login_response.dart';
import 'package:soleoserp/models/api_response/registraion/registration_response.dart';
import 'package:soleoserp/repositories/repository.dart';

part 'authentication_events.dart';
part 'authentication_states.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationStates> {
  Repository userRepository = Repository.getInstance();
  BaseBloc baseBloc;

  AuthenticationBloc(this.baseBloc) : super(AuthenticationInitialState());

  @override
  Stream<AuthenticationStates> mapEventToState(
      AuthenticationEvent event) async* {
    /// sets state based on events
    if (event is RegistrationRequestEvent) {
      yield* _mapRegistrationRequestEventToState(event);
    }
    if (event is LoginRequestEvent) {
      yield* _mapLoginRequestEventToState(event);
    }
  }

  ///event functions to states implementation

  Stream<AuthenticationStates> _mapRegistrationRequestEventToState(
      RegistrationRequestEvent event) async* {
    try {
      print("uuuuuuu");
      baseBloc.emit(ShowProgressIndicatorState(true));

      //call your api as follows
      RegistrationResponse companyDetailsResponse =
          await userRepository.getRegistrationDetailsApi(event.request);
      yield RegistrationResponseState(companyDetailsResponse);
    } catch (error, stacktrace) {
      baseBloc.emit(ApiCallFailureState(error));
      print(stacktrace);
    } finally {
      baseBloc.emit(ShowProgressIndicatorState(false));
    }
  }

  Stream<AuthenticationStates> _mapLoginRequestEventToState(
      LoginRequestEvent event) async* {
    try {
      print("uuuuuuu");
      baseBloc.emit(ShowProgressIndicatorState(true));

      //call your api as follows
      LoginResponse companyDetailsResponse =
          await userRepository.getLoginDetailsApi(event.request);
      yield LoginResponseState(companyDetailsResponse);
    } catch (error, stacktrace) {
      baseBloc.emit(ApiCallFailureState(error));
      print(stacktrace);
    } finally {
      baseBloc.emit(ShowProgressIndicatorState(false));
    }
  }
}
