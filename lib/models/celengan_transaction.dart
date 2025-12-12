class CelenganTransaction {
  final int id;
  final int amount;
  final String type;
  final String? description;
  final DateTime createdAt;

  CelenganTransaction({
    required this.id,
    required this.amount,
    required this.type,
    this.description,
    required this.createdAt,
  });

  factory CelenganTransaction.fromJson(Map<String, dynamic> json) {
    return CelenganTransaction(
      id: json['id'],
      amount: json['amount'] ?? 0,
      type: json['type'] ?? 'deposit',
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}


