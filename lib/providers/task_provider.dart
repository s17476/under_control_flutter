import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:under_control_flutter/helpers/date_calc.dart';
import 'package:under_control_flutter/models/app_user.dart';
import 'package:under_control_flutter/models/task.dart';

class TaskProvider with ChangeNotifier {
  AppUser? _user;

  Map<String, List<Task>> _tasks = {};
  final Map<String, List<Task>> _tasksArchive = {};

  Task? _undoTask;
  BuildContext? _undoContext;

  bool _isActive = true;
  bool _isLoading = false;

  double _totalCost = 0;
  int _totalTime = 0;
  Map<String, int> _assetsTime = {};
  Map<String, double> _assetsCost = {};

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

  void toggleIsActive() {
    _isActive = !isActive;
    fetchAndSetTasks();
    notifyListeners();
  }

  bool get isActive => _isActive;

  bool get isLoading => _isLoading;

  double get totalCost => _totalCost;

  int get totalTime => _totalTime;

  List<Task> get upcomingTasks => _upcomingTasks;

  TaskExecutor get executor => calendarExecutor;

  Map<String, List<Task>> get getAllTasks => _tasks;

  Map<String, int> get assetsTime => _assetsTime;

  Map<String, double> get assetsCosts => _assetsCost;

  Future<void> getCosts(
    DateTime? fromDate,
    DateTime? toDate,
    String? itemId,
  ) async {
    double tmpTotalCost = 0;
    int tmpTotalTime = 0;
    Map<String, double> tmpAssetsCosts = {};
    Map<String, int> tmpAssetsTime = {};

    final nowDate = DateTime.now();
    toDate ??= DateTime(nowDate.year, nowDate.month, 31);
    toDate = DateTime(toDate.year, toDate.month, 31);

    FirebaseFirestore.instance
        .collection('companies')
        .doc(_user!.companyId)
        .collection('archive')
        .where('date', isGreaterThanOrEqualTo: fromDate?.toIso8601String())
        .where('date', isLessThanOrEqualTo: toDate.toIso8601String())
        .where('itemId', isEqualTo: itemId)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (doc['cost'] != null) {
          tmpTotalCost += doc['cost'];
          if (doc['itemId'] != null) {
            if (tmpAssetsCosts.keys.contains(doc['itemId'])) {
              tmpAssetsCosts[doc['itemId']] =
                  tmpAssetsCosts[doc['itemId']]! + doc['cost'];
            } else {
              tmpAssetsCosts[doc['itemId']] = doc['cost'];
            }
          }
        }
        if (doc['duration'] != null) {
          tmpTotalTime += doc['duration'] as int;
          if (doc['itemId'] != null) {
            if (tmpAssetsTime.keys.contains(doc['itemId'])) {
              tmpAssetsTime[doc['itemId']] =
                  tmpAssetsTime[doc['itemId']]! + doc['duration'] as int;
            } else {
              tmpAssetsTime[doc['itemId']] = doc['duration'] as int;
            }
          }
        }
      }
      _totalCost = tmpTotalCost;
      _totalTime = tmpTotalTime;
      _assetsCost = tmpAssetsCosts;
      _assetsTime = tmpAssetsTime;
      notifyListeners();

