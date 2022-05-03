import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todolist/models/task.dart';
import 'package:todolist/models/todo.dart';

class DatabaseHelper {
  Future<Database> database() async {
    return openDatabase(
      join(await getDatabasesPath(), "todo.db"),
      onCreate: <Database>(db, version) async {
        await db.execute(
          'CREATE TABLE tasks(id INTEGER PRIMARY KEY, title TEXT, description TEXT)',
        );
        await db.execute(
          'CREATE TABLE todo(id INTEGER PRIMARY KEY, title TEXT,taskId INTEGER, isDone INTEGER)',
        );
        return db;
      },
      version: 1,
    );
  }

// Tasks
  Future<int> insertTask(Task task) async {
    int taskId = 0;

    Database _db = await database();
    await _db
        .insert(
          "tasks",
          task.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        )
        .then((value) => taskId = value);

    return taskId;
  }

  Future<int> updateTaskTitle(int id, String taskTitle) async {
    int taskId = 0;

    Database _db = await database();
    await _db
        .rawUpdate("UPDATE tasks SET title = '$taskTitle' WHERE id = '$id'")
        .then((value) => taskId = value);

    return taskId;
  }

  Future<void> updateTaskDescription(int id, String description) async {
    Database _db = await database();
    await _db.rawUpdate(
        "UPDATE tasks SET description = '$description' WHERE id = '$id'");
  }

  Future<List<Task>> getTasks() async {
    Database _db = await database();
    List<Map<String, dynamic>> taskMap = await _db.query("tasks");
    return List.generate(
      taskMap.length,
      (index) {
        return Task(
          id: taskMap[index]["id"],
          title: taskMap[index]["title"],
          description: taskMap[index]["description"],
        );
      },
    );
  }

  Future<void> deleteTask(int id) async {
    Database _db = await database();
    await _db.rawUpdate("DELETE FROM tasks WHERE id = '$id'");
    await _db.rawUpdate("DELETE FROM todo WHERE taskId = '$id'");
  }

// TODOS
  Future<void> insertTodo(Todo todo) async {
    Database _db = await database();
    await _db.insert(
      "todo",
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Todo>> getTodos(int? taskId) async {
    Database _db = await database();
    List<Map<String, dynamic>> todoMap =
        await _db.rawQuery("SELECT * FROM todo WHERE taskId = $taskId");

    return List.generate(
      todoMap.length,
      (index) {
        return Todo(
          id: todoMap[index]["id"],
          title: todoMap[index]["title"],
          isDone: todoMap[index]["isDone"],
          taskId: todoMap[index]["taskId"],
        );
      },
    );
  }

  Future<void> updateTodoState(int id, int state) async {
    Database _db = await database();
    await _db.rawUpdate("UPDATE todo SET isDone = '$state' WHERE id = '$id'");
  }
}
