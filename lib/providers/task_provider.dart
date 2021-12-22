import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:under_control_flutter/models/app_user.dart';
import 'package:under_control_flutter/models/item.dart';
import 'package:under_control_flutter/models/task.dart';

class TaskProvider with ChangeNotifier {
  AppUser? _user;

  Map<String, List<Task>> _tasks = {};

  TaskExecutor calendarExecutor = TaskExecutor.company;

  TaskProvider();

  void clear() {
    _user = null;
  }

  void updateUser(AppUser? user) {
    _user = user;
  }

  void set executor(TaskExecutor taskExecutor) {
    calendarExecutor = taskExecutor;
    notifyListeners();
  }

  TaskExecutor get executor => calendarExecutor;

  Map<String, List<Task>> get getAllTasks => _tasks;

  Future<void> fetchAndSetTasks() async {
    Map<String, List<Task>> tmpTasks = {};
    await FirebaseFirestore.instance
        .collection('companies')
        .doc(_user!.companyId)
        .collection('tasks')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        final date = DateTime.parse(doc['date']);
        final stringDate = DateFormat('dd/MMM/yyyy').format(date);
        final reminderDate = doc['reminderDate'] != null
            ? DateTime.parse(doc['reminderDate'])
            : null;

        final tmpTask = Task(
          taskId: doc.id,
          title: doc['title'],
          date: date,
          reminderDate: reminderDate,
          executor: TaskExecutor.values[doc['executor']],
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
      'reminderDate': task.reminderDate?.toIso8601String(),
      'executor': task.executor.index,
      'itemId': task.itemId,
      'description': task.description,
      'comments': task.comments,
      'status': task.status.index,
      'type': task.type.index,
      'images': task.images,
    }).then((autoreneratedId) {
      tmpTask = Task(
        title: task.title,
        date: task.date,
        reminderDate: task.reminderDate,
        executor: task.executor,
        itemId: task.itemId,
        description: task.description,
        comments: task.comments,
        status: task.status,
        type: task.type,
        images: task.images,
      );
      final date = DateFormat('dd/MMM/yyyy').format(tmpTask.date);
      if (_tasks.containsKey(date)) {
        _tasks[date]!.add(tmpTask);
      } else {
        _tasks[date] = [tmpTask];
      }
      notifyListeners();
    });
  }
}
