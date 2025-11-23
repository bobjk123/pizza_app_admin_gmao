import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

part 'sign_in_event.dart';
part 'sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final UserRepository _userRepository;

  SignInBloc(this._userRepository) : super(SignInInitial()) {
    on<SignInRequired>((event, emit) async {
      // Prevent re-entrancy: if a sign-in is already in progress, ignore
      // subsequent SignInRequired events until the current attempt finishes.
      if (state is SignInProcess) {
        log('SignInBloc: sign-in already in progress, ignoring duplicate request');
        return;
      }

      emit(SignInProcess());
      log('SignInBloc: attempting sign in for ${event.email}');
      try {
        await _userRepository.signIn(event.email, event.password);
        log('SignInBloc: sign in succeeded for ${event.email}');
        emit(SignInSuccess());
      } catch (e, st) {
        log('SignInBloc: sign in failed for ${event.email}: $e',
            stackTrace: st);
        emit(SignInFailure());
      }
    });

    on<SignOutRequired>((event, emit) async {
      await _userRepository.logOut();
      emit(SignOutSuccess());
    });
  }
}
