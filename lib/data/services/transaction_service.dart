import 'package:dio/dio.dart';
import '../models/transaction_model.dart';
import '../models/summary_model.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_error_handler.dart';

class TransactionService {
  final Dio _dio = ApiClient().dio;

  /// POST /transaction — Catat transaksi baru
  Future<Map<String, dynamic>> createTransaction({
    required int userId,
    required int balanceId,
    required String type,
    required int amount,
    required String category,
    String description = '',
  }) async {
    try {
      final response = await _dio.post('/transaction', data: {
        'userID': userId,
        'balanceID': balanceId,
        'type': type,
        'amount': amount,
        'category': category,
        'description': description,
      });

      final isSuccess = response.data is Map ? (response.data['success'] ?? true) : true;
      final message = response.data is Map
          ? (response.data['messagge'] ?? response.data['message'] ?? 'Transaksi berhasil dicatat!')
          : 'Transaksi berhasil dicatat!';

      return {
        'success': isSuccess,
        'message': message,
        'data': (response.data is Map && response.data['data'] != null)
            ? Transaction.fromJson(response.data['data'])
            : null,
      };
    } catch (e) {
      final errorMessage = ApiErrorHandler.extractMessage(
        e,
        fallbackMessage: 'Gagal mencatat transaksi.',
      );
      return {
        'success': false,
        'message': errorMessage,
      };
    }
  }

  /// GET /transaction?page=&limit=&category=&type=&start_date=&end_date=
  /// Ambil transaksi milik user dengan filter & paginasi dari Backend Go
  Future<Map<String, dynamic>> getAllTransactions({
    int page = 1,
    int limit = 10,
    String? category,
    String? type,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }
      if (startDate != null && startDate.isNotEmpty) {
        queryParams['start_date'] = startDate;
      }
      if (endDate != null && endDate.isNotEmpty) {
        queryParams['end_date'] = endDate;
      }

      final response = await _dio.get('/transaction', queryParameters: queryParams);
      if (response.data is Map && response.data['success'] == true && response.data['data'] != null) {
        final resData = response.data['data'];
        List<Transaction> transactions = [];
        int currentPage = page;
        int totalPages = 1;
        int totalItems = 0;

        if (resData is Map<String, dynamic>) {
          final List rawList = resData['data'] ?? [];
          transactions = rawList.map((json) => Transaction.fromJson(json)).toList();
          currentPage = resData['page'] as int? ?? page;
          totalPages = resData['total_pages'] as int? ?? resData['totalPages'] as int? ?? 1;
          totalItems = resData['total_items'] as int? ?? resData['totalItems'] as int? ?? transactions.length;
        } else if (resData is List) {
          transactions = resData.map((json) => Transaction.fromJson(json)).toList();
          totalItems = transactions.length;
          totalPages = (totalItems / limit).ceil().clamp(1, 999999);
        }

        return {
          'success': true,
          'transactions': transactions,
          'page': currentPage,
          'totalPages': totalPages,
          'totalItems': totalItems,
        };
      }
      return {
        'success': false,
        'transactions': <Transaction>[],
        'page': 1,
        'totalPages': 1,
        'totalItems': 0,
      };
    } catch (_) {
      return {
        'success': false,
        'transactions': <Transaction>[],
        'page': 1,
        'totalPages': 1,
        'totalItems': 0,
      };
    }
  }

  /// GET /transaction/:id — Ambil detail satu transaksi
  Future<Transaction?> getTransactionById(int id) async {
    try {
      final response = await _dio.get('/transaction/$id');
      if (response.data is Map && response.data['success'] == true && response.data['data'] != null) {
        return Transaction.fromJson(response.data['data']);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// GET /transaction/summary?start_date=&end_date= — Ringkasan keuangan
  Future<Summary> getSummary({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await _dio.get('/transaction/summary', queryParameters: {
        'start_date': startDate,
        'end_date': endDate,
      });
      if (response.data is Map && response.data['success'] == true && response.data['data'] != null) {
        return Summary.fromJson(response.data['data']);
      }
      return Summary.empty();
    } catch (_) {
      return Summary.empty();
    }
  }

  /// PUT /transaction/:id — Update transaksi
  Future<Map<String, dynamic>> updateTransaction({
    required int id,
    required int userId,
    required int balanceId,
    required String type,
    required int amount,
    required String category,
    String description = '',
  }) async {
    try {
      final response = await _dio.put('/transaction/$id', data: {
        'userID': userId,
        'balanceID': balanceId,
        'type': type,
        'amount': amount,
        'category': category,
        'description': description,
      });

      final isSuccess = response.data is Map ? (response.data['success'] ?? true) : true;
      final message = response.data is Map
          ? (response.data['messagge'] ?? response.data['message'] ?? 'Transaksi berhasil diupdate!')
          : 'Transaksi berhasil diupdate!';

      return {
        'success': isSuccess,
        'message': message,
      };
    } catch (e) {
      final errorMessage = ApiErrorHandler.extractMessage(
        e,
        fallbackMessage: 'Gagal mengupdate transaksi.',
      );
      return {
        'success': false,
        'message': errorMessage,
      };
    }
  }

  /// DELETE /transaction/:id — Hapus transaksi
  Future<Map<String, dynamic>> deleteTransaction(int id) async {
    try {
      final response = await _dio.delete('/transaction/$id');

      final isSuccess = response.data is Map ? (response.data['success'] ?? true) : true;
      final message = response.data is Map
          ? (response.data['messagge'] ?? response.data['message'] ?? 'Transaksi berhasil dihapus!')
          : 'Transaksi berhasil dihapus!';

      return {
        'success': isSuccess,
        'message': message,
      };
    } catch (e) {
      final errorMessage = ApiErrorHandler.extractMessage(
        e,
        fallbackMessage: 'Gagal menghapus transaksi.',
      );
      return {
        'success': false,
        'message': errorMessage,
      };
    }
  }
}
