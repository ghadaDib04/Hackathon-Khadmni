class Task {
  final int id;
  final String title;
  final String description;
  final String category;
  final String taskType;
  final double? suggestedPrice;
  final double? aiPrice;
  final String status;
  final int posterId;
  final int? workerId;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.taskType,
    this.suggestedPrice,
    this.aiPrice,
    required this.status,
    required this.posterId,
    this.workerId,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'],
    title: json['title'],
    description: json['description'] ?? '',
    category: json['category'] ?? '',
    taskType: json['task_type'] ?? '',
    suggestedPrice: (json['suggested_price'] as num?)?.toDouble(),
    aiPrice: (json['ai_price'] as num?)?.toDouble(),
    status: json['status'] ?? 'open',
    posterId: json['poster_id'] ?? 0,
    workerId: json['worker_id'],
  );
}