import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../../core/network/api_client.dart';

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
      return {
        'success': response.data['success'] ?? false,
        'message': response.data['messagge'] ?? response.data['message'] ?? '',
        'data': response.data['data'] != null
            ? RegisterResponse.fromJson(response.data['data'])
            : null,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ??
            e.response?.data?['messagge'] ??
            'Terjadi kesalahan saat registrasi.',
      };
    }
  }

  /// POST /auth/login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return {
        'success': response.data['success'] ?? false,
        'message': response.data['messagge'] ?? response.data['message'] ?? '',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ??
            e.response?.data?['messagge'] ??
            'Email atau password salah.',
      };
    }
  }

  /// POST /auth/logout
  Future<bool> logout() async {
    try {
      await _dio.post('/auth/logout');
      await ApiClient().clearCookies();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// GET /profile
  Future<UserProfile?> getProfile() async {
    try {
      final response = await _dio.get('/profile');
      if (response.data['success'] == true && response.data['data'] != null) {
        return UserProfile.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
