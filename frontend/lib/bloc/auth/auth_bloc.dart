import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';

// Events
abstract class AuthEvent extends Equatable {
  @override List<Object?> get props => [];
}

class SendSmsEvent extends AuthEvent {
  final String phone;
  SendSmsEvent(this.phone);
  @override List<Object?> get props => [phone];
}

class LoginSmsEvent extends AuthEvent {
  final String phone, code;
  LoginSmsEvent(this.phone, this.code);
  @override List<Object?> get props => [phone, code];
}

class LoginPasswordEvent extends AuthEvent {
  final String phone, password;
  LoginPasswordEvent(this.phone, this.password);
  @override List<Object?> get props => [phone, password];
}

class LoginPinEvent extends AuthEvent {
  final String pin;
  LoginPinEvent(this.pin);
  @override List<Object?> get props => [pin];
}

class RegisterSmsEvent extends AuthEvent {
  final String phone, code;
  RegisterSmsEvent(this.phone, this.code);
}

class RegisterPasswordEvent extends AuthEvent {
  final String phone, password;
  RegisterPasswordEvent(this.phone, this.password);
}

class SetPinEvent extends AuthEvent {
  final String pin, pinConfirm;
  SetPinEvent(this.pin, this.pinConfirm);
}

class LogoutEvent extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  @override List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
  @override List<Object?> get props => [message];
}

class AuthSuccess extends AuthState {
  final bool requirePinSetup;
  AuthSuccess({this.requirePinSetup = false});
  @override List<Object?> get props => [requirePinSetup];
}

class SmsSent extends AuthState {
  final String phone;
  SmsSent(this.phone);
}

class AuthLoggedOut extends AuthState {}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final StorageService _storage;

  AuthBloc(this._authService, this._storage) : super(AuthInitial()) {
    on<SendSmsEvent>(_onSendSms);
    on<LoginSmsEvent>(_onLoginSms);
    on<LoginPasswordEvent>(_onLoginPassword);
    on<LoginPinEvent>(_onLoginPin);
    on<RegisterPasswordEvent>(_onRegisterPassword);
    on<SetPinEvent>(_onSetPin);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onSendSms(SendSmsEvent e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      emit(SmsSent(e.phone));
    } catch (ex) {
      emit(AuthError(ex.toString()));
    }
  }

  Future<void> _onLoginSms(LoginSmsEvent e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authService.loginWithSms(e.phone, e.code);
      emit(AuthSuccess(requirePinSetup: !_storage.hasPinSet()));
    } catch (ex) {
      emit(AuthError('Неверный код'));
    }
  }

  Future<void> _onLoginPassword(LoginPasswordEvent e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authService.loginWithPassword(e.phone, e.password);
      emit(AuthSuccess(requirePinSetup: !_storage.hasPinSet()));
    } catch (ex) {
      emit(AuthError('Неверный телефон или пароль'));
    }
  }

  Future<void> _onLoginPin(LoginPinEvent e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authService.loginWithPin(e.pin);
      emit(AuthSuccess());
    } catch (ex) {
      emit(AuthError('Неверный PIN'));
    }
  }

  Future<void> _onRegisterPassword(RegisterPasswordEvent e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authService.registerWithPassword(e.phone, e.password);
      emit(AuthSuccess(requirePinSetup: true));
    } catch (ex) {
      emit(AuthError('Ошибка регистрации'));
    }
  }

  Future<void> _onSetPin(SetPinEvent e, Emitter<AuthState> emit) async {
    try {
      await _authService.setPin(e.pin, e.pinConfirm);
    } catch (_) {}
  }

  Future<void> _onLogout(LogoutEvent e, Emitter<AuthState> emit) async {
    await _authService.logout();
    emit(AuthLoggedOut());
  }
}
