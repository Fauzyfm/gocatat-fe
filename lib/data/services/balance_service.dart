import 'package:dio/dio.dart';
import '../models/balance_model.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_error_handler.dart';

class BalanceService {
  final Dio _dio = ApiClient().dio;

  /// POST /balance — Buat dompet baru
  Future<Map<String, dynamic>> createBalance({
    required int userId,
    required String wallet,
    required String type,
  }) async {
    try {
      final response = await _dio.post('/balance', data: {
        'userID': userId,
        'wallet': wallet,
        'type': type,
      });

      final isSuccess = response.data is Map ? (response.data['success'] ?? true) : true;
      final message = response.data is Map
          ? (response.data['messagge'] ?? response.data['message'] ?? 'Dompet berhasil ditambahkan!')
          : 'Dompet berhasil ditambahkan!';

      return {
        'success': isSuccess,
        'message': message,
        'data': (response.data is Map && response.data['data'] != null)
            ? Balance.fromJson(response.data['data'])
            : null,
      };
    } catch (e) {
      final errorMessage = ApiErrorHandler.extractMessage(
        e,
        fallbackMessage: 'Gagal membuat dompet.',
      );
      return {
        'success': false,
        'message': errorMessage,
      };
    }
  }

  /// GET /balance — Ambil semua dompet milik user
  Future<List<Balance>> getAllBalances() async {
    try {
      final response = await _dio.get('/balance');
      if (response.data is Map && response.data['success'] == true && response.data['data'] != null) {
        final List data = response.data['data'];
        return data.map((json) => Balance.fromJson(json)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// GET /balance/:id — Ambil detail satu dompet
  Future<Balance?> getBalanceById(int id) async {
    try {
      final response = await _dio.get('/balance/$id');
      if (response.data is Map && response.data['success'] == true && response.data['data'] != null) {
        return Balance.fromJson(response.data['data']);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// PUT /balance/:id — Update dompet
  Future<Map<String, dynamic>> updateBalance({
    required int id,
    required int userId,
    required String wallet,
    required String type,
  }) async {
    try {
      final response = await _dio.put('/balance/$id', data: {
        'userID': userId,
        'wallet': wallet,
        'type': type,
      });

      final isSuccess = response.data is Map ? (response.data['success'] ?? true) : true;
      final message = response.data is Map
          ? (response.data['messagge'] ?? response.data['message'] ?? 'Dompet berhasil diupdate!')
          : 'Dompet berhasil diupdate!';

      return {
        'success': isSuccess,
        'message': message,
      };
    } catch (e) {
      final errorMessage = ApiErrorHandler.extractMessage(
        e,
        fallbackMessage: 'Gagal mengupdate dompet.',
      );
      return {
        'success': false,
        'message': errorMessage,
      };
    }
  }

  /// DELETE /balance/:id — Hapus dompet
  Future<Map<String, dynamic>> deleteBalance(int id) async {
    try {
      final response = await _dio.delete('/balance/$id');

      final isSuccess = response.data is Map ? (response.data['success'] ?? true) : true;
      final message = response.data is Map
          ? (response.data['messagge'] ?? response.data['message'] ?? 'Dompet berhasil dihapus!')
          : 'Dompet berhasil dihapus!';

      return {
        'success': isSuccess,
        'message': message,
      };
    } catch (e) {
      final errorMessage = ApiErrorHandler.extractMessage(
        e,
        fallbackMessage: 'Gagal menghapus dompet. Pastikan tidak ada transaksi terkait.',
      );
      return {
        'success': false,
        'message': errorMessage,
      };
    }
  }
}
