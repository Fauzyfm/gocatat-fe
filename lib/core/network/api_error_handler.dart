import 'package:dio/dio.dart';

/// Helper kelas untuk mengekstrak dan memformat pesan error dari Backend Go Fiber maupun jaringan
class ApiErrorHandler {
  /// Ekstrak pesan error dari objek error apa pun (DioException, Exception, String, dll)
  static String extractMessage(dynamic error, {String fallbackMessage = 'Terjadi kesalahan. Silakan coba lagi.'}) {
    if (error == null) return fallbackMessage;

    if (error is DioException) {
      return _handleDioException(error, fallbackMessage);
    }

    if (error is String) {
      if (error.trim().isNotEmpty) return error.trim();
      return fallbackMessage;
    }

    if (error is Exception) {
      final msg = error.toString().replaceFirst('Exception: ', '').trim();
      if (msg.isNotEmpty && !msg.contains('Instance of')) return msg;
    }

    return fallbackMessage;
  }

  /// Penanganan khusus untuk DioException
  static String _handleDioException(DioException error, String fallbackMessage) {
    // 1. Jika ada respon dari server
    if (error.response != null) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;

      // Jika body berupa JSON Map
      if (data is Map) {
        // Backend Go menggunakan "messagge" atau "message"
        final rawMsg = data['messagge'] ??
            data['message'] ??
            data['error'] ??
            data['msg'] ??
            data['detail'];

        if (rawMsg != null && rawMsg.toString().trim().isNotEmpty) {
          return rawMsg.toString().trim();
        }
      }

      // Jika body berupa String polos (misal dari middleware fiber limiter 429 atau HTML server error)
      if (data is String && data.trim().isNotEmpty) {
        final text = data.trim();
        // Cek jika teks bukan halaman HTML lengkap
        if (!text.toLowerCase().contains('<!doctype html') && !text.toLowerCase().contains('<html')) {
          if (text.toLowerCase().contains('too many requests')) {
            return 'Terlalu banyak permintaan. Silakan coba beberapa saat lagi.';
          }
          return text;
        }
      }

      // Fallback berdasarkan HTTP Status Code jika tidak ada pesan di body
      switch (statusCode) {
        case 400:
          return 'Permintaan tidak valid atau data yang dikirim tidak sesuai.';
        case 401:
          return 'Email atau password salah, atau sesi login telah berakhir.';
        case 403:
          return 'Anda tidak memiliki izin untuk mengakses fitur ini.';
        case 404:
          return 'Layanan atau data yang dicari tidak ditemukan (404).';
        case 409:
          return 'Data sudah terdaftar atau terjadi konflik data.';
        case 422:
          return 'Format data tidak valid.';
        case 429:
          return 'Terlalu banyak percobaan. Harap tunggu beberapa saat.';
        case 500:
          return 'Terjadi kesalahan pada server backend. Silakan coba lagi nanti.';
        case 502:
        case 503:
        case 504:
          return 'Server backend sedang tidak dapat diakses atau sedang dalam pemeliharaan.';
        default:
          return 'Gagal memproses permintaan (Status: $statusCode).';
      }
    }

    // 2. Jika tidak ada respon (koneksi putus, timeout, dsb)
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Waktu koneksi habis. Silakan periksa jaringan internet Anda.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Pastikan backend aktif dan koneksi internet stabil.';
      case DioExceptionType.cancel:
        return 'Permintaan dibatalkan.';
      case DioExceptionType.badCertificate:
        return 'Sertifikat keamanan server tidak valid.';
      case DioExceptionType.unknown:
      default:
        if (error.message != null && error.message!.isNotEmpty && !error.message!.contains('DioException')) {
          return error.message!;
        }
        return 'Koneksi ke server gagal. Silakan periksa jaringan Anda.';
    }
  }

  /// Cek apakah pesan error menandakan akun belum diverifikasi
  static bool isUnverifiedError(String message) {
    final lower = message.toLowerCase();
    return lower.contains('verifikasi') ||
        lower.contains('verif') ||
        lower.contains('verify') ||
        lower.contains('belum diverifikasi') ||
        lower.contains('belum terverifikasi') ||
        lower.contains('not verified');
  }
}
