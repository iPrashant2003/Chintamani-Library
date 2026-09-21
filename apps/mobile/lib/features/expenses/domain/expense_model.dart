class Expense {
  final String id;
  final String branchId;
  final String category; // ELECTRICITY, INTERNET, MAINTENANCE, SALARY, CLEANING, EQUIPMENT, OTHER
  final double amount;
  final String? description;
  final DateTime date;

  const Expense({
    required this.id,
    required this.branchId,
    required this.category,
    required this.amount,
    this.description,
    required this.date,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String? ?? '',
      branchId: json['branchId'] as String? ?? '',
      category: json['category'] as String? ?? 'OTHER',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String?,
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'branchId': branchId,
      'category': category,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
    };
  }

  static const List<String> categories = [
    'ELECTRICITY',
    'INTERNET',
    'MAINTENANCE',
    'SALARY',
    'CLEANING',
    'EQUIPMENT',
    'OTHER',
  ];
}
