class BalanceModel {
  final String userId;
  final double amount;
  final DateTime lastUpdated;

  BalanceModel({
    required this.userId,
    required this.amount,
    required this.lastUpdated,
  });

  factory BalanceModel.fromJson(Map<String, dynamic> json) {
    return BalanceModel(
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'amount': amount,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  BalanceModel copyWith({
    String? userId,
    double? amount,
    DateTime? lastUpdated,
  }) {
    return BalanceModel(
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  String toString() {
    return 'BalanceModel(userId: $userId, amount: $amount, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BalanceModel &&
        other.userId == userId &&
        other.amount == amount &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode {
    return userId.hashCode ^ amount.hashCode ^ lastUpdated.hashCode;
  }
}
