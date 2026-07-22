import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/token_storage.dart';
import '../models/user.dart';

class AuthRepository {
  AuthRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final data = await _apiClient.post(
      '/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );

    return _persistAuthResponse(data);
  }

  Future<User> login({
    required String email,
    required String password,
  }) async {
    final data = await _apiClient.post(
      '/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    return _persistAuthResponse(data);
  }

  Future<User?> restoreSession() async {
    final token = await _tokenStorage.readToken();
    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final data = await _apiClient.get('/profile');
      final userJson =
          data['data'] as Map<String, dynamic>? ?? data;
      return User.fromJson(userJson);
    } on ApiException catch (error) {
      if (error.statusCode == 401) {
        await _tokenStorage.deleteToken();
        return null;
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.post('/logout');
    } finally {
      await _tokenStorage.deleteToken();
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _apiClient.delete('/profile');
    } finally {
      await _tokenStorage.deleteToken();
    }
  }

  Future<User> updateProfile({
    String? name,
    String? email,
    String? password,
    String? passwordConfirmation,
  }) async {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (password != null) {
      data['password'] = password;
      data['password_confirmation'] = passwordConfirmation;
    }

    final response = await _apiClient.put('/profile', data: data);
    final userJson =
        response['data'] as Map<String, dynamic>? ?? response;
    return User.fromJson(userJson);
  }

  Future<User> _persistAuthResponse(Map<String, dynamic> data) async {
    final token = data['token'];
    final userJson = data['user'];

    if (token is! String || token.isEmpty) {
      throw ApiException(message: 'Authentication token missing from server response.');
    }

    if (userJson is! Map<String, dynamic>) {
      throw ApiException(message: 'User data missing from server response.');
    }

    await _tokenStorage.saveToken(token);
    return User.fromJson(userJson);
  }
}
