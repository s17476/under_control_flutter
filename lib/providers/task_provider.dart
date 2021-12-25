import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:under_control_flutter/models/app_user.dart';
import 'package:under_control_flutter/models/item.dart';
import 'package:under_control_flutter/models/task.dart';

class TaskProvider with ChangeNotifier {
  AppUser? _user;

  Map<String, List<Task>> _tasks = {};
  Map<String, List<Task>> _tasksArchive = {};

  Task? undoTask;
  BuildContext? undoContext;

  List<Task> _upcomingTasks = [];

  TaskExecutor calendarExecutor = TaskExecutor.all;

  TaskProvider();

  void clear() {
    _user = null;
  }

  void updateUser(AppUser? user) {
    _user = user;
  }

  set executor(TaskExecutor taskExecutor) {
    calendarExecutor = taskExecutor;
    notifyListeners();
  }

  List<Task> get upcomingTasks => _upcomingTasks;

  TaskExecutor get executor => calendarExecutor;

  Map<String, List<Task>> get getAllTasks => _tasks;

  Future<List<Task>> fetchAndGetUpcomingTasks() async {
    var keys = _tasks.keys.toList();
    DateFormat format = DateFormat("dd/MM/yyyy");
    var dates = keys.map((e) => format.parse(e)).toList();
    dates = dates..sort((a, b) => a.compareTo(b));
    var formatedKeys =
        dates.map((e) => DateFormat('dd/MM/yyyy').format(e)).toList();
    int count = 0;
    List<Task> result = [];
    for (var i = 0; i < formatedKeys.length && count < 5; i++) {
      for (var j = 0; j < _tasks[formatedKeys[i]]!.length && count < 5; j++) {
        result.add(_tasks[formatedKeys[i]]![j]);
        count++;
      }
    }
    _upcomingTasks = result;

    return _upcomingTasks;
  }

