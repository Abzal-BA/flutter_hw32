class Item {
  const Item({
    required this.id,
    required this.title,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String status;
  final DateTime createdAt;

  Item copyWith({
    String? id,
    String? title,
    String? status,
    DateTime? createdAt,
  }) {
    return Item(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
