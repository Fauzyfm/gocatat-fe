import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/balance_provider.dart';
import 'presentation/providers/transaction_provider.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  
  // Load konfigurasi dari file .env (jika ada)
  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {
    // Fallback aman jika file .env belum dibuat oleh user
  }

  runApp(const GoCatatApp());
}

class GoCatatApp extends StatelessWidget {
  const GoCatatApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BalanceProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: MaterialApp(
        title: 'GoCatat - Manajemen Keuangan',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const _AuthGate(),
      ),
    );
  }
}

/// Cek apakah user sudah login (cookie valid) atau harus ke halaman login
class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  @override
  void initState() {
    super.initState();
    // Cek status login saat aplikasi pertama dibuka
    Future.microtask(() {
      context.read<AuthProvider>().checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Saat sedang mengecek status
        if (authProvider.isLoading) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEC5B38).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 36,
                      color: Color(0xFFEC5B38),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'GoCatat',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF524646),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Color(0xFFEC5B38),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Sudah login → tampilkan shell utama
        if (authProvider.isLoggedIn) {
          return const AppShell();
        }

        // Belum login → tampilkan halaman login
        return const LoginScreen();
      },
    );
  }
}
