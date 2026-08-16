import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/transaction_model.dart';
import 'glass_card.dart';

class DailyChartData {
  final DateTime date;
  final String dayName;
  final int income;
  final int expense;

  DailyChartData({
    required this.date,
    required this.dayName,
    required this.income,
    required this.expense,
  });
}

/// Widget Grafik Analitik 7 Hari (Pemasukan & Pengeluaran)
class AnalyticsChart extends StatelessWidget {
  final List<Transaction> transactions;

  const AnalyticsChart({
    Key? key,
    required this.transactions,
  }) : super(key: key);

  /// Mengelompokkan transaksi 7 hari terakhir
  List<DailyChartData> _generate7DaysData() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = <DailyChartData>[];

    for (int i = 6; i >= 0; i--) {
      final targetDate = today.subtract(Duration(days: i));
      final dayName = DateFormat('EEE', 'id_ID').format(targetDate); // Sen, Sel, Rab...

      int dailyIncome = 0;
      int dailyExpense = 0;

      for (var tx in transactions) {
        if (tx.createdAt.isNotEmpty) {
          try {
            final txDate = DateTime.parse(tx.createdAt).toLocal();
            if (txDate.year == targetDate.year &&
                txDate.month == targetDate.month &&
                txDate.day == targetDate.day) {
              if (tx.isIncome) {
                dailyIncome += tx.amount;
              } else {
                dailyExpense += tx.amount;
              }
            }
          } catch (_) {}
        }
      }

      days.add(DailyChartData(
        date: targetDate,
        dayName: dayName,
        income: dailyIncome,
        expense: dailyExpense,
      ));
    }

    return days;
  }

  @override
  Widget build(BuildContext context) {
    final data = _generate7DaysData();

    // Cari nilai maksimum untuk penskalaan tinggi grafik
    int maxVal = 0;
    for (var d in data) {
      if (d.income > maxVal) maxVal = d.income;
      if (d.expense > maxVal) maxVal = d.expense;
    }
    if (maxVal == 0) maxVal = 1; // Cegah division by zero

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 8,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Analisis 7 Hari Terakhir',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Pemasukan vs Pengeluaran Harian',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              // Legend
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _legendItem('Masuk', AppColors.income),
                  const SizedBox(width: 12),
                  _legendItem('Keluar', AppColors.expense),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Area Grafik Bar (Height fixed 140px)
          SizedBox(
            height: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((d) {
                final incomeRatio = (d.income / maxVal).clamp(0.05, 1.0);
                final expenseRatio = (d.expense / maxVal).clamp(0.05, 1.0);

                return Tooltip(
                  message: '${d.dayName}: Masuk ${CurrencyFormatter.format(d.income)} | Keluar ${CurrencyFormatter.format(d.expense)}',
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Dual Bar
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Income Bar
                          _buildBar(
                            heightFactor: d.income == 0 ? 0.04 : incomeRatio,
                            color: d.income == 0
                                ? AppColors.income.withOpacity(0.2)
                                : AppColors.income,
                          ),
                          const SizedBox(width: 3),
                          // Expense Bar
                          _buildBar(
                            heightFactor: d.expense == 0 ? 0.04 : expenseRatio,
                            color: d.expense == 0
                                ? AppColors.expense.withOpacity(0.2)
                                : AppColors.expense,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        d.dayName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar({required double heightFactor, required Color color}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      width: 12,
      height: 100 * heightFactor,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
