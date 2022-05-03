class Todo {
  final int? id;
  final String title;
  final int isDone;
  final int? taskId;

  Todo({
    this.id,
    required this.title,
    this.taskId,
    required this.isDone,
  });

  Map<String, dynamic> toMap() {
    return {"id": id, "title": title, "taskId": taskId, "isDone": isDone};
  }

  // Implement toString to make it easier to see information about
  // each Todo when using the print statement.
  @override
  String toString() {
    return 'Todo{id: $id, title: $title, isDone: $isDone, taskId: $taskId}';
  }
}
