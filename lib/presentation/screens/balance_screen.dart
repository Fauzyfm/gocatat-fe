import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/balance_model.dart';
import '../providers/auth_provider.dart';
import '../providers/balance_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/toast_notification.dart';

class BalanceScreen extends StatefulWidget {
  const BalanceScreen({Key? key}) : super(key: key);
  @override
  State<BalanceScreen> createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BalanceProvider>().fetchBalances();
    });
  }

  void _showBalanceDialog(Balance? existing) {
    final isEdit = existing != null;
    final walletCtrl = TextEditingController(text: existing?.wallet ?? '');
    String selectedType = existing?.type ?? 'cash';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppColors.background.withOpacity(0.92),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textSecondary.withOpacity(0.3), borderRadius: BorderRadius.circular(2)))),
                    const SizedBox(height: 20),
                    Text(isEdit ? 'Edit Dompet' : 'Tambah Dompet Baru', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 24),
                    TextFormField(controller: walletCtrl, decoration: const InputDecoration(labelText: 'Nama Dompet', hintText: 'Contoh: BCA, Gopay', prefixIcon: Icon(Icons.account_balance_wallet_outlined))),
                    const SizedBox(height: 18),
                    Text('Tipe Dompet', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(child: _typeChip('Tunai', 'cash', selectedType, Icons.money_rounded, () => setModalState(() => selectedType = 'cash'))),
                      const SizedBox(width: 12),
                      Expanded(child: _typeChip('Non-Tunai', 'nonCash', selectedType, Icons.credit_card_rounded, () => setModalState(() => selectedType = 'nonCash'))),
                    ]),
                    const SizedBox(height: 28),
                    ElevatedButton(
                      onPressed: () async {
                        if (walletCtrl.text.trim().isEmpty) { ToastHelper.showError(context, 'Nama dompet tidak boleh kosong'); return; }
                        final userId = context.read<AuthProvider>().userId;
                        final bp = context.read<BalanceProvider>();
                        bool ok;
                        if (isEdit) {
                          ok = await bp.updateBalance(id: existing.id, userId: userId, wallet: walletCtrl.text.trim(), type: selectedType);
                        } else {
                          ok = await bp.createBalance(userId: userId, wallet: walletCtrl.text.trim(), type: selectedType);
                        }
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        if (ok) { ToastHelper.showSuccess(context, isEdit ? 'Dompet diupdate!' : 'Dompet ditambahkan!'); }
                        else { ToastHelper.showError(context, bp.errorMessage); }
                      },
                      child: Text(isEdit ? 'Simpan' : 'Tambah Dompet'),
                    ),
                    const SizedBox(height: 12),
                  ]),
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Widget _typeChip(String label, String value, String current, IconData icon, VoidCallback onTap) {
    final sel = current == value;
    return GestureDetector(onTap: onTap, child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: sel ? AppColors.primaryAction.withOpacity(0.12) : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: sel ? AppColors.primaryAction : AppColors.textSecondary.withOpacity(0.2), width: sel ? 1.5 : 1),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 18, color: sel ? AppColors.primaryAction : AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: sel ? AppColors.primaryAction : AppColors.textSecondary, fontWeight: sel ? FontWeight.w600 : FontWeight.w400)),
      ]),
    ));
  }

  void _confirmDelete(Balance b) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Hapus Dompet?'),
      content: Text('Dompet "${b.wallet}" akan dihapus.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal', style: TextStyle(color: AppColors.textSecondary))),
        TextButton(onPressed: () async {
          Navigator.pop(ctx);
          final bp = context.read<BalanceProvider>();
          final ok = await bp.deleteBalance(b.id);
          if (!mounted) return;
          if (ok) { ToastHelper.showSuccess(context, 'Dompet dihapus!'); }
          else { ToastHelper.showError(context, bp.errorMessage); }
        }, child: const Text('Hapus', style: TextStyle(color: AppColors.expense))),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Positioned(bottom: -80, left: -60, child: Container(width: 280, height: 280, decoration: BoxDecoration(color: AppColors.primaryAction.withOpacity(0.1), shape: BoxShape.circle))),
        SafeArea(child: RefreshIndicator(
          color: AppColors.primaryAction,
          onRefresh: () => context.read<BalanceProvider>().fetchBalances(),
          child: CustomScrollView(physics: const AlwaysScrollableScrollPhysics(), slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Dompet Saya', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24)),
                Consumer<BalanceProvider>(builder: (c, bp, _) => Text(CurrencyFormatter.format(bp.totalBalance), style: TextStyle(color: AppColors.primaryAction, fontWeight: FontWeight.w700, fontSize: 16))),
              ],
            ))),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            Consumer<BalanceProvider>(builder: (context, bp, child) {
              if (bp.isLoading) return SliverToBoxAdapter(child: TransactionListShimmer(count: 3));
              if (bp.balances.isEmpty) {
                return SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
                  const SizedBox(height: 60),
                  Icon(Icons.account_balance_wallet_outlined, size: 64, color: AppColors.textSecondary.withOpacity(0.4)),
                  const SizedBox(height: 20),
                  const Text('Belum ada dompet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Text('Tambahkan dompet pertamamu!', style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(onPressed: () => _showBalanceDialog(null), icon: const Icon(Icons.add_rounded), label: const Text('Tambah Dompet')),
                ])));
              }
              return SliverList(delegate: SliverChildBuilderDelegate((context, index) {
                final b = bp.balances[index];
                final isNonCash = b.type == 'nonCash';
                return Padding(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6), child: GlassCard(
                  padding: const EdgeInsets.all(18),
                  child: Row(children: [
                    Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.primaryAction.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                      child: Icon(isNonCash ? Icons.credit_card_rounded : Icons.money_rounded, color: AppColors.primaryAction, size: 24)),
                    const SizedBox(width: 16),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(b.wallet, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 16)),
                      const SizedBox(height: 4),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppColors.textSecondary.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text(b.typeLabel, style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500))),
                    ])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(CurrencyFormatter.format(b.amount), style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 16)),
                      const SizedBox(height: 6),
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        GestureDetector(onTap: () => _showBalanceDialog(b), child: Icon(Icons.edit_rounded, size: 18, color: AppColors.textSecondary)),
                        const SizedBox(width: 12),
                        GestureDetector(onTap: () => _confirmDelete(b), child: Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.expense)),
                      ]),
                    ]),
                  ]),
                ));
              }, childCount: bp.balances.length));
            }),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ]),
        )),
      ]),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => _showBalanceDialog(null), icon: const Icon(Icons.add_rounded), label: const Text('Tambah')),
    );
  }
}
