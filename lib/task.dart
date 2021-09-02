class Task {
  // Init
  final int id;
  final String task;

  Task({required this.id, required this.task,});

  // toMap()
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": task,
    };
  }

  @override
  String toString() {
    return "SuperHero{\n  id: $id\n  task: $task\n  }\n\n";
  }
}