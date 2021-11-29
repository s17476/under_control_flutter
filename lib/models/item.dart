import 'package:flutter/material.dart';
import 'package:under_control_flutter/models/inspection.dart';

enum InspectionStatus { ok, needsAttention, failed, expired }

class Item {
  String? itemId;
  String internalId;
  String producer;
  String model;
  String category;
  String comments;
  List<Inspection> inspections;
  DateTime lastInspection;
  String interval;
  int inspectionStatus;

  Item({
    this.itemId,
    required this.internalId,
    required this.producer,
    required this.model,
    required this.category,
    this.comments = '',
    required this.lastInspection,
    this.inspections = const [],
    required this.interval,
    required this.inspectionStatus,
  });

  void setAutogeneratedId(String id) {
    itemId = id;
  }
}
