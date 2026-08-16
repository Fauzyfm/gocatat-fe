import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  /// Format angka menjadi format Rupiah (contoh: Rp 5.250.000)
  static String format(int amount) {
    return _formatter.format(amount);
  }

  /// Format angka dengan tanda +/- di depan
  static String formatSigned(int amount, {bool isIncome = true}) {
    final prefix = isIncome ? '+ ' : '- ';
    return '$prefix${_formatter.format(amount)}';
  }
}

class DateFormatter {
  /// Format tanggal ISO UTC string dari backend menjadi format waktu lokal perangkat pengguna
  /// (Mengikuti zona waktu device user: WIB, WITA, WIT, atau zona waktu lokal luar negeri)
  static String formatDate(String isoString) {
    if (isoString.isEmpty) return '-';
    try {
      // 1. Konversi UTC dari backend ke waktu lokal perangkat pengguna
      final date = DateTime.parse(isoString).toLocal();
      final now = DateTime.now();

      // 2. Normalisasi tanggal kalender lokal (00:00:00)
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final txDate = DateTime(date.year, date.month, date.day);

      final timeStr = DateFormat('HH:mm').format(date);

      // 3. Bandingkan tanggal kalender secara tepat
      if (txDate.isAtSameMomentAs(today)) {
        return 'Hari ini, $timeStr';
      } else if (txDate.isAtSameMomentAs(yesterday)) {
        return 'Kemarin, $timeStr';
      } else if (today.difference(txDate).inDays < 7 && txDate.isBefore(today)) {
        return '${DateFormat('EEEE', 'id_ID').format(date)}, $timeStr';
      } else {
        return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(date);
      }
    } catch (e) {
      return isoString;
    }
  }

  /// Tanggal sekarang dalam format yyyy-MM-dd (waktu lokal device)
  static String todayForApi() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  /// Awal bulan ini dalam format yyyy-MM-dd
  static String startOfMonthForApi() {
    final now = DateTime.now();
    return DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month, 1));
  }

  /// Akhir bulan ini dalam format yyyy-MM-dd
  static String endOfMonthForApi() {
    final now = DateTime.now();
    return DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month + 1, 0));
  }

  /// Awal tahun ini dalam format yyyy-MM-dd
  static String startOfYearForApi() {
    return '${DateTime.now().year}-01-01';
  }

  /// Akhir tahun ini dalam format yyyy-MM-dd
  static String endOfYearForApi() {
    return '${DateTime.now().year}-12-31';
  }
}
