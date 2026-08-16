import 'package:flutter/material.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/summary_model.dart';
import '../../data/services/transaction_service.dart';
import '../../core/utils/formatters.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionService _transactionService = TransactionService();

  List<Transaction> _transactions = [];
  Summary _summary = Summary.empty();
  bool _isLoading = false;
  String _errorMessage = '';

  // Pagination & Filter state dari backend
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  int _limit = 10;
  String? _selectedCategory;
  String? _selectedType;
  String? _selectedStartDate;
  String? _selectedEndDate;

  // Getters
  List<Transaction> get transactions => _transactions;
  Summary get summary => _summary;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;
  int get limit => _limit;
  String? get selectedCategory => _selectedCategory;
  String? get selectedType => _selectedType;
  String? get selectedStartDate => _selectedStartDate;
  String? get selectedEndDate => _selectedEndDate;

  /// Fetch transaksi dari API Backend dengan dukungan query params paginasi & filter
  Future<void> fetchTransactions({
    int? page,
    int? limit,
    String? category,
    String? type,
    String? startDate,
    String? endDate,
    bool resetFilter = false,
  }) async {
    _isLoading = true;
    notifyListeners();

    if (resetFilter) {
      _selectedCategory = null;
      _selectedType = null;
      _selectedStartDate = null;
      _selectedEndDate = null;
      _currentPage = 1;
    } else {
      if (page != null) _currentPage = page;
      if (limit != null) _limit = limit;
      if (category != null) _selectedCategory = category.isEmpty ? null : category;
      if (type != null) _selectedType = type.isEmpty ? null : type;
      if (startDate != null) _selectedStartDate = startDate.isEmpty ? null : startDate;
      if (endDate != null) _selectedEndDate = endDate.isEmpty ? null : endDate;
    }

    final result = await _transactionService.getAllTransactions(
      page: _currentPage,
      limit: _limit,
      category: _selectedCategory,
      type: _selectedType,
      startDate: _selectedStartDate,
      endDate: _selectedEndDate,
    );

    if (result['success'] == true) {
      _transactions = result['transactions'] as List<Transaction>;
      _currentPage = result['page'] as int? ?? _currentPage;
      _totalPages = result['totalPages'] as int? ?? 1;
      _totalItems = result['totalItems'] as int? ?? _transactions.length;
    } else {
      _transactions = [];
      _totalPages = 1;
      _totalItems = 0;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Ambil ringkasan bulan ini (GET /transaction/summary)
  Future<void> fetchSummary() async {
    _summary = await _transactionService.getSummary(
      startDate: DateFormatter.startOfMonthForApi(),
      endDate: DateFormatter.endOfMonthForApi(),
    );
    notifyListeners();
  }

  /// Ambil ringkasan tahun ini
  Future<void> fetchYearlySummary() async {
    _summary = await _transactionService.getSummary(
      startDate: DateFormatter.startOfYearForApi(),
      endDate: DateFormatter.endOfYearForApi(),
    );
    notifyListeners();
  }

  /// Catat transaksi baru (POST /transaction)
  Future<bool> createTransaction({
    required int userId,
    required int balanceId,
    required String type,
    required int amount,
    required String category,
    String description = '',
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final result = await _transactionService.createTransaction(
      userId: userId,
      balanceId: balanceId,
      type: type,
      amount: amount,
      category: category,
      description: description,
    );

    if (result['success'] == true) {
      await fetchTransactions(page: 1);
      await fetchSummary();
      return true;
    } else {
      _errorMessage = result['message'] ?? 'Gagal mencatat transaksi';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update transaksi (PUT /transaction/:id)
  Future<bool> updateTransaction({
    required int id,
    required int userId,
    required int balanceId,
    required String type,
    required int amount,
    required String category,
    String description = '',
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final result = await _transactionService.updateTransaction(
      id: id,
      userId: userId,
      balanceId: balanceId,
      type: type,
      amount: amount,
      category: category,
      description: description,
    );

    if (result['success'] == true) {
      await fetchTransactions();
      await fetchSummary();
      return true;
    } else {
      _errorMessage = result['message'] ?? 'Gagal mengupdate transaksi';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Hapus transaksi (DELETE /transaction/:id)
  Future<bool> deleteTransaction(int id) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final result = await _transactionService.deleteTransaction(id);

    if (result['success'] == true) {
      await fetchTransactions();
      await fetchSummary();
      return true;
    } else {
      _errorMessage = result['message'] ?? 'Gagal menghapus transaksi';
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
