import 'dart:ffi';
import 'dart:io';

enum TaskStatus { planned, started, completed }

enum TaskType { maintenance, event, inspection, reparation }

enum TaskExecutor { shared, company, user, all }

class Task {
  String? taskId;
  String title;
  DateTime date;
  DateTime? nextDate;
  String? taskInterval;
  TaskExecutor executor;
  String? executorId;
  String userId;
  String? itemId;
  String? location;
  String description;
  String comments;
  TaskStatus status;
  TaskType type;
  List<File>? images;
  double? cost;
  int? duration;

  Task({
    this.taskId,
    required this.title,
    required this.date,
    this.nextDate,
    this.taskInterval,
    required this.executor,
    this.executorId,
    required this.userId,
    this.itemId,
    this.location,
    required this.description,
    required this.comments,
    required this.status,
    required this.type,
    this.images,
    this.cost,
    this.duration,
  });

  void setAutogeneratedId(String id) {
    itemId = id;
  }

  Task copyWith({
    String? taskId,
    String? title,
    DateTime? date,
    DateTime? nextDate,
    String? taskInterval,
    TaskExecutor? executor,
    String? executorId,
    String? userId,
    String? itemId,
    String? location,
    String? description,
    String? comments,
    TaskStatus? status,
    TaskType? type,
    List<File>? images,
    double? cost,
    int? duration,
  }) {
    return Task(
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      date: date ?? this.date,
      nextDate: nextDate ?? this.nextDate,
      taskInterval: taskInterval ?? this.taskInterval,
      executor: executor ?? this.executor,
      executorId: executorId ?? this.executorId,
      userId: userId ?? this.userId,
      itemId: itemId ?? this.itemId,
      location: location ?? this.location,
      description: description ?? this.description,
      comments: comments ?? this.comments,
      status: status ?? this.status,
      type: type ?? this.type,
      images: images ?? this.images,
      cost: cost ?? this.cost,
      duration: duration ?? this.duration,
    );
  }
}
