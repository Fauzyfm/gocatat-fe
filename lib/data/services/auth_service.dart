import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_error_handler.dart';

class AuthService {
  final Dio _dio = ApiClient().dio;

  /// POST /auth/register
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'username': username,
        'email': email,
        'password': password,
        'confirm_password': confirmPassword,
        'role': 'user',
      });

      final isSuccess = response.data is Map ? (response.data['success'] ?? true) : true;
      final message = response.data is Map
          ? (response.data['messagge'] ?? response.data['message'] ?? 'Registrasi berhasil!')
          : 'Registrasi berhasil!';

      return {
        'success': isSuccess,
        'message': message,
        'data': (response.data is Map && response.data['data'] != null)
            ? RegisterResponse.fromJson(response.data['data'])
            : null,
      };
    } catch (e) {
      final errorMessage = ApiErrorHandler.extractMessage(
        e,
        fallbackMessage: 'Terjadi kesalahan saat registrasi.',
      );
      return {
        'success': false,
        'message': errorMessage,
      };
    }
  }

  /// POST /auth/login
  /// Returns map with 'success', 'message', 'needsVerification', 'email'
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final isSuccess = response.data is Map ? (response.data['success'] ?? true) : true;
      final message = response.data is Map
          ? (response.data['messagge'] ?? response.data['message'] ?? 'Login berhasil!')
          : 'Login berhasil!';

      return {
        'success': isSuccess,
        'message': message,
        'needsVerification': false,
        'email': email,
      };
    } catch (e) {
      final errorMessage = ApiErrorHandler.extractMessage(
        e,
        fallbackMessage: 'Email atau password salah.',
      );
      final isUnverified = ApiErrorHandler.isUnverifiedError(errorMessage);

      return {
        'success': false,
        'message': errorMessage,
        'needsVerification': isUnverified,
        'email': email,
      };
    }
  }

  /// POST /auth/logout
  Future<bool> logout() async {
    try {
      await _dio.post('/auth/logout');
      await ApiClient().clearCookies();
      return true;
    } catch (_) {
      // Bersihkan cookie lokal meskipun request ke server gagal
      try {
        await ApiClient().clearCookies();
      } catch (_) {}
      return false;
    }
  }

  /// GET /profile
  Future<UserProfile?> getProfile() async {
    try {
      final response = await _dio.get('/profile');
      if (response.data is Map && response.data['success'] == true && response.data['data'] != null) {
        return UserProfile.fromJson(response.data['data']);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// GET /auth/verify?token=xxx
  Future<Map<String, dynamic>> verifyEmail(String token) async {
    try {
      final response = await _dio.get('/auth/verify', queryParameters: {
        'token': token,
      });

      final isSuccess = response.data is Map ? (response.data['success'] ?? true) : true;
      final message = response.data is Map
          ? (response.data['messagge'] ?? response.data['message'] ?? 'Email berhasil diverifikasi!')
          : 'Email berhasil diverifikasi!';

      return {
        'success': isSuccess,
        'message': message,
      };
    } catch (e) {
      final errorMessage = ApiErrorHandler.extractMessage(
        e,
        fallbackMessage: 'Gagal memverifikasi email. Token mungkin sudah kadaluarsa.',
      );
      return {
        'success': false,
        'message': errorMessage,
      };
    }
  }

  /// POST /auth/resend-verification
  Future<Map<String, dynamic>> resendVerification(String email) async {
    try {
      final response = await _dio.post('/auth/resend-verification', data: {
        'email': email,
      });

      final isSuccess = response.data is Map ? (response.data['success'] ?? true) : true;
      final message = response.data is Map
          ? (response.data['messagge'] ?? response.data['message'] ?? 'Email verifikasi berhasil dikirim ulang!')
          : 'Email verifikasi berhasil dikirim ulang!';

      return {
        'success': isSuccess,
        'message': message,
      };
    } catch (e) {
      final errorMessage = ApiErrorHandler.extractMessage(
        e,
        fallbackMessage: 'Gagal mengirim ulang email verifikasi.',
      );
      return {
        'success': false,
        'message': errorMessage,
      };
    }
  }

  /// POST /auth/verification-change-password
  /// Kirim email berisi link reset password
  Future<Map<String, dynamic>> requestChangePassword(String email) async {
    try {
      final response = await _dio.post('/auth/verification-change-password', data: {
        'email': email,
      });

      final isSuccess = response.data is Map ? (response.data['success'] ?? true) : true;
      final message = response.data is Map
          ? (response.data['messagge'] ?? response.data['message'] ?? 'Silakan cek email Anda untuk melakukan perubahan password.')
          : 'Silakan cek email Anda untuk melakukan perubahan password.';

      return {
        'success': isSuccess,
        'message': message,
      };
    } catch (e) {
      final errorMessage = ApiErrorHandler.extractMessage(
        e,
        fallbackMessage: 'Gagal mengirim email reset password.',
      );
      return {
        'success': false,
        'message': errorMessage,
      };
    }
  }

  /// POST /auth/change-password
  /// Ganti password dengan token dari email
  Future<Map<String, dynamic>> changePassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _dio.post('/auth/change-password', data: {
        'token': token,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      });

      final isSuccess = response.data is Map ? (response.data['success'] ?? true) : true;
      final message = response.data is Map
          ? (response.data['messagge'] ?? response.data['message'] ?? 'Password berhasil diubah!')
          : 'Password berhasil diubah!';

      return {
        'success': isSuccess,
        'message': message,
      };
    } catch (e) {
      final errorMessage = ApiErrorHandler.extractMessage(
        e,
        fallbackMessage: 'Gagal mengubah password.',
      );
      return {
        'success': false,
        'message': errorMessage,
      };
    }
  }
}
