import 'package:intl/intl.dart';

class Task {
  String? id;
  String name;
  DateTime? dueDate;
  TaskPriority priority;
  TaskStatus status;

  Task(
      {this.id,
      required this.name,
      this.dueDate,
      required this.priority,
      required this.status});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'priority': priority.name,
      'status': status.name,
      'dueDate': dueDate != null
          ? DateFormat('dd/MM/yyyy').format(dueDate!)
          : "No Deadline",
    };
  }
}

enum TaskStatus { inProgress, done}

enum TaskPriority { low, normal, high }
