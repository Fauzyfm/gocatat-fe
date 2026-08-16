import 'package:dio/dio.dart';
import '../models/balance_model.dart';
import '../../core/network/api_client.dart';

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
      return {
        'success': response.data['success'] ?? false,
        'message': response.data['messagge'] ?? response.data['message'] ?? '',
        'data': response.data['data'] != null
            ? Balance.fromJson(response.data['data'])
            : null,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ??
            e.response?.data?['messagge'] ??
            'Gagal membuat dompet.',
      };
    }
  }

  /// GET /balance — Ambil semua dompet milik user
  Future<List<Balance>> getAllBalances() async {
    try {
      final response = await _dio.get('/balance');
      if (response.data['success'] == true && response.data['data'] != null) {
        final List data = response.data['data'];
        return data.map((json) => Balance.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// GET /balance/:id — Ambil detail satu dompet
  Future<Balance?> getBalanceById(int id) async {
    try {
      final response = await _dio.get('/balance/$id');
      if (response.data['success'] == true && response.data['data'] != null) {
        return Balance.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
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
      return {
        'success': response.data['success'] ?? false,
        'message': response.data['messagge'] ?? response.data['message'] ?? 'Dompet berhasil diupdate!',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ??
            e.response?.data?['messagge'] ??
            'Gagal mengupdate dompet.',
      };
    }
  }

  /// DELETE /balance/:id — Hapus dompet
  Future<Map<String, dynamic>> deleteBalance(int id) async {
    try {
      final response = await _dio.delete('/balance/$id');
      return {
        'success': response.data['success'] ?? false,
        'message': response.data['messagge'] ?? response.data['message'] ?? 'Dompet berhasil dihapus!',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ??
            e.response?.data?['messagge'] ??
            'Gagal menghapus dompet. Pastikan tidak ada transaksi yang terkait.',
      };
    }
  }
}
