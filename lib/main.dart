import 'package:flutter/material.dart';
import 'task_model.dart';
import 'task_repository.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Tarefas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TaskListPage(),
    );
  }
}

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  final TaskRepository _repository = TaskRepository();
  List<TaskModel> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshTasks();
  }

  Future<void> _refreshTasks() async {
    setState(() => _isLoading = true);
    final tasks = await _repository.getAll();
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _deleteTask(int id) async {
    await _repository.delete(id);
    _showSnackBar('Tarefa excluída com sucesso!');
    _refreshTasks();
  }

  Future<bool?> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Tarefa'),
        content: const Text('Tem certeza que deseja excluir esta tarefa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleTaskStatus(TaskModel task) async {
    final updatedTask = task.copyWith(done: task.done == 0 ? 1 : 0);
    await _repository.update(updatedTask);
    _refreshTasks();
  }

  void _openTaskForm({TaskModel? task}) async {
    // If task is not null, we are editing. The user requested loading data via "Listagem por ID".
    TaskModel? taskToEdit = task;
    if (task != null && task.id != null) {
      taskToEdit = await _repository.getById(task.id!);
    }

    if (!mounted) return;

    final TextEditingController controller = TextEditingController(text: taskToEdit?.task ?? '');
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              taskToEdit == null ? 'Nova Tarefa' : 'Editar Tarefa',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Descrição da tarefa',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.isEmpty) return;

                if (taskToEdit == null) {
                  // Create
                  final newTask = TaskModel(
                    task: controller.text,
                    done: 0,
                    created: DateTime.now().toIso8601String(),
                  );
                  await _repository.insert(newTask);
                  _showSnackBar('Tarefa criada com sucesso!');
                } else {
                  // Update
                  final updatedTask = taskToEdit.copyWith(task: controller.text);
                  await _repository.update(updatedTask);
                  _showSnackBar('Tarefa atualizada com sucesso!');
                }

                if (context.mounted) Navigator.pop(context);
                _refreshTasks();
              },
              child: Text(taskToEdit == null ? 'Criar' : 'Salvar'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Tarefas'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? const Center(child: Text('Nenhuma tarefa encontrada.'))
              : ListView.builder(
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    return Dismissible(
                      key: Key(task.id.toString()),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) => _confirmDelete(context),
                      onDismissed: (direction) => _deleteTask(task.id!),
                      child: ListTile(
                        leading: Checkbox(
                          value: task.done == 1,
                          onChanged: (_) => _toggleTaskStatus(task),
                        ),
                        title: Text(
                          task.task,
                          style: TextStyle(
                            decoration: task.done == 1
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        subtitle: Text('Criada em: ${task.created.substring(0, 10)}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () async {
                            final confirmed = await _confirmDelete(context);
                            if (confirmed == true) {
                              _deleteTask(task.id!);
                            }
                          },
                        ),
                        onTap: () => _openTaskForm(task: task),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openTaskForm(),
        tooltip: 'Adicionar Tarefa',
        child: const Icon(Icons.add),
      ),
    );
  }
}
