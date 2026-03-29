class Task {
  const Task({
    required this.id,
    required this.uid,
    required this.title,
    required this.description,
    required this.status,
    required this.category,
    required this.tags,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String uid;
  final String title;
  final String description;
  final String status;
  final String category;
  final List<String> tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
