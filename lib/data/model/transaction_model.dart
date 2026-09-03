import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType {
  income,
  expense,
}

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final String? categoryId;
  final DateTime date;
  final String? note;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    this.categoryId,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type.name,
      'categoryId': categoryId,
      'date': Timestamp.fromDate(date),
      'note': note,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      type: TransactionType.values.firstWhere(
            (value) => value.name == map['type'],
        orElse: () => TransactionType.expense,
      ),
      categoryId: map['categoryId'],
      date: map['date'] is Timestamp
          ? (map['date'] as Timestamp).toDate()
          : DateTime.parse(map['date']),
      note: map['note'],
    );
  }
}