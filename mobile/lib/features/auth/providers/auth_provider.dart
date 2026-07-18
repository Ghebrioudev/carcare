import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../data/auth_repository.dart';
import '../models/user.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authRepository);

  final AuthRepository _authRepository;

  AuthStatus status = AuthStatus.unknown;
  User? user;
  bool isLoading = false;
  String? errorMessage;

  Future<void> initialize() async {
    isLoading = true;
    notifyListeners();

    try {
      user = await _authRepository.restoreSession();
      status =
          user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    } on ApiException catch (error) {
      status = AuthStatus.unauthenticated;
      errorMessage = error.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    return _authenticate(() {
      return _authRepository.login(email: email, password: password);
    });
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    return _authenticate(() {
      return _authRepository.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
    });
  }

  Future<bool> _authenticate(Future<User> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      user = await action();
      status = AuthStatus.authenticated;
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
      status = AuthStatus.unauthenticated;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    isLoading = true;
    notifyListeners();

    try {
      await _authRepository.logout();
    } finally {
      user = null;
      status = AuthStatus.unauthenticated;
      isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
