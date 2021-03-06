import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:under_control_flutter/helpers/date_calc.dart';
import 'package:under_control_flutter/models/app_user.dart';
import 'package:under_control_flutter/models/item.dart';
import 'package:under_control_flutter/models/task.dart';

// this class provides tasks data and DB operations methods
class TaskProvider with ChangeNotifier {
  AppUser? _user;

  Map<String, List<Task>> _tasks = {};
  Map<String, List<Task>> _tasksArchive = {};

  Task? _undoTask;
  BuildContext? _undoContext;

  bool _isActive = true;
  bool _isLoading = false;

  List<Task> _upcomingTasks = [];

  TaskExecutor calendarExecutor = TaskExecutor.all;

  TaskProvider();

  void clear() {
    _user = null;
    _upcomingTasks = [];
    _tasks = {};
    _tasksArchive = {};
  }

  void updateUser(AppUser? user) {
    _user = user;
  }

  set executor(TaskExecutor taskExecutor) {
    calendarExecutor = taskExecutor;
    notifyListeners();
  }

  void setDoneTasks() {
    _isActive = false;
  }

  // switches between active and done tasks
  void toggleIsActive() {
    _isActive = !isActive;
    // fetchAndSetTasks();
    notifyListeners();
  }

  bool get isActive => _isActive;

  bool get isLoading => _isLoading;

  List<Task> get upcomingTasks => _upcomingTasks;

  TaskExecutor get executor => calendarExecutor;

  Map<String, List<Task>> get getAllTasks => isActive ? _tasks : _tasksArchive;

  // provides five upcoming tasks
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

  // provides five recently finished tasks
  Future<List<Task>> fetchAndGetCompletedTasks() async {
    var keys = _tasksArchive.keys.toList();
    DateFormat format = DateFormat("dd/MM/yyyy");
    var dates = keys.map((e) => format.parse(e)).toList();
    dates = dates..sort((a, b) => b.compareTo(a));
    var formatedKeys =
        dates.map((e) => DateFormat('dd/MM/yyyy').format(e)).toList();
    int count = 0;
    List<Task> result = [];
    for (var i = 0; i < formatedKeys.length && count < 5; i++) {
      for (var j = 0;
          j < _tasksArchive[formatedKeys[i]]!.length && count < 5;
          j++) {
        result.add(_tasksArchive[formatedKeys[i]]![j]);
        count++;
      }
    }
    _upcomingTasks = result;
    return _upcomingTasks;
  }

