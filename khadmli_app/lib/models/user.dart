class User {
  final int id;
  final String name;
  final String email;
  final String? university;
  final String? skills;
  final double walletBalance;
  final double trustScore;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.university,
    this.skills,
    required this.walletBalance,
    required this.trustScore,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    university: json['university'],
    skills: json['skills'],
    walletBalance: json['wallet_balance']?.toDouble() ?? 0.0,
    trustScore: json['trust_score']?.toDouble() ?? 100.0,
  );
}