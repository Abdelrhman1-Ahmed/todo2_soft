import 'package:hive_flutter/adapters.dart';

part 'task_model.g.dart';

class TaskStatus {
  static const pending = 'Pending';
  static const inProgress = 'In Progress';
  static const done = 'Done';
  static const values = [pending, inProgress, done];
}

@HiveType(typeId: 1)
class TaskModel extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  String status;

  @HiveField(3)
  int colorValue;

  TaskModel({
    required this.title,
    required this.description,
    required this.status,
    required this.colorValue,
  });
}