      // print(tmpAssetsTime);
      // print(tmpAssetsCosts);
    });
  }

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
    _isLoading = true;
    Map<String, List<Task>> tmpTasks = {};
    final taskRef = isActive
        ? FirebaseFirestore.instance
            .collection('companies')
            .doc(_user!.companyId)
            .collection('tasks')
            .orderBy('date', descending: false)
            .get()
        : FirebaseFirestore.instance
            .collection('companies')
            .doc(_user!.companyId)
            .collection('archive')
            .orderBy('date', descending: true)
            .get();

    await taskRef.then((QuerySnapshot querySnapshot) {
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
          location: doc['location'],
          description: doc['description'],
          comments: doc['comments'],
          status: TaskStatus.values[doc['status']],
          type: TaskType.values[doc['type']],
          images: doc['images'],
          cost: doc['cost'],
          duration: doc['duration'],
        );
        // print('f\ne\nt\nc\nh\n ${tmpTask.cost}  ${tmpTask.duration}');
        if (tmpTasks.containsKey(stringDate)) {
          tmpTasks[stringDate]!.add(tmpTask);
        } else {
          tmpTasks[stringDate] = [tmpTask];
        }
      }
      _tasks = tmpTasks;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<Task?> addTask(Task task) async {
    // print('add task executor id  ${task.executorId}');
    Task tmpTask;
    Task result;
    // get taskss referance
    final tasksRef = FirebaseFirestore.instance
        .collection('companies')
        .doc(_user!.companyId)
        .collection('tasks');

    result = await tasksRef.add({
      'title': task.title,
      'date': task.date.toIso8601String(),
      'nextDate': task.nextDate?.toIso8601String(),
      'taskInterval': task.taskInterval,
      'executor': task.executor.index,
      'executorId': task.executorId,
      'userId': task.userId,
      'itemId': task.itemId,
      'location': task.location,
      'description': task.description,
      'comments': task.comments,
      'status': task.status.index,
      'type': task.type.index,
      'images': task.images,
      'cost': task.cost,
      'duration': task.duration,
    }).then((autoreneratedId) {
      tmpTask = task.copyWith(taskId: autoreneratedId.id);
      final date = DateFormat('dd/MM/yyyy').format(tmpTask.date);
      if (_tasks.containsKey(date)) {
        _tasks[date]!.add(tmpTask);
      } else {
        _tasks[date] = [tmpTask];
      }

      notifyListeners();
      return tmpTask;
    });
    return result;
  }

  // update task
  Future<void> updateTask(Task task) async {
    final tasksRef = FirebaseFirestore.instance
        .collection('companies')
        .doc(_user!.companyId)
        .collection('tasks')
        .doc(task.taskId);

    await tasksRef.set({
      'title': task.title,
      'date': task.date.toIso8601String(),
      'nextDate': task.nextDate?.toIso8601String(),
      'taskInterval': task.taskInterval,
      'executor': task.executor.index,
      'executorId': task.executorId,
      'userId': task.userId,
      'itemId': task.itemId,
      'location': task.location,
      'description': task.description,
      'comments': task.comments,
      'status': task.status.index,
      'type': task.type.index,
      'images': task.images,
      'cost': task.cost,
      'duration': task.duration,
    });
    // _tasks.forEach((key, val) {
    //   var index = val.indexWhere((element) => element.taskId == task.taskId);
    //   if (index > -1) {
    //     // _tasks[key]!.removeAt(index);
    //     // if (_tasks[DateFormat('dd/MM/yyyy').format(task.date)] != null) {
    //     //   _tasks[DateFormat('dd/MM/yyyy').format(task.date)]!.add(task);
    //     // } else {
    //     //   _tasks[DateFormat('dd/MM/yyyy').format(task.date)] = [task];
    //     // }

    //     _tasks[key]![index] = task;
    //   }
    // });
    fetchAndSetTasks();
    // notifyListeners();
  }

  Future<void> completeTask(Task task, Task oldTask) async {
    await addToArchive(task).then((_) => deleteTask(oldTask));
  }

  // add next task to the list
  Future<Task?> addNextTask(Task task) async {
    Task? nextTask;

    // update next task date
    if (task.taskInterval != 'No') {
      DateTime nextDate = DateTime.now();

      nextDate = DateCalc.getNextDate(task.nextDate!, task.taskInterval!)!;
      nextTask = task.copyWith(
        date: task.nextDate,
        nextDate: nextDate,
        comments: '',
        status: TaskStatus.planned,
      );
    }
    if (nextTask == null) {
      return null;
    }
    notifyListeners();
    return await addTask(nextTask);
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
      'location': task.location,
      'description': task.description,
      'comments': task.comments,
      'status': task.status.index,
      'type': task.type.index,
      'images': task.images,
      'cost': task.cost,
      'duration': task.duration,
    }).then((autoreneratedId) {
      _undoTask = _undoTask?.copyWith(
        taskId: autoreneratedId.id,
      );
      tmpTask = task.copyWith();

      final date = DateFormat('dd/MM/yyyy').format(tmpTask.date);
      if (_tasksArchive.containsKey(date)) {
        _tasksArchive[date]!.add(tmpTask);
      } else {
        _tasksArchive[date] = [tmpTask];
      }
      notifyListeners();
    });
  }

  Future<bool> deleteTask(Task task) async {
    var response = true;
    final taskRef = !isActive
        ? FirebaseFirestore.instance
            .collection('companies')
            .doc(_user!.companyId)
            .collection('archive')
            .doc(task.taskId)
        : FirebaseFirestore.instance
            .collection('companies')
            .doc(_user!.companyId)
            .collection('tasks')
            .doc(task.taskId);

    await taskRef.delete().then((_) {
      final key = DateFormat('dd/MM/yyyy').format(task.date);
      _tasks[key]!.removeWhere((element) => element.taskId == task.taskId);
      if (_tasks[key] != null && _tasks[key]!.isEmpty) {
        _tasks.remove(key);
      }
      notifyListeners();
    }).catchError((error) {
      // print(error);
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
    _undoContext = context;
    _undoTask = task;
    task.status = TaskStatus.completed;
    task.comments = 'Rapid Complete';

    var response = false;
    await addToArchive(task).then((_) => deleteTask(task).then((value) {
          addNextTask(task).then(
            (nextTask) => // undo rapid complete
                ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      backgroundColor:
                          Theme.of(context).appBarTheme.backgroundColor,
                      content: Text('${task.title} - Rapid Complete done!'),
                      duration: const Duration(seconds: 4),
                      action: SnackBarAction(
                        textColor: Colors.amber,
                        label: 'UNDO',
                        onPressed: () async {
                          await undoRapidComplete();
                          if (nextTask != null) {
                            await deleteTask(nextTask);
                          }
                        },
                      ),
                    ),
                  ),
          );
          response = value;
        }));
    // print('rapid      $_undoTask');
    return response;
  }

  Future<bool> undoRapidComplete() async {
    _undoTask!.status = TaskStatus.started;
    _undoTask!.comments = '';
    // print('undo      $_undoTask');
    var response = false;
    await addTask(_undoTask!).then((value) =>
        deleteFromTaskArchive(_undoContext!, _undoTask!)
            .then((value) => response = value));
    return response;
  }
}
