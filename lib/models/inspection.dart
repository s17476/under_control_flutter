import 'package:under_control_flutter/models/checklist.dart';

class Inspection {
  String? inspectionId;
  DateTime date;
  String comments;
  int status;
  Checklist? checklist;

  Inspection({
    this.inspectionId,
    required this.date,
    required this.comments,
    required this.status,
    this.checklist,
  });

  Inspection copyWith({
    String? inspectionId,
    DateTime? date,
    String? comments,
    int? status,
    Checklist? checklist,
  }) {
    return Inspection(
      inspectionId: inspectionId ?? this.inspectionId,
      date: date ?? this.date,
      comments: comments ?? this.comments,
      status: status ?? this.status,
      checklist: checklist ?? this.checklist,
    );
  }
}
