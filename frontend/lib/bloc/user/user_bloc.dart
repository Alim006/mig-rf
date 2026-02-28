import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../services/api_service.dart';

// Events
abstract class UserEvent extends Equatable {
  @override List<Object?> get props => [];
}
class LoadProfileEvent extends UserEvent {}
class UpdateProfileEvent extends UserEvent {
  final Map<String, dynamic> data;
  UpdateProfileEvent(this.data);
}
class SetVisitTypeEvent extends UserEvent {
  final String type;
  SetVisitTypeEvent(this.type);
}

// States
abstract class UserState extends Equatable {
  @override List<Object?> get props => [];
}
class UserInitial extends UserState {}
class UserLoading extends UserState {}
class UserLoaded extends UserState {
  final Map<String, dynamic> profile;
  UserLoaded(this.profile);
  @override List<Object?> get props => [profile];
}
class UserError extends UserState {
  final String message;
  UserError(this.message);
}

// BLoC
class UserBloc extends Bloc<UserEvent, UserState> {
  final ApiService _api;

  UserBloc(this._api) : super(UserInitial()) {
    on<LoadProfileEvent>(_onLoad);
    on<UpdateProfileEvent>(_onUpdate);
    on<SetVisitTypeEvent>(_onSetVisitType);
  }

  Future<void> _onLoad(LoadProfileEvent e, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final profile = await _api.getProfile();
      emit(UserLoaded(profile));
    } catch (ex) {
      emit(UserError(ex.toString()));
    }
  }

  Future<void> _onUpdate(UpdateProfileEvent e, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final profile = await _api.updateProfile(e.data);
      emit(UserLoaded(profile));
    } catch (ex) {
      emit(UserError(ex.toString()));
    }
  }

  Future<void> _onSetVisitType(SetVisitTypeEvent e, Emitter<UserState> emit) async {
    try {
      await _api.setVisitType(e.type);
      add(LoadProfileEvent());
    } catch (ex) {
      emit(UserError(ex.toString()));
    }
  }
}
