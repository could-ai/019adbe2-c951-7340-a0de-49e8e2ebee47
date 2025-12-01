import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';

class TransactionProvider with ChangeNotifier {
  final List<DebtTransaction> _transactions = [];

  List<DebtTransaction> get transactions => _transactions;

  // Getters for filtered lists
  List<DebtTransaction> get borrowedTransactions =>
      _transactions.where((t) => t.type == TransactionType.borrow).toList();

  List<DebtTransaction> get lentTransactions =>
      _transactions.where((t) => t.type == TransactionType.lend).toList();

  // Calculate totals
  double get totalBorrowed {
    return borrowedTransactions
        .where((t) => !t.isPaid)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get totalLent {
    return lentTransactions
        .where((t) => !t.isPaid)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  void addTransaction({
    required double amount,
    required TransactionType type,
    required String personName,
    required DateTime date,
    String? description,
    String currency = 'AZN',
  }) {
    final newTransaction = DebtTransaction(
      id: const Uuid().v4(),
      amount: amount,
      type: type,
      personName: personName,
      date: date,
      description: description,
      currency: currency,
    );
    _transactions.insert(0, newTransaction); // Add to top
    notifyListeners();
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void togglePaymentStatus(String id) {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index != -1) {
      final t = _transactions[index];
      _transactions[index] = t.copyWith(isPaid: !t.isPaid);
      notifyListeners();
    }
  }
}
