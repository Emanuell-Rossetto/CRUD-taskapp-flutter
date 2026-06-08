import 'connection_db.dart';
import 'task_model.dart';

class TaskRepository {
  Future<int> insert(TaskModel task) async {
    final db = await ConnectionDb.instance.database;
    return await db.insert('tasks', task.toMap());
  }

  Future<List<TaskModel>> getAll() async {
    final db = await ConnectionDb.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('tasks', orderBy: 'created DESC');
    return List.generate(maps.length, (i) {
      return TaskModel.fromMap(maps[i]);
    });
  }

  Future<TaskModel?> getById(int id) async {
    final db = await ConnectionDb.instance.database;
    final maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return TaskModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> update(TaskModel task) async {
    final db = await ConnectionDb.instance.database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await ConnectionDb.instance.database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
