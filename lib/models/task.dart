class Task {
  String id;
  String name;
  DateTime start;
  DateTime end;
  TaskPriority priority;
  TaskStatus status;
  double completePercent;

  Task(this.id, this.name, this.start, this.end, this.priority, this.status,
      this.completePercent);
}

enum TaskStatus { inProgress, done, cancelled }

enum TaskPriority { low, normal, high }