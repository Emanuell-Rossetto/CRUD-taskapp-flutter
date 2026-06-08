class TaskModel {
  final int? id;
  final String task;
  final int done; // 0 for false, 1 for true
  final String created;

  TaskModel({
    this.id,
    required this.task,
    required this.done,
    required this.created,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task': task,
      'done': done,
      'created': created,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'],
      task: map['task'],
      done: map['done'],
      created: map['created'],
    );
  }

  TaskModel copyWith({
    int? id,
    String? task,
    int? done,
    String? created,
  }) {
    return TaskModel(
      id: id ?? this.id,
      task: task ?? this.task,
      done: done ?? this.done,
      created: created ?? this.created,
    );
  }
}
