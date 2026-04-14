class Bid {
  final int id;
  final int taskId;
  final int bidderId;
  final double amount;
  final String? message;
  final String status;

  Bid({
    required this.id,
    required this.taskId,
    required this.bidderId,
    required this.amount,
    this.message,
    required this.status,
  });

  factory Bid.fromJson(Map<String, dynamic> json) => Bid(
    id: json['id'],
    taskId: json['task_id'],
    bidderId: json['bidder_id'],
    amount: json['amount'].toDouble(),
    message: json['message'],
    status: json['status'],
  );
}