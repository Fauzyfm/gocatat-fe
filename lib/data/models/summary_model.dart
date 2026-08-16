class Summary {
  final int income;
  final int expense;
  final int balance;

  Summary({
    required this.income,
    required this.expense,
    required this.balance,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      income: json['Income'] as int? ?? 0,
      expense: json['Expense'] as int? ?? 0,
      balance: json['AllBalance'] as int? ?? json['Balance'] as int? ?? 0,
    );
  }

  factory Summary.empty() {
    return Summary(income: 0, expense: 0, balance: 0);
  }
}
