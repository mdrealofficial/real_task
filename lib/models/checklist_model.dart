class ChecklistItem {
  final String id;
  String title;
  bool isCompleted;
  int order;

  ChecklistItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.order = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'order': order,
    };
  }

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      order: json['order'] as int? ?? 0,
    );
  }

  ChecklistItem copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    int? order,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      order: order ?? this.order,
    );
  }
}
