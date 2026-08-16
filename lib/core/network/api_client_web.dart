import 'package:dio/dio.dart';
import 'package:dio/browser.dart';

/// Setup untuk platform Web: gunakan withCredentials agar browser kirim cookie
void setupInterceptors(Dio dio) {
  // Ini memberitahu browser untuk mengirim cookie secara otomatis
  dio.httpClientAdapter = BrowserHttpClientAdapter(withCredentials: true);
}

Future<void> clearCookies(Dio dio) async {
  // Di web, cookie dikelola oleh browser — tidak perlu clear manual
}