  // gets tasks data from DB
  Future<void> fetchAndSetTasks() async {
    _isLoading = true;

    final taskRef = FirebaseFirestore.instance
        .collection('companies')
        .doc(_user!.companyId)
        .collection('tasks')
        .orderBy('date', descending: false)
        .snapshots();

    taskRef.listen((snapshot) {
      _tasks.clear();
      for (DocumentSnapshot doc in snapshot.docs) {
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
          itemName: doc['itemName'],
          location: doc['location'],
          description: doc['description'],
          comments: doc['comments'],
          status: TaskStatus.values[doc['status']],
          type: TaskType.values[doc['type']],
          images: doc['images'],
          cost: doc['cost'],
          duration: doc['duration'],
        );
        if (_tasks.containsKey(stringDate)) {
          _tasks[stringDate]!.insert(0, tmpTask);
        } else {
          _tasks[stringDate] = [tmpTask];
        }
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> fetchAndSetCompletedTasks() async {
    _isLoading = true;

    final taskRef = FirebaseFirestore.instance
        .collection('companies')
        .doc(_user!.companyId)
        .collection('archive')
        .orderBy('date', descending: false)
        .snapshots();

    taskRef.listen((snapshot) {
      _tasksArchive.clear();
      for (DocumentSnapshot doc in snapshot.docs) {
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
          itemName: doc['itemName'],
          location: doc['location'],
          description: doc['description'],
          comments: doc['comments'],
          status: TaskStatus.values[doc['status']],
          type: TaskType.values[doc['type']],
          images: doc['images'],
          cost: doc['cost'],
          duration: doc['duration'],
        );
        if (_tasksArchive.containsKey(stringDate)) {
          _tasksArchive[stringDate]!.insert(0, tmpTask);
        } else {
          _tasksArchive[stringDate] = [tmpTask];
        }
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  // gets shared done tasks
  Future<Map<String, List<Task>>> getSharedDoneTasks(
      Item item, String companyId) async {
    _isLoading = true;
    Map<String, List<Task>> tmpTasks = {};
    final taskRef = FirebaseFirestore.instance
        .collection('companies')
        .doc(companyId)
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
          itemName: doc['itemName'],
          location: doc['location'],
          description: doc['description'],
          comments: doc['comments'],
          status: TaskStatus.values[doc['status']],
          type: TaskType.values[doc['type']],
          images: doc['images'],
          cost: doc['cost'],
          duration: doc['duration'],
        );
        if (tmpTasks.containsKey(stringDate)) {
          tmpTasks[stringDate]!.add(tmpTask);
        } else {
          tmpTasks[stringDate] = [tmpTask];
        }
      }
    });
    _isLoading = false;
    notifyListeners();
    return tmpTasks;
  }

  // gets shared tasks from DB
  Future<void> fetchAndSetSharedTasks() async {
    _isLoading = true;

    final taskRef = FirebaseFirestore.instance
        .collection('companies')
        .doc(_user!.companyId)
        .collection('sharedTasks')
        .get();

    await taskRef.then((QuerySnapshot querySnapshot) async {
      for (var sharedDoc in querySnapshot.docs) {
        final companyId = sharedDoc['companyId'];
        final taskId = sharedDoc['taskId'];

        await FirebaseFirestore.instance
            .collection('companies')
            .doc(companyId)
            .collection('tasks')
            .doc(taskId)
            .get()
            .then((DocumentSnapshot docSnap) {
          if (docSnap.exists) {
            final date = DateTime.parse(docSnap['date']);
            final stringDate = DateFormat('dd/MM/yyyy').format(date);
            final nextDate = docSnap['nextDate'] != null
                ? DateTime.parse(docSnap['nextDate'])
                : null;

            final tmpTask = Task(
              taskId: docSnap.id,
              title: docSnap['title'],
              date: date,
              nextDate: nextDate,
              taskInterval: docSnap['taskInterval'],
              executor: TaskExecutor.values[docSnap['executor']],
              executorId: docSnap['executorId'],
              userId: docSnap['userId'],
              itemId: docSnap['itemId'],
              itemName: docSnap['itemName'],
              location: docSnap['location'],
              description: docSnap['description'],
              comments: docSnap['comments'],
              status: TaskStatus.values[docSnap['status']],
              type: TaskType.values[docSnap['type']],
              images: docSnap['images'],
              cost: docSnap['cost'],
              duration: docSnap['duration'],
            );

            if (_tasks.containsKey(stringDate)) {
              _tasks[stringDate]!.add(tmpTask);
            } else {
              _tasks[stringDate] = [tmpTask];
            }
          }
        });
      }
    });
  }

  // adds new task to DB
  Future<Task?> addTask(Task task) async {
    Task tmpTask = task;
    Task result;

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
      'itemName': task.itemName,
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
      return tmpTask;
    });
    // if (tmpTask.executor == TaskExecutor.shared) {
    //   await shareTask(tmpTask);
    // }
    return result;
  }

