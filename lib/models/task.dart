class Task {
  final int? id;
  final String? title;
  final String? description;

  Task({this.id, this.title, this.description});

  Map<String, dynamic> toMap() {
    return {"id": id, "title": title, "description": description};
  }

  // Implement toString to make it easier to see information about
  // each task when using the print statement.
  @override
  String toString() {
    return 'Task{id: $id, title: $title, description: $description}';
  }
}
