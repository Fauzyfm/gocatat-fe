import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserProfile? _profile;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String _errorMessage = '';

  // Getters
  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String get errorMessage => _errorMessage;
  int get userId => _profile?.userId ?? 0;

  /// Cek status login saat aplikasi pertama kali dibuka
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    _profile = await _authService.getProfile();
    _isLoggedIn = _profile != null;

    _isLoading = false;
    notifyListeners();
  }

  /// Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final result = await _authService.login(email: email, password: password);

    if (result['success'] == true) {
      // Setelah login berhasil, langsung ambil profil user
      _profile = await _authService.getProfile();
      _isLoggedIn = _profile != null;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'] ?? 'Login gagal';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Register
  Future<bool> register(String username, String email, String password, String confirmPassword) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final result = await _authService.register(
      username: username,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );

    _isLoading = false;

    if (result['success'] == true) {
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'] ?? 'Registrasi gagal';
      notifyListeners();
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authService.logout();
    _profile = null;
    _isLoggedIn = false;

    _isLoading = false;
    notifyListeners();
  }

  /// Bersihkan error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