  // add shared task to DB
  Future<Task?> addSharedTask(Task task, String companyId) async {
    Task tmpTask = task;
    Task result;

    final tasksRef = FirebaseFirestore.instance
        .collection('companies')
        .doc(companyId)
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
      'itemName': task.itemName,
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
      return tmpTask;
    });
    // if (tmpTask.executor == TaskExecutor.shared) {
    //   await shareTaskByShared(tmpTask, companyId);
    // }
    return result;
  }

  // shares task with choosen company
  Future<void> shareTask(Task task) async {
    final tasksRef = FirebaseFirestore.instance
        .collection('companies')
        .doc(task.executorId)
        .collection('sharedTasks');

    await tasksRef.add({
      'companyId': _user!.companyId,
      'taskId': task.taskId,
    });
  }

  // shares cyclic task completed by choosen company
  Future<void> shareTaskByShared(Task task, String companyId) async {
    final tasksRef = FirebaseFirestore.instance
        .collection('companies')
        .doc(task.executorId)
        .collection('sharedTasks');

    await tasksRef.add({
      'companyId': companyId,
      'taskId': task.taskId,
    });
  }

  // updates task
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
      'itemName': task.itemName,
      'location': task.location,
      'description': task.description,
      'comments': task.comments,
      'status': task.status.index,
      'type': task.type.index,
      'images': task.images,
      'cost': task.cost,
      'duration': task.duration,
    });
    notifyListeners();
  }

  // updates shared task
  Future<void> updateSharedTask(Task task, String companyId) async {
    final tasksRef = FirebaseFirestore.instance
        .collection('companies')
        .doc(companyId)
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
      'itemName': task.itemName,
      'location': task.location,
      'description': task.description,
      'comments': task.comments,
      'status': task.status.index,
      'type': task.type.index,
      'images': task.images,
      'cost': task.cost,
      'duration': task.duration,
    });
    notifyListeners();
  }

  // completes task
  Future<void> completeTask(Task task, Task oldTask) async {
    await addToArchive(task).then((_) => deleteTask(oldTask));
  }

  // completes shared task
  Future<void> completeSharedTask(
      Task task, Task oldTask, String companyId) async {
    await addSharedToArchive(task, companyId)
        .then((_) => deleteSharedTask(oldTask, companyId));
  }

  // adds next cyclic task to the list
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
    // _tasks.remove(task);
    notifyListeners();
    return await addTask(nextTask);
  }

  // adds next shared task to the list
  Future<Task?> addNextSharedTask(Task task, String companyId) async {
    Task? nextTask;

    // updates next task date
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
    return await addSharedTask(nextTask, companyId);
  }

  // adds task to archive
  Future<void> addToArchive(Task task) async {
    // Task tmpTask;

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
      'itemName': task.itemName,
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
      // tmpTask = task.copyWith();

      // final date = DateFormat('dd/MM/yyyy').format(tmpTask.date);
      // if (_tasksArchive.containsKey(date)) {
      //   _tasksArchive[date]!.add(tmpTask);
      // } else {
      //   _tasksArchive[date] = [tmpTask];
      // }
      // notifyListeners();
    });
  }

  // adds shared task to archive
  Future<void> addSharedToArchive(Task task, String companyId) async {
    // Task tmpTask;

    final tasksRef = FirebaseFirestore.instance
        .collection('companies')
        .doc(companyId)
        .collection('archive');

    await tasksRef.add({
      'title': task.title,
      'date': task.date.toIso8601String(),
      'nextDate': task.nextDate?.toIso8601String(),
      'taskInterval': task.taskInterval,
      'executor': task.executor.index,
      'executorId': task.executorId,
      'userId': task.userId,
      'itemId': task.itemId,
      'itemName': task.itemName,
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
      // tmpTask = task.copyWith();

      // final date = DateFormat('dd/MM/yyyy').format(tmpTask.date);
      // if (_tasksArchive.containsKey(date)) {
      //   _tasksArchive[date]!.add(tmpTask);
      // } else {
      //   _tasksArchive[date] = [tmpTask];
      // }
      // notifyListeners();
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

    // if (task.executor == TaskExecutor.shared) {
    //   await deleteSharedWithTask(task);
    // }

    await taskRef.delete();

    // .then((_) {
    //   final key = DateFormat('dd/MM/yyyy').format(task.date);
    //   _tasks[key]!.removeWhere((element) => element.taskId == task.taskId);
    //   if (_tasks[key] != null && _tasks[key]!.isEmpty) {
    //     _tasks.remove(key);
    //   }
    // }).catchError((error) {});
    // notifyListeners();
    return response;
  }

  // deletes shared task
  Future<bool> deleteSharedTask(Task task, String companyId) async {
    var response = true;
    final taskRef = FirebaseFirestore.instance
        .collection('companies')
        .doc(companyId)
        .collection('tasks')
        .doc(task.taskId);

    await deleteSharedWithTask(task);

    await taskRef.delete();

    // .then((_) {
    //   final key = DateFormat('dd/MM/yyyy').format(task.date);
    //   _tasks[key]!.removeWhere((element) => element.taskId == task.taskId);
    //   if (_tasks[key] != null && _tasks[key]!.isEmpty) {
    //     _tasks.remove(key);
    //   }
    // }).catchError((error) {});
    // notifyListeners();
    return response;
  }

  // deletes task shared with choosen company
  Future<void> deleteSharedWithTask(Task task) async {
    String taskToDelete = '';
    await FirebaseFirestore.instance
        .collection('companies')
        .doc(task.executorId)
        .collection('sharedTasks')
        .where('taskId', isEqualTo: task.taskId)
        .get()
        .then((QuerySnapshot querySnap) {
      if (querySnap.docs.isNotEmpty) {
        taskToDelete = querySnap.docs[0].id;
      }
    });

    await FirebaseFirestore.instance
        .collection('companies')
        .doc(task.executorId)
        .collection('sharedTasks')
        .doc(taskToDelete)
        .delete();
  }

  // deletes task from archive
  Future<bool> deleteFromTaskArchive(BuildContext context, Task task) async {
    var response = true;
    await FirebaseFirestore.instance
        .collection('companies')
        .doc(_user!.companyId)
        .collection('archive')
        .doc(task.taskId)
        .delete()
        //     .then((_) {
        //   final key = DateFormat('dd/MM/yyyy').format(task.date);
        //   _tasksArchive[key]!
        //       .removeWhere((element) => element.taskId == task.taskId);
        //   if (_tasksArchive[key]!.isEmpty) {
        //     _tasksArchive.remove(key);
        //   }
        //   notifyListeners();
        // })
        .catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to delete item"),
        ),
      );
    });
    return response;
  }

  // rapid complete
  Future<bool> rapidComplete(BuildContext context, Task task) async {
    _undoContext = context;
    _undoTask = task;
    task.status = TaskStatus.completed;
    task.comments = 'Rapid Complete';

    // set task date to today
    task = task.copyWith(date: DateTime.now());
    if (task.taskInterval != null && task.taskInterval != 'No') {
      task.nextDate = DateCalc.getNextDate(task.date, task.taskInterval!);
    }

    var response = false;
    await addToArchive(task).then((_) => deleteTask(task).then((value) {
          addNextTask(task).then(
            (nextTask) => ScaffoldMessenger.of(context)
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
    return response;
  }

  // undo rapid complete
  Future<bool> undoRapidComplete() async {
    _undoTask!.status = TaskStatus.started;
    _undoTask!.comments = '';
    var response = false;
    await addTask(_undoTask!).then((value) =>
        deleteFromTaskArchive(_undoContext!, _undoTask!)
            .then((value) => response = value));
    return response;
  }

  // check if task is steel active
  Future<bool> checkIfActive(Task task) async {
    bool response = false;

    await FirebaseFirestore.instance
        .collection('companies')
        .doc(_user!.companyId)
        .collection('tasks')
        .doc(task.taskId)
        .get()
        .then((doc) => response = doc.exists);

    return response;
  }
}
