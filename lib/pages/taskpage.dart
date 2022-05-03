// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:todolist/database_helpers.dart';
import 'package:todolist/models/task.dart';
import 'package:todolist/models/todo.dart';
import 'package:todolist/widgets/noglowbehaviour.dart';
import 'package:todolist/widgets/todowidget.dart';

class TaskPage extends StatefulWidget {
  final Task? task;
  TaskPage({this.task});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  DatabaseHelper _dbHelper = DatabaseHelper();
  String? _taskTitle = "";
  int? _taskId = 0;
  String _taskDescription = "";

  final FocusNode _titleFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();
  final FocusNode _todoFocus = FocusNode();
  bool _contentVisible = false;

  @override
  void initState() {
    if (widget.task != null) {
      _contentVisible = true;
      _taskTitle = widget.task?.title;
      _taskDescription = widget.task?.description ?? "";
      _taskId = widget.task?.id;
      // Focus on todo input
      _todoFocus.requestFocus();
    } else {
      // Focus on title input
      _titleFocus.requestFocus();
    }
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _titleFocus.dispose();
    _descriptionFocus.dispose();
    _todoFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 24.0, bottom: 6.0),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Image(
                              image: AssetImage(
                                  "assets/images/back_arrow_icon.png"),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            focusNode: _titleFocus,
                            onSubmitted: (value) async {
                              // Check if input el is not empty
                              if (value != "") {
                                // Check if task.id exists
                                if (widget.task?.id == null) {
                                  Task _newTask = Task(title: value);
                                  DatabaseHelper _dbHelper = DatabaseHelper();
                                  _taskId =
                                      await _dbHelper.insertTask(_newTask);
                                  setState(() {
                                    _contentVisible = true;
                                    _taskTitle = value;
                                  });
                                } else {
                                  await _dbHelper.updateTaskTitle(
                                      _taskId!, value);
                                }
                              }
                              _descriptionFocus.requestFocus();
                            },
                            controller: TextEditingController()
                              ..text = _taskTitle!,
                            decoration: InputDecoration(
                              hintText: "Enter Task Title",
                              border: InputBorder.none,
                            ),
                            style: TextStyle(
                              fontSize: 26.0,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF211551),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Visibility(
                    visible: _contentVisible,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 12.0),
                      child: TextField(
                        focusNode: _descriptionFocus,
                        onSubmitted: (value) async {
                          if (value != "") {
                            await _dbHelper.updateTaskDescription(
                                _taskId!, value);
                            _taskDescription = value;
                          }
                          _todoFocus.requestFocus();
                        },
                        controller: TextEditingController()
                          ..text = _taskDescription,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Enter description for the task",
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 24.0),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: _contentVisible,
                    child: Expanded(
                      child: FutureBuilder(
                        future: _dbHelper.getTodos(_taskId),
                        builder: (context, AsyncSnapshot<List<Todo>> snapshot) {
                          return ScrollConfiguration(
                            behavior: NoGlowBehaviour(),
                            child: ListView.builder(
                              itemCount: snapshot.data?.length,
                              itemBuilder: (context, index) => GestureDetector(
                                onTap: () async {
                                  int? _isDone = snapshot.data?[index].isDone;
                                  int? _todoId = snapshot.data?[index].id;

                                  if (_isDone == 0) {
                                    _isDone = 1;
                                  } else {
                                    _isDone = 0;
                                  }
                                  await _dbHelper.updateTodoState(
                                      _todoId!, _isDone);

                                  setState(() {});
                                },
                                child: TodoWidget(
                                  text: snapshot.data?[index].title,
                                  isDone: snapshot.data?[index].isDone == 0
                                      ? false
                                      : true,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Visibility(
                      visible: _contentVisible,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.0),
                        child: Row(
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                right: 10.0,
                              ),
                              width: 20.0,
                              height: 20.0,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(6.0),
                                border: Border.all(
                                  color: Color(0xFF86829D),
                                  width: 1.5,
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                focusNode: _todoFocus,
                                controller: TextEditingController()..text = "",
                                onSubmitted: (value) async {
                                  if (value != "") {
                                    // Check if todo.id exists
                                    Todo _newTodo = Todo(
                                      title: value,
                                      taskId: _taskId,
                                      isDone: 0,
                                    );
                                    await _dbHelper.insertTodo(_newTodo);
                                    setState(() {});
                                    _todoFocus.requestFocus();
                                  }
                                },
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Enter Todo item...",
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))
                ],
              ),
              Visibility(
                visible: _contentVisible,
                child: Positioned(
                  bottom: 24.0,
                  right: 24.0,
                  child: GestureDetector(
                    onTap: () async {
                      await _dbHelper.deleteTask(_taskId!);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 60.0,
                      height: 60.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: Color(0xFFFE3577),
                      ),
                      child: Image(
                        image: AssetImage("assets/images/delete_icon.png"),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
