import 'package:flutter/material.dart';

import '../../core/graphql/graphql_queries.dart';
import '../../core/models/user_model.dart';
import '../../core/services/graphql_service.dart';
import '../../core/services/storage_service.dart';

class AuthController extends ChangeNotifier {
  AuthController({
    required StorageService storageService,
    required GraphQLService graphqlService,
  })  : _storageService = storageService,
        _graphqlService = graphqlService;

  final StorageService _storageService;
  final GraphQLService _graphqlService;

  bool _isAuthenticated = false;
  bool _isLoading = false;
  UserModel? _currentUser;
  String? _errorMessage;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;

  Future<void> init() async {
    final token = _storageService.getToken();
    if (token != null && token.isNotEmpty) {
      await fetchProfile(silent: true);
    } else {
      _isAuthenticated = false;
      _currentUser = null;
      notifyListeners();
    }
  }

  Future<bool> fetchProfile({bool silent = false}) async {
    try {
      final result = await _graphqlService.query(GraphQLQueries.profileQuery);

      if (result.hasException || result.data?['profile'] == null) {
        if (!silent) {
          await logout();
        }
        return false;
      }

      final profileData = result.data!['profile'] as Map<String, dynamic>;
      _currentUser = UserModel.fromJson(profileData);
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (e) {
      if (!silent) {
        _errorMessage = 'Error al cargar perfil: $e';
        await logout();
      }
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final trimmedEmail = email.trim();
      final trimmedPassword = password.trim();

      if (trimmedEmail.isEmpty || trimmedPassword.isEmpty) {
        _errorMessage = 'Correo y contraseña son requeridos.';
        return false;
      }

      final result = await _graphqlService.mutate(
        GraphQLQueries.loginMutation,
        variables: {
          'email': trimmedEmail,
          'password': trimmedPassword,
          'type': 'email',
        },
      );

      if (result.hasException) {
        final graphqlErrors = result.exception?.graphqlErrors;
        if (graphqlErrors != null && graphqlErrors.isNotEmpty) {
          _errorMessage = graphqlErrors.first.message;
        } else {
          _errorMessage = 'Credenciales inválidas o error de red.';
        }
        return false;
      }

      final loginData = result.data?['login'] as Map<String, dynamic>?;
      if (loginData == null) {
        _errorMessage = 'Respuesta inesperada del servidor.';
        return false;
      }

      final token = loginData['token']?.toString();
      if (token == null || token.isEmpty) {
        _errorMessage = 'No se recibió un token válido.';
        return false;
      }

      await _graphqlService.updateToken(token);
      _currentUser = UserModel.fromJson(loginData);
      _isAuthenticated = true;

      // Attempt background profile update without dropping session on failure
      fetchProfile(silent: true);

      return true;
    } catch (e) {
      _errorMessage = 'Error inesperado: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _graphqlService.clearToken();
    _isAuthenticated = false;
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }
}
