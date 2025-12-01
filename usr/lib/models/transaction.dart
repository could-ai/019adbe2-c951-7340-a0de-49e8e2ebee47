enum TransactionType {
  borrow, // Borc almaq (Mən borc alıram)
  lend,   // Borc vermək (Mən borc verirəm)
}

class DebtTransaction {
  final String id;
  final double amount;
  final TransactionType type;
  final String personName;
  final DateTime date;
  final String? description;
  final bool isPaid;
  final String currency;

  DebtTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.personName,
    required this.date,
    this.description,
    this.isPaid = false,
    this.currency = 'AZN',
  });

  DebtTransaction copyWith({
    String? id,
    double? amount,
    TransactionType? type,
    String? personName,
    DateTime? date,
    String? description,
    bool? isPaid,
    String? currency,
  }) {
    return DebtTransaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      personName: personName ?? this.personName,
      date: date ?? this.date,
      description: description ?? this.description,
      isPaid: isPaid ?? this.isPaid,
      currency: currency ?? this.currency,
    );
  }
}
