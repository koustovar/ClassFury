import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:classfury/features/auth/domain/entities/user_entity.dart';
import 'package:classfury/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:classfury/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:classfury/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:classfury/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:classfury/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:classfury/features/auth/domain/usecases/save_student_details_usecase.dart';
import 'package:classfury/features/auth/domain/usecases/has_student_details_usecase.dart';
import 'package:classfury/features/auth/domain/usecases/save_teacher_details_usecase.dart';
import 'package:classfury/features/auth/domain/usecases/has_teacher_details_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

export 'auth_event.dart';
export 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignUpUseCase _signUpUseCase;
  final SignInUseCase _signInUseCase;
  final SignOutUseCase _signOutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final SaveStudentDetailsUseCase _saveStudentDetailsUseCase;
  final HasStudentDetailsUseCase _hasStudentDetailsUseCase;
  final SaveTeacherDetailsUseCase _saveTeacherDetailsUseCase;
  final HasTeacherDetailsUseCase _hasTeacherDetailsUseCase;

  AuthBloc({
    required SignUpUseCase signUpUseCase,
    required SignInUseCase signInUseCase,
    required SignOutUseCase signOutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required SaveStudentDetailsUseCase saveStudentDetailsUseCase,
    required HasStudentDetailsUseCase hasStudentDetailsUseCase,
    required SaveTeacherDetailsUseCase saveTeacherDetailsUseCase,
    required HasTeacherDetailsUseCase hasTeacherDetailsUseCase,
  })  : _signUpUseCase = signUpUseCase,
        _signInUseCase = signInUseCase,
        _signOutUseCase = signOutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        _saveStudentDetailsUseCase = saveStudentDetailsUseCase,
        _hasStudentDetailsUseCase = hasStudentDetailsUseCase,
        _saveTeacherDetailsUseCase = saveTeacherDetailsUseCase,
        _hasTeacherDetailsUseCase = hasTeacherDetailsUseCase,
        super(AuthInitial()) {
    on<SignUpRequested>(_onSignUp);
    on<SignInRequested>(_onSignIn);
    on<SignOutRequested>(_onSignOut);
    on<AuthCheckRequested>(_onAuthCheck);
    on<UpdateProfileRequested>(_onUpdateProfile);
    on<SaveStudentDetailsRequested>(_onSaveStudentDetails);
    on<CheckStudentDetailsRequested>(_onCheckStudentDetails);
    on<SaveTeacherDetailsRequested>(_onSaveTeacherDetails);
  }

  Future<void> _onSignUp(SignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _signUpUseCase(SignUpParams(
      email: event.email,
      password: event.password,
      name: event.name,
      phoneNumber: event.phoneNumber,
      role: event.role,
    ));
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) {
        if (user.role == 'teacher') {
          emit(AuthTeacherNeedsDetails(user));
        } else {
          emit(AuthAuthenticated(user));
        }
      },
    );
  }

  Future<void> _onSignIn(SignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _signInUseCase(SignInParams(
      email: event.email,
      password: event.password,
    ));
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) async {
        if (user.role == 'student') {
          final hasDetailsResult = await _hasStudentDetailsUseCase(user.uid);
          hasDetailsResult.fold(
            (failure) => emit(AuthStudentNeedsDetails(
                user)), // If error, assume needs details
            (hasDetails) {
              if (hasDetails) {
                emit(AuthAuthenticated(user));
              } else {
                emit(AuthStudentNeedsDetails(user));
              }
            },
          );
        } else {
          emit(AuthAuthenticated(user));
        }
      },
    );
  }

  Future<void> _onSignOut(
      SignOutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _signOutUseCase();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  Future<void> _onAuthCheck(
      AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _getCurrentUserUseCase();
    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (user) {
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> _onUpdateProfile(
      UpdateProfileRequested event, Emitter<AuthState> emit) async {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      emit(AuthLoading());
      final result = await _updateProfileUseCase(UpdateProfileParams(
        uid: currentState.user.uid,
        name: event.name,
        photoUrl: event.photoUrl,
      ));

      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (_) {
          final updatedUser = UserEntity(
            uid: currentState.user.uid,
            name: event.name ?? currentState.user.name,
            email: currentState.user.email,
            phoneNumber: currentState.user.phoneNumber,
            role: currentState.user.role,
            photoUrl: event.photoUrl ?? currentState.user.photoUrl,
            createdAt: currentState.user.createdAt,
            isPremium: currentState.user.isPremium,
            isEmailVerified: currentState.user.isEmailVerified,
          );
          emit(AuthAuthenticated(updatedUser));
        },
      );
    }
  }

  Future<void> _onSaveStudentDetails(
      SaveStudentDetailsRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _saveStudentDetailsUseCase(SaveStudentDetailsParams(
      uid: event.uid,
      studentName: event.studentName,
      guardianName: event.guardianName,
      studentPhone: event.studentPhone,
      className: event.className,
      schoolName: event.schoolName,
      board: event.board,
    ));
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthSuccess('Student details saved successfully')),
    );
  }

  Future<void> _onSaveTeacherDetails(
      SaveTeacherDetailsRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _saveTeacherDetailsUseCase(SaveTeacherDetailsParams(
      uid: event.uid,
      name: event.name,
      phoneNumber: event.phoneNumber,
      subject: event.subject,
      qualification: event.qualification,
      tuitionType: event.tuitionType,
      description: event.description,
      profilePictureUrl: event.profilePictureUrl,
    ));
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthSuccess('Teacher details saved successfully')),
    );
  }
}
