import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

final CookieJar _cookieJar = CookieJar();

/// Setup untuk platform Native (Android/iOS/Windows/macOS/Linux)
void setupInterceptors(Dio dio) {
  dio.interceptors.add(CookieManager(_cookieJar));
}

Future<void> clearCookies(Dio dio) async {
  await _cookieJar.deleteAll();
}
