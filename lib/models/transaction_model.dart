enum TransactionType {
  send,
  receive,
  topup,
  withdrawal,
}

class TransactionModel {
  final String id;
  final String uid;
  final double amount;
  final TransactionType type;
  final String description;
  final DateTime timestamp;
  final String? recipientUid;
  final String? senderUid;

  TransactionModel({
    required this.id,
    required this.uid,
    required this.amount,
    required this.type,
    required this.description,
    required this.timestamp,
    this.recipientUid,
    this.senderUid,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      uid: json['uid'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == 'TransactionType.${json['type']}',
        orElse: () => TransactionType.send,
      ),
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      recipientUid: json['recipientUid'] as String?,
      senderUid: json['senderUid'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'amount': amount,
      'type': type.toString().split('.').last,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'recipientUid': recipientUid,
      'senderUid': senderUid,
    };
  }

  TransactionModel copyWith({
    String? id,
    String? uid,
    double? amount,
    TransactionType? type,
    String? description,
    DateTime? timestamp,
    String? recipientUid,
    String? senderUid,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      recipientUid: recipientUid ?? this.recipientUid,
      senderUid: senderUid ?? this.senderUid,
    );
  }

  @override
  String toString() {
    return 'TransactionModel(id: $id, uid: $uid, amount: $amount, type: $type, description: $description, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionModel &&
        other.id == id &&
        other.uid == uid &&
        other.amount == amount &&
        other.type == type &&
        other.description == description &&
        other.timestamp == timestamp &&
        other.recipientUid == recipientUid &&
        other.senderUid == senderUid;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        uid.hashCode ^
        amount.hashCode ^
        type.hashCode ^
        description.hashCode ^
        timestamp.hashCode ^
        recipientUid.hashCode ^
        senderUid.hashCode;
  }
}
