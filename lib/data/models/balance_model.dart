class Balance {
  final int id;
  final int userId;
  final String wallet;
  final String type; // 'cash' atau 'nonCash'
  final int amount;
  final String createdAt;
  final String updateAt;

  Balance({
    required this.id,
    required this.userId,
    required this.wallet,
    required this.type,
    required this.amount,
    required this.createdAt,
    required this.updateAt,
  });

  factory Balance.fromJson(Map<String, dynamic> json) {
    return Balance(
      id: json['id'] as int,
      userId: json['userID'] as int? ?? json['user_id'] as int? ?? 0,
      wallet: json['wallet'] as String? ?? '',
      type: json['type'] as String? ?? 'cash',
      amount: json['amount'] as int? ?? 0,
      createdAt: json['createdAt'] as String? ?? json['created_at'] as String? ?? '',
      updateAt: json['updateAt'] as String? ?? json['update_at'] as String? ?? '',
    );
  }

  String get typeLabel => type == 'cash' ? 'Tunai' : 'Non-Tunai';
}
