class Wallet {
  final double balance;
  final double trustScore;

  Wallet({
    required this.balance,
    required this.trustScore,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
    balance: json['balance']?.toDouble() ?? 0.0,
    trustScore: json['trust_score']?.toDouble() ?? 100.0,
  );
}