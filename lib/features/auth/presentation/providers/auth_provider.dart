import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserEntity? user;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get isAdmin => user?.isAdmin ?? false;

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? error,
  }) =>
      AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        error: error,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState()) {
    _init();
  }

  void _init() {
    _repository.authStateChanges.listen((user) {
      if (user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    });
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    final result = await _repository.signIn(email: email, password: password);
    return result.fold(
      (failure) {
        state = AuthState(
            status: AuthStatus.unauthenticated, error: failure.message);
        return false;
      },
      (user) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
        return true;
      },
    );
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String? city,
    String? address,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    final result = await _repository.signUp(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
      city: city,
      address: address,
    );
    return result.fold(
      (failure) {
        state = AuthState(
            status: AuthStatus.unauthenticated, error: failure.message);
        return false;
      },
      (user) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
        return true;
      },
    );
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<bool> resetPassword(String email) async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await _repository.resetPassword(email: email);
    return result.fold(
      (failure) {
        state = state.copyWith(
            status: AuthStatus.unauthenticated, error: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return true;
      },
    );
  }

  Future<bool> updateProfile({
    String? fullName,
    String? phone,
    String? city,
    String? address,
    String? avatarUrl,
  }) async {
    final result = await _repository.updateProfile(
      fullName: fullName,
      phone: phone,
      city: city,
      address: address,
      avatarUrl: avatarUrl,
    );
    return result.fold(
      (failure) => false,
      (user) {
        state = state.copyWith(user: user);
        return true;
      },
    );
  }

  /// Refresh user profile from Supabase (e.g. after an admin update).
  Future<void> refreshUser() async {
    final result = await _repository.getCurrentUser();
    result.fold((_) {}, (user) => state = state.copyWith(user: user));
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return GetIt.instance<AuthRepository>();
});

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

final currentUserProvider = Provider<UserEntity?>((ref) {
  return ref.watch(authProvider).user;
});

final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAdmin;
});
