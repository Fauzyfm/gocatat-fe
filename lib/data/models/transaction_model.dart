class Transaction {
  final int id;
  final int userId;
  final int balanceId;
  final String type; // 'cash' atau 'nonCash'
  final int amount;
  final String category; // 'income' atau 'expense'
  final String description;
  final String createdAt;

  Transaction({
    required this.id,
    required this.userId,
    required this.balanceId,
    required this.type,
    required this.amount,
    required this.category,
    required this.description,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int,
      userId: json['userID'] as int? ?? json['user_id'] as int? ?? 0,
      balanceId: json['balanceID'] as int? ?? json['balance_id'] as int? ?? 0,
      type: json['type'] as String? ?? 'cash',
      amount: json['amount'] as int? ?? 0,
      category: json['category'] as String? ?? 'expense',
      description: json['description'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? json['created_at'] as String? ?? '',
    );
  }

  bool get isIncome => category == 'income';
  String get categoryLabel => isIncome ? 'Pemasukan' : 'Pengeluaran';
}
