import 'package:flutter/material.dart';
import '../../data/models/balance_model.dart';
import '../../data/services/balance_service.dart';

class BalanceProvider extends ChangeNotifier {
  final BalanceService _balanceService = BalanceService();

  List<Balance> _balances = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  List<Balance> get balances => _balances;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  /// Hitung total saldo dari seluruh dompet
  int get totalBalance => _balances.fold(0, (sum, b) => sum + b.amount);

  /// Ambil semua dompet (GET /balance)
  Future<void> fetchBalances() async {
    _isLoading = true;
    notifyListeners();

    _balances = await _balanceService.getAllBalances();

    _isLoading = false;
    notifyListeners();
  }

  /// Tambah dompet baru (POST /balance)
  Future<bool> createBalance({
    required int userId,
    required String wallet,
    required String type,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final result = await _balanceService.createBalance(
      userId: userId,
      wallet: wallet,
      type: type,
    );

    if (result['success'] == true) {
      await fetchBalances(); // Refresh data
      return true;
    } else {
      _errorMessage = result['message'] ?? 'Gagal membuat dompet';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update dompet (PUT /balance/:id)
  Future<bool> updateBalance({
    required int id,
    required int userId,
    required String wallet,
    required String type,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final result = await _balanceService.updateBalance(
      id: id,
      userId: userId,
      wallet: wallet,
      type: type,
    );

    if (result['success'] == true) {
      await fetchBalances(); // Refresh data
      return true;
    } else {
      _errorMessage = result['message'] ?? 'Gagal mengupdate dompet';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Hapus dompet (DELETE /balance/:id)
  Future<bool> deleteBalance(int id) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final result = await _balanceService.deleteBalance(id);

    if (result['success'] == true) {
      await fetchBalances(); // Refresh data
      return true;
    } else {
      _errorMessage = result['message'] ?? 'Gagal menghapus dompet';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
