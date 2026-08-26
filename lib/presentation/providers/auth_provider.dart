import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';
import '../../core/network/api_error_handler.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserProfile? _profile;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String _errorMessage = '';
  bool _needsVerification = false;
  String _pendingEmail = '';

  // Getters
  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String get errorMessage => _errorMessage;
  int get userId => _profile?.userId ?? 0;
  bool get needsVerification => _needsVerification;
  String get pendingEmail => _pendingEmail;

  /// Cek status login saat aplikasi pertama kali dibuka
  Future<void> checkAuthStatus() async {
    try {
      _isLoading = true;
      notifyListeners();

      _profile = await _authService.getProfile();
      _isLoggedIn = _profile != null;
    } catch (_) {
      _profile = null;
      _isLoggedIn = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login
  /// Returns a map with 'success', 'message', 'needsVerification', 'email'
  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = '';
    _needsVerification = false;
    notifyListeners();

    try {
      final result = await _authService.login(email: email, password: password);

      if (result['success'] == true) {
        // Ambil profil setelah login berhasil
        _profile = await _authService.getProfile();
        _isLoggedIn = _profile != null;
        _errorMessage = '';
        _isLoading = false;
        notifyListeners();
        return {
          'success': true,
          'message': result['message'] ?? 'Login berhasil!',
          'needsVerification': false,
        };
      } else {
        _errorMessage = result['message'] ?? 'Login gagal. Silakan coba lagi.';
        _isLoading = false;

        if (result['needsVerification'] == true) {
          _needsVerification = true;
          _pendingEmail = result['email'] ?? email;
          notifyListeners();
          return {
            'success': false,
            'message': _errorMessage,
            'needsVerification': true,
            'email': _pendingEmail,
          };
        }

        notifyListeners();
        return {
          'success': false,
          'message': _errorMessage,
          'needsVerification': false,
        };
      }
    } catch (e) {
      _errorMessage = ApiErrorHandler.extractMessage(e, fallbackMessage: 'Email atau password salah.');
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': _errorMessage,
        'needsVerification': false,
      };
    }
  }

  /// Register
  /// Returns map with 'success', 'message', 'email'
  Future<Map<String, dynamic>> register(
      String username, String email, String password, String confirmPassword) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await _authService.register(
        username: username,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );

      _isLoading = false;

      if (result['success'] == true) {
        _pendingEmail = email;
        _errorMessage = '';
        notifyListeners();
        return {
          'success': true,
          'message': result['message'] ?? 'Registrasi berhasil! Silakan cek email Anda.',
          'email': email,
        };
      } else {
        _errorMessage = result['message'] ?? 'Registrasi gagal.';
        notifyListeners();
        return {
          'success': false,
          'message': _errorMessage,
        };
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = ApiErrorHandler.extractMessage(e, fallbackMessage: 'Registrasi gagal. Silakan coba lagi.');
      notifyListeners();
      return {
        'success': false,
        'message': _errorMessage,
      };
    }
  }

  /// Verify email dengan token
  Future<Map<String, dynamic>> verifyEmail(String token) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await _authService.verifyEmail(token);
      _isLoading = false;

      if (result['success'] != true) {
        _errorMessage = result['message'] ?? 'Verifikasi gagal.';
      }
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      _errorMessage = ApiErrorHandler.extractMessage(e, fallbackMessage: 'Gagal memverifikasi email.');
      notifyListeners();
      return {
        'success': false,
        'message': _errorMessage,
      };
    }
  }

  /// Resend verification email
  Future<Map<String, dynamic>> resendVerification(String email) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await _authService.resendVerification(email);
      _isLoading = false;

      if (result['success'] != true) {
        _errorMessage = result['message'] ?? 'Gagal mengirim ulang email verifikasi.';
      }
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      _errorMessage = ApiErrorHandler.extractMessage(e, fallbackMessage: 'Gagal mengirim ulang email verifikasi.');
      notifyListeners();
      return {
        'success': false,
        'message': _errorMessage,
      };
    }
  }

  /// Set pending email (for navigation from login to resend)
  void setPendingEmail(String email) {
    _pendingEmail = email;
    _needsVerification = true;
    notifyListeners();
  }

  /// Request change password — kirim email berisi link reset
  Future<Map<String, dynamic>> requestChangePassword(String email) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await _authService.requestChangePassword(email);
      _isLoading = false;

      if (result['success'] != true) {
        _errorMessage = result['message'] ?? 'Gagal mengirim email reset password.';
      }
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      _errorMessage = ApiErrorHandler.extractMessage(e, fallbackMessage: 'Gagal mengirim email reset password.');
      notifyListeners();
      return {
        'success': false,
        'message': _errorMessage,
      };
    }
  }

  /// Change password — ganti password dengan token dari email
  Future<Map<String, dynamic>> changePassword(String token, String newPassword, String confirmPassword) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await _authService.changePassword(
        token: token,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      _isLoading = false;

      if (result['success'] != true) {
        _errorMessage = result['message'] ?? 'Gagal mengubah password.';
      }
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      _errorMessage = ApiErrorHandler.extractMessage(e, fallbackMessage: 'Gagal mengubah password.');
      notifyListeners();
      return {
        'success': false,
        'message': _errorMessage,
      };
    }
  }

  /// Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
    } finally {
      _profile = null;
      _isLoggedIn = false;
      _needsVerification = false;
      _pendingEmail = '';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Bersihkan error message
  void clearError() {
    _errorMessage = '';
    _needsVerification = false;
    notifyListeners();
  }
}
