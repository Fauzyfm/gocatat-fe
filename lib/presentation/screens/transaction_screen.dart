import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/balance_model.dart';
import '../../data/models/transaction_model.dart';
import '../providers/auth_provider.dart';
import '../providers/balance_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/interactive_scale.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/toast_notification.dart';

enum DateRangeMode { last7Days, last1Month, customRange }

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({Key? key}) : super(key: key);

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  DateRangeMode _dateRangeMode = DateRangeMode.last7Days;
  DateTimeRange _selectedRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 6)),
    end: DateTime.now(),
  );

  String _selectedCategory = ''; // '' = Semua, 'income', 'expense'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDataWithCurrentFilter(page: 1);
      context.read<BalanceProvider>().fetchBalances();
    });
  }

  void _fetchDataWithCurrentFilter({int page = 1}) {
    final trxP = context.read<TransactionProvider>();
    final startStr = DateFormat('yyyy-MM-dd').format(_selectedRange.start);
    final endStr = DateFormat('yyyy-MM-dd').format(_selectedRange.end);

    trxP.fetchTransactions(
      page: page,
      limit: 10,
      startDate: startStr,
      endDate: endStr,
      category: _selectedCategory,
    );
  }

  void _applyDateRangePreset(DateRangeMode mode) {
    final now = DateTime.now();
    DateTimeRange range;

    if (mode == DateRangeMode.last7Days) {
      range = DateTimeRange(
        start: now.subtract(const Duration(days: 6)),
        end: now,
      );
    } else {
      // 1 Bulan Terakhir (30 hari terakhir)
      range = DateTimeRange(
        start: now.subtract(const Duration(days: 30)),
        end: now,
      );
    }

    setState(() {
      _dateRangeMode = mode;
      _selectedRange = range;
    });

    _fetchDataWithCurrentFilter(page: 1);
  }

  Future<void> _pickCustomDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedRange,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryAction,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateRangeMode = DateRangeMode.customRange;
        _selectedRange = picked;
      });
      _fetchDataWithCurrentFilter(page: 1);
    }
  }

  void _showCreateDialog() => _showTransactionDialog(null);
  void _showEditDialog(Transaction tx) => _showTransactionDialog(tx);

  void _showTransactionDialog(Transaction? existing) {
    final isEdit = existing != null;
    final amountController = TextEditingController(text: isEdit ? existing.amount.toString() : '');
    final descController = TextEditingController(text: existing?.description ?? '');
    String category = existing?.category ?? 'expense';
    int? selectedBalanceId = existing?.balanceId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setModalState) {
          final balances = context.read<BalanceProvider>().balances;
          if (selectedBalanceId == null && balances.isNotEmpty) {
            selectedBalanceId = balances.first.id;
          }
          final selectedBalance = balances.cast<Balance?>().firstWhere(
            (b) => b?.id == selectedBalanceId,
            orElse: () => balances.isNotEmpty ? balances.first : null,
          );

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppColors.background.withOpacity(0.94),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.6), width: 1.5),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.textSecondary.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          isEdit ? 'Edit Transaksi' : 'Catat Transaksi Baru',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Kategori toggle
                        Text(
                          'Kategori Transaksi',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _toggleChip(
                                label: 'Pengeluaran',
                                value: 'expense',
                                current: category,
                                icon: Icons.arrow_upward_rounded,
                                activeColor: AppColors.expense,
                                onTap: () => setModalState(() => category = 'expense'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _toggleChip(
                                label: 'Pemasukan',
                                value: 'income',
                                current: category,
                                icon: Icons.arrow_downward_rounded,
                                activeColor: AppColors.income,
                                onTap: () => setModalState(() => category = 'income'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Jumlah
                        TextFormField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Jumlah (Rp)',
                            prefixIcon: Icon(Icons.attach_money_rounded),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Pilih Dompet
                        if (balances.isNotEmpty)
                          DropdownButtonFormField<int>(
                            value: selectedBalanceId,
                            decoration: const InputDecoration(
                              labelText: 'Pilih Dompet Target',
                              prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                            ),
                            items: balances.map((b) {
                              return DropdownMenuItem(
                                value: b.id,
                                child: Text('${b.wallet} (${b.typeLabel})'),
                              );
                            }).toList(),
                            onChanged: (v) {
                              setModalState(() {
                                selectedBalanceId = v;
                              });
                            },
                          ),
                        if (selectedBalance != null) ...[
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  size: 13,
                                  color: AppColors.textSecondary.withOpacity(0.8),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Tipe transaksi otomatis mengikuti dompet: ${selectedBalance!.typeLabel} (${selectedBalance!.type})',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary.withOpacity(0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),

                        // Deskripsi
                        TextFormField(
                          controller: descController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Deskripsi / Catatan (opsional)',
                            prefixIcon: Icon(Icons.notes_rounded),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Submit Button
                        ElevatedButton(
                          onPressed: () async {
                            final amount = int.tryParse(amountController.text.trim()) ?? 0;
                            if (amount <= 0) {
                              ToastHelper.showError(context, 'Jumlah harus lebih dari 0');
                              return;
                            }
                            if (selectedBalance == null) {
                              ToastHelper.showError(context, 'Pilih dompet terlebih dahulu');
                              return;
                            }

                            final userId = context.read<AuthProvider>().userId;
                            final trxProvider = context.read<TransactionProvider>();
                            bool success;

                            if (isEdit) {
                              success = await trxProvider.updateTransaction(
                                id: existing.id,
                                userId: userId,
                                balanceId: selectedBalance!.id,
                                type: selectedBalance!.type,
                                amount: amount,
                                category: category,
                                description: descController.text.trim(),
                              );
                            } else {
                              success = await trxProvider.createTransaction(
                                userId: userId,
                                balanceId: selectedBalance!.id,
                                type: selectedBalance!.type,
                                amount: amount,
                                category: category,
                                description: descController.text.trim(),
                              );
                            }

                            if (!context.mounted) return;
                            Navigator.pop(context);
                            context.read<BalanceProvider>().fetchBalances();
                            if (success) {
                              ToastHelper.showSuccess(
                                context,
                                isEdit ? 'Transaksi diupdate!' : 'Transaksi berhasil dicatat!',
                              );
                            } else {
                              ToastHelper.showError(context, trxProvider.errorMessage);
                            }
                          },
                          child: Text(isEdit ? 'Simpan Perubahan' : 'Catat Transaksi'),
                        ),

                        // Tombol Hapus Transaksi (jika Edit)
                        if (isEdit) ...[
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _confirmDelete(existing);
                            },
                            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.expense),
                            label: const Text(
                              'Hapus Transaksi Ini',
                              style: TextStyle(color: AppColors.expense, fontWeight: FontWeight.w600),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.expense.withOpacity(0.5)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Widget _toggleChip({
    required String label,
    required String value,
    required String current,
    required IconData icon,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    final selected = current == value;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: selected ? activeColor.withOpacity(0.14) : Colors.white.withOpacity(0.4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? activeColor : AppColors.textSecondary.withOpacity(0.2),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: selected ? activeColor : AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? activeColor : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(Transaction tx) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Transaksi?'),
        content: Text('Transaksi "${tx.description.isNotEmpty ? tx.description : tx.categoryLabel}" akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final p = context.read<TransactionProvider>();
              final ok = await p.deleteTransaction(tx.id);
              if (!mounted) return;
              context.read<BalanceProvider>().fetchBalances();
              if (ok) {
                ToastHelper.showSuccess(context, 'Transaksi dihapus!');
              } else {
                ToastHelper.showError(context, p.errorMessage);
              }
            },
            child: const Text('Hapus', style: TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: AppColors.primaryAction.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              color: AppColors.primaryAction,
              onRefresh: () async => _fetchDataWithCurrentFilter(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Riwayat Transaksi',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // Preset Filter Rentang Tanggal (7 Hari Terakhir, 1 Bulan Terakhir, Custom Range)
                  SliverToBoxAdapter(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          _filterChip(
                            label: '7 Hari Terakhir',
                            icon: Icons.calendar_view_week_rounded,
                            isSelected: _dateRangeMode == DateRangeMode.last7Days,
                            onTap: () => _applyDateRangePreset(DateRangeMode.last7Days),
                          ),
                          const SizedBox(width: 8),

                          _filterChip(
                            label: '1 Bulan Terakhir',
                            icon: Icons.calendar_month_rounded,
                            isSelected: _dateRangeMode == DateRangeMode.last1Month,
                            onTap: () => _applyDateRangePreset(DateRangeMode.last1Month),
                          ),
                          const SizedBox(width: 8),

                          _filterChip(
                            label: _dateRangeMode == DateRangeMode.customRange
                                ? '${DateFormat('dd/MM').format(_selectedRange.start)} - ${DateFormat('dd/MM').format(_selectedRange.end)}'
                                : 'Pilih Rentang',
                            icon: Icons.date_range_rounded,
                            isSelected: _dateRangeMode == DateRangeMode.customRange,
                            onTap: _pickCustomDateRange,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),

                  // Filter Kategori (Dropdown)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Consumer<TransactionProvider>(
                        builder: (context, trxP, child) {
                          final hasDataOrFilter = trxP.transactions.isNotEmpty || _selectedCategory.isNotEmpty;

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.textSecondary.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.filter_list_rounded,
                                  size: 20,
                                  color: hasDataOrFilter ? AppColors.primaryAction : AppColors.textSecondary.withOpacity(0.4),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedCategory,
                                      isExpanded: true,
                                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      onChanged: hasDataOrFilter
                                          ? (val) {
                                              if (val != null) {
                                                setState(() => _selectedCategory = val);
                                                _fetchDataWithCurrentFilter(page: 1);
                                              }
                                            }
                                          : null,
                                      items: const [
                                        DropdownMenuItem(
                                          value: '',
                                          child: Text('Semua Kategori Transaksi'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'income',
                                          child: Text('Pemasukan (Income)'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'expense',
                                          child: Text('Pengeluaran (Expense)'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),

                  Consumer<TransactionProvider>(
                    builder: (context, trxP, child) {
                      if (trxP.isLoading) {
                        return SliverToBoxAdapter(child: TransactionListShimmer(count: 6));
                      }

                      final transactions = trxP.transactions;

                      if (transactions.isEmpty) {
                        final rangeStr = '${DateFormat('dd MMM').format(_selectedRange.start)} - ${DateFormat('dd MMM yyyy').format(_selectedRange.end)}';

                        return SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                const SizedBox(height: 40),
                                Icon(Icons.calendar_today_outlined, size: 60, color: AppColors.textSecondary.withOpacity(0.4)),
                                const SizedBox(height: 18),
                                Text(
                                  'Tidak ada transaksi pada periode $rangeStr',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Coba ubah rentang tanggal/kategori atau catat transaksi baru.',
                                  style: TextStyle(color: AppColors.textSecondary),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (_selectedCategory.isNotEmpty || _dateRangeMode != DateRangeMode.last7Days)
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          setState(() => _selectedCategory = '');
                                          _applyDateRangePreset(DateRangeMode.last7Days);
                                        },
                                        icon: const Icon(Icons.refresh_rounded),
                                        label: const Text('Reset Filter'),
                                      ),
                                    if (_selectedCategory.isNotEmpty || _dateRangeMode != DateRangeMode.last7Days) const SizedBox(width: 12),
                                    ElevatedButton.icon(
                                      onPressed: _showCreateDialog,
                                      icon: const Icon(Icons.add_rounded),
                                      label: const Text('Catat Baru'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return SliverMainAxisGroup(
                        slivers: [
                          // Daftar Transaksi Terpaginasi Langsung Dari API Backend
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final tx = transactions[index];
                                return _buildTransactionItem(tx);
                              },
                              childCount: transactions.length,
                            ),
                          ),

                          // Kontrol Pagination Berbasis TotalPages dari API
                          if (trxP.totalPages > 1)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                                child: GlassCard(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      InteractiveScale(
                                        onTap: trxP.currentPage > 1
                                            ? () => trxP.fetchTransactions(page: trxP.currentPage - 1)
                                            : null,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: trxP.currentPage > 1
                                                ? AppColors.primaryAction.withOpacity(0.12)
                                                : Colors.black.withOpacity(0.04),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.chevron_left_rounded,
                                                size: 20,
                                                color: trxP.currentPage > 1
                                                    ? AppColors.primaryAction
                                                    : AppColors.textSecondary.withOpacity(0.4),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Sebelumnya',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: trxP.currentPage > 1
                                                      ? AppColors.primaryAction
                                                      : AppColors.textSecondary.withOpacity(0.4),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      Text(
                                        'Halaman ${trxP.currentPage} dari ${trxP.totalPages}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),

                                      InteractiveScale(
                                        onTap: trxP.currentPage < trxP.totalPages
                                            ? () => trxP.fetchTransactions(page: trxP.currentPage + 1)
                                            : null,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: trxP.currentPage < trxP.totalPages
                                                ? AppColors.primaryAction.withOpacity(0.12)
                                                : Colors.black.withOpacity(0.04),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                'Berikutnya',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: trxP.currentPage < trxP.totalPages
                                                      ? AppColors.primaryAction
                                                      : AppColors.textSecondary.withOpacity(0.4),
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Icon(
                                                Icons.chevron_right_rounded,
                                                size: 20,
                                                color: trxP.currentPage < trxP.totalPages
                                                    ? AppColors.primaryAction
                                                    : AppColors.textSecondary.withOpacity(0.4),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Catat'),
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InteractiveScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryAction : Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryAction : AppColors.textSecondary.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Transaction tx) {
    final isIncome = tx.isIncome;
    final color = isIncome ? AppColors.income : AppColors.expense;
    final isNonCash = tx.type == 'nonCash';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
      child: Dismissible(
        key: ValueKey(tx.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: AppColors.expense.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete_outline_rounded, color: AppColors.expense),
        ),
        confirmDismiss: (_) async {
          _confirmDelete(tx);
          return false;
        },
        child: InteractiveScale(
          onTap: () => _showEditDialog(tx),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.6)),
            ),
            child: Row(
              children: [
                // Icon Category
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),

                // Description & Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.description.isNotEmpty ? tx.description : tx.categoryLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          // Badge Tipe Pembayaran (Cash / Non-Tunai)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.textSecondary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isNonCash ? Icons.credit_card_rounded : Icons.money_rounded,
                                  size: 11,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isNonCash ? 'Non-Tunai' : 'Tunai',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Badge Nama Dompet (Target Wallet)
                          Consumer<BalanceProvider>(
                            builder: (context, bp, child) {
                              final wallet = bp.balances
                                  .cast<Balance?>()
                                  .firstWhere((b) => b?.id == tx.balanceId, orElse: () => null);
                              if (wallet == null) return const SizedBox.shrink();
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryAction.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.account_balance_wallet_outlined,
                                      size: 11,
                                      color: AppColors.primaryAction,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      wallet.wallet,
                                      style: const TextStyle(
                                        color: AppColors.primaryAction,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          Text(
                            DateFormatter.formatDate(tx.createdAt),
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Amount & Delete Button
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      CurrencyFormatter.formatSigned(tx.amount, isIncome: isIncome),
                      style: TextStyle(
                        color: isIncome ? AppColors.textPrimary : AppColors.expense,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InteractiveScale(
                      onTap: () => _confirmDelete(tx),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: AppColors.expense.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
