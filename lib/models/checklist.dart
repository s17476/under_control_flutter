class Checklist {
  String? checklistId;
  String name;
  Map<String, bool> fields;

  Checklist({
    this.checklistId,
    required this.name,
    required this.fields,
  });

  Checklist copyWith({
    String? checklistId,
    String? name,
    Map<String, bool>? fields,
  }) {
    return Checklist(
      checklistId: checklistId ?? this.checklistId,
      name: name ?? this.name,
      fields: fields ?? this.fields,
    );
  }
}