  Future<void> fetchAndSetTasks() async {
    Map<String, List<Task>> tmpTasks = {};
    await FirebaseFirestore.instance
        .collection('companies')
        .doc(_user!.companyId)
        .collection('tasks')
        .orderBy('date', descending: false)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        final date = DateTime.parse(doc['date']);
        final stringDate = DateFormat('dd/MM/yyyy').format(date);
        final nextDate =
            doc['nextDate'] != null ? DateTime.parse(doc['nextDate']) : null;

        final tmpTask = Task(
          taskId: doc.id,
          title: doc['title'],
          date: date,
          nextDate: nextDate,
          taskInterval: doc['taskInterval'],
          executor: TaskExecutor.values[doc['executor']],
          executorId: doc['executorId'],
          userId: doc['userId'],
          itemId: doc['itemId'],
          description: doc['description'],
          comments: doc['comments'],
          status: TaskStatus.values[doc['status']],
          type: TaskType.values[doc['type']],
          images: doc['images'],
        );
        if (tmpTasks.containsKey(stringDate)) {
          tmpTasks[stringDate]!.add(tmpTask);
        } else {
          tmpTasks[stringDate] = [tmpTask];
        }
      }
      _tasks = tmpTasks;
      notifyListeners();
    });
  }

  Future<void> addTask(Task task) async {
    Task tmpTask;
    // get taskss referance
    final tasksRef = FirebaseFirestore.instance
        .collection('companies')
        .doc(_user!.companyId)
        .collection('tasks');

    await tasksRef.add({
      'title': task.title,
      'date': task.date.toIso8601String(),
      'nextDate': task.nextDate?.toIso8601String(),
      'taskInterval': task.taskInterval,
      'executor': task.executor.index,
      'executorId': task.executorId,
      'userId': task.userId,
      'itemId': task.itemId,
      'description': task.description,
      'comments': task.comments,
      'status': task.status.index,
      'type': task.type.index,
      'images': task.images,
    }).then((autoreneratedId) {
      tmpTask = Task(
        taskId: autoreneratedId.id,
        title: task.title,
        date: task.date,
        nextDate: task.nextDate,
        taskInterval: task.taskInterval,
        executor: task.executor,
        executorId: task.executorId,
        userId: task.userId,
        itemId: task.itemId,
        description: task.description,
        comments: task.comments,
        status: task.status,
        type: task.type,
        images: task.images,
      );
      final date = DateFormat('dd/MM/yyyy').format(tmpTask.date);
      if (_tasks.containsKey(date)) {
        _tasks[date]!.add(tmpTask);
      } else {
        _tasks[date] = [tmpTask];
      }
      print('added task');
      notifyListeners();
    });
  }

  Future<void> addToArchive(Task task) async {
    Task tmpTask;
    // get taskss referance
    final tasksRef = FirebaseFirestore.instance
        .collection('companies')
        .doc(_user!.companyId)
        .collection('archive');

    await tasksRef.add({
      'title': task.title,
      'date': task.date.toIso8601String(),
      'nextDate': task.nextDate?.toIso8601String(),
      'taskInterval': task.taskInterval,
      'executor': task.executor.index,
      'executorId': _user!.userId,
      'userId': task.userId,
      'itemId': task.itemId,
      'description': task.description,
      'comments': 'Rapid Complete',
      'status': TaskStatus.completed.index,
      'type': task.type.index,
      'images': task.images,
    }).then((autoreneratedId) {
      undoTask = Task(
        taskId: autoreneratedId.id,
        title: task.title,
        date: task.date,
        nextDate: task.nextDate,
        taskInterval: task.taskInterval,
        executor: task.executor,
        executorId: task.userId,
        userId: task.userId,
        itemId: task.itemId,
        description: task.description,
        comments: task.comments,
        status: task.status,
        type: task.type,
        images: task.images,
      );
      tmpTask = Task(
        taskId: autoreneratedId.id,
        title: task.title,
        date: task.date,
        nextDate: task.nextDate,
        taskInterval: task.taskInterval,
        executor: task.executor,
        executorId: _user!.userId,
        userId: task.userId,
        itemId: task.itemId,
        description: task.description,
        comments: 'Rapid Complete',
        status: TaskStatus.completed,
        type: task.type,
        images: task.images,
      );

      final date = DateFormat('dd/MM/yyyy').format(tmpTask.date);
      if (_tasksArchive.containsKey(date)) {
        _tasksArchive[date]!.add(tmpTask);
      } else {
        _tasksArchive[date] = [tmpTask];
      }
      notifyListeners();
    });
  }

  Future<bool> deleteTask(BuildContext context, Task task) async {
    var response = true;
    await FirebaseFirestore.instance
        .collection('companies')
        .doc(_user!.companyId)
        .collection('tasks')
        .doc(task.taskId)
        .delete()
        .then((_) {
      final key = DateFormat('dd/MM/yyyy').format(task.date);
      _tasks[key]!.removeWhere((element) => element.taskId == task.taskId);
      if (_tasks[key]!.isEmpty) {
        _tasks.remove(key);
      }
      notifyListeners();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to delete item"),
        ),
      );
    });
    return response;
  }

  Future<bool> deleteFromTaskArchive(BuildContext context, Task task) async {
    var response = true;
    await FirebaseFirestore.instance
        .collection('companies')
        .doc(_user!.companyId)
        .collection('archive')
        .doc(task.taskId)
        .delete()
        .then((_) {
      final key = DateFormat('dd/MM/yyyy').format(task.date);
      _tasksArchive[key]!
          .removeWhere((element) => element.taskId == task.taskId);
      if (_tasksArchive[key]!.isEmpty) {
        _tasksArchive.remove(key);
      }
      notifyListeners();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to delete item"),
        ),
      );
    });
    return response;
  }

  Future<bool> rapidComplete(BuildContext context, Task task) async {
    undoContext = context;

    var response = false;
    await addToArchive(task).then(
        (_) => deleteTask(context, task).then((value) => response = value));
    print('rapid      $undoTask');
    return response;
  }

  Future<bool> undoRapidComplete() async {
    print('undo      $undoTask');
    var response = false;
    await addTask(undoTask!).then((value) =>
        deleteFromTaskArchive(undoContext!, undoTask!)
            .then((value) => response = value));
    return response;
  }
}