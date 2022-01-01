import 'package:under_control_flutter/models/app_user.dart';
import 'package:under_control_flutter/models/checklist.dart';

class Inspection {
  String? inspectionId;
  String user;
  DateTime date;
  String comments;
  int status;
  Checklist? checklist;
  String? taskId;

  Inspection({
    this.inspectionId,
    required this.user,
    required this.date,
    required this.comments,
    required this.status,
    this.checklist,
    this.taskId,
  });

  Inspection copyWith({
    String? inspectionId,
    String? user,
    DateTime? date,
    String? comments,
    int? status,
    Checklist? checklist,
    String? taskId,
  }) {
    return Inspection(
      inspectionId: inspectionId ?? this.inspectionId,
      user: user ?? this.user,
      date: date ?? this.date,
      comments: comments ?? this.comments,
      status: status ?? this.status,
      checklist: checklist ?? this.checklist,
      taskId: taskId ?? this.taskId,
    );
  }
}
