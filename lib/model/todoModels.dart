class Todo {
  final int id;
  final String title;
  final bool isCompleted;

  Todo({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  Todo copyWith({bool? isCompleted}) {
    return Todo(
      id: id,
      title: title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  //  Convert Todo to Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
    };
  }

  //  Create Todo from Map
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  //  Optional: Create from Firestore DocumentSnapshot
  factory Todo.fromDocument(dynamic doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Todo(
      id: data['id'],
      title: data['title'],
      isCompleted: data['isCompleted'] ?? false,
    );
  }
}
