import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/balance_model.dart';
import '../../data/models/transaction_model.dart';
import '../providers/auth_provider.dart';
import '../providers/balance_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/analytics_chart.dart';
import '../widgets/interactive_scale.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;
  const HomeScreen({Key? key, this.onNavigateTab}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final balanceProvider = context.read<BalanceProvider>();
    final transactionProvider = context.read<TransactionProvider>();

    await Future.wait([
      balanceProvider.fetchBalances(),
      transactionProvider.fetchTransactions(),
      transactionProvider.fetchSummary(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final email = authProvider.profile?.email ?? 'Pengguna';
    final displayName = email.split('@').first;

    return Scaffold(
      body: Stack(
        children: [
          // Background decorative circles
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.primaryAction.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),

          RefreshIndicator(
            color: AppColors.primaryAction,
            onRefresh: _loadData,
            child: SafeArea(
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // Greeting Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Halo, $displayName! 👋',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Siap mencatat hari ini?',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 28)),

                  // Summary Card (dari API /transaction/summary)
                  SliverToBoxAdapter(
                    child: Consumer<TransactionProvider>(
                      builder: (context, trxProvider, child) {
                        if (trxProvider.isLoading) {
                          return const SummaryCardShimmer();
                        }
                        final summary = trxProvider.summary;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ringkasan Bulan Ini',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  CurrencyFormatter.format(summary.balance),
                                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                        fontSize: 30,
                                        color: AppColors.textPrimary,
                                      ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _SummaryMiniCard(
                                        title: 'Pemasukan',
                                        amount: CurrencyFormatter.format(summary.income),
                                        icon: Icons.arrow_downward_rounded,
                                        color: AppColors.income,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _SummaryMiniCard(
                                        title: 'Pengeluaran',
                                        amount: CurrencyFormatter.format(summary.expense),
                                        icon: Icons.arrow_upward_rounded,
                                        color: AppColors.expense,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 28)),

                  // Grafik Analitik 7 Hari Terakhir
                  SliverToBoxAdapter(
                    child: Consumer<TransactionProvider>(
                      builder: (context, trxProvider, child) {
                        if (trxProvider.isLoading) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: AnalyticsChart(transactions: trxProvider.transactions),
                        );
                      },
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 28)),

                  // Dompet Saya (dari API /balance)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text('Dompet Saya', style: Theme.of(context).textTheme.titleLarge),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  SliverToBoxAdapter(
                    child: Consumer<BalanceProvider>(
                      builder: (context, balanceProvider, child) {
                        if (balanceProvider.isLoading) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: ShimmerLoading(height: 110),
                          );
                        }
                        if (balanceProvider.balances.isEmpty) {
                          return _buildEmptyWallet();
                        }
                        return SizedBox(
                          height: 120,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            itemCount: balanceProvider.balances.length,
                            itemBuilder: (context, index) {
                              final balance = balanceProvider.balances[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: _WalletChip(balance: balance),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 28)),

                  // Transaksi Terakhir (dari API /transaction)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Transaksi Terakhir', style: Theme.of(context).textTheme.titleLarge),
                          InteractiveScale(
                            onTap: () {
                              if (widget.onNavigateTab != null) {
                                widget.onNavigateTab!(2); // Pindah ke tab Transaksi (index 2)
                              }
                            },
                            child: Text(
                              'Lihat Semua',
                              style: TextStyle(
                                color: AppColors.primaryAction,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),

                  Consumer<TransactionProvider>(
                    builder: (context, trxProvider, child) {
                      if (trxProvider.isLoading) {
                        return SliverToBoxAdapter(
                          child: TransactionListShimmer(count: 4),
                        );
                      }
                      if (trxProvider.transactions.isEmpty) {
                        return SliverToBoxAdapter(child: _buildEmptyTransaction());
                      }

                      // Ambil 5 transaksi terakhir saja
                      final recentTx = trxProvider.transactions.take(5).toList();

                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final tx = recentTx[index];
                            return _TransactionTile(transaction: tx);
                          },
                          childCount: recentTx.length,
                        ),
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
    );
  }

  Widget _buildEmptyWallet() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GlassCard(
        child: Column(
          children: [
            Icon(Icons.account_balance_wallet_outlined, size: 40, color: AppColors.textSecondary.withOpacity(0.5)),
            const SizedBox(height: 12),
            Text(
              'Belum ada dompet',
              style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              'Tambahkan dompet pertamamu di tab Dompet',
              style: TextStyle(color: AppColors.textSecondary.withOpacity(0.7), fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTransaction() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Icon(Icons.receipt_long_outlined, size: 56, color: AppColors.textSecondary.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(
            'Belum ada catatan keuangan',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Mulai catat pemasukan atau pengeluaranmu!',
            style: TextStyle(color: AppColors.textSecondary.withOpacity(0.7), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-Widgets ─────────────────────────────────

class _SummaryMiniCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final Color color;

  const _SummaryMiniCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                const SizedBox(height: 2),
                Text(
                  amount,
                  style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletChip extends StatelessWidget {
  final Balance balance;
  const _WalletChip({required this.balance});

  @override
  Widget build(BuildContext context) {
    final isNonCash = balance.type == 'nonCash';
    return GlassCard(
      width: 150,
      borderRadius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isNonCash ? Icons.credit_card_rounded : Icons.money_rounded,
            color: AppColors.textPrimary,
            size: 22,
          ),
          const SizedBox(height: 10),
          Text(
            balance.wallet,
            style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            CurrencyFormatter.format(balance.amount),
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction transaction;
  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.isIncome;
    final color = isIncome ? AppColors.income : AppColors.expense;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description.isNotEmpty ? transaction.description : transaction.categoryLabel,
                    style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
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
                              transaction.type == 'nonCash' ? Icons.credit_card_rounded : Icons.money_rounded,
                              size: 11,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              transaction.type == 'nonCash' ? 'Non-Tunai' : 'Tunai',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Badge Nama Dompet
                      Consumer<BalanceProvider>(
                        builder: (context, bp, child) {
                          final wallet = bp.balances
                              .cast<Balance?>()
                              .firstWhere((b) => b?.id == transaction.balanceId, orElse: () => null);
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
                        DateFormatter.formatDate(transaction.createdAt),
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              CurrencyFormatter.formatSigned(transaction.amount, isIncome: isIncome),
              style: TextStyle(
                color: isIncome ? AppColors.textPrimary : AppColors.expense,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
