import 'package:flutter/material.dart';

class Task {
  String title;
  String description;
  String status;

  Task({
    required this.title,
    required this.description,
    required this.status,
  });

  factory Task.fromJson(String json) {
    final parts = json.split('|');
    return Task(
      title: parts[0],
      description: parts[1],
      status: parts[2],
    );
  }

  String toJson() => '$title|$description|$status';
}

class TaskItem extends StatelessWidget {
  final Task task;
  final Function(Task) onChanged;
  final Function() onDeleted;

  const TaskItem({
    super.key,
    required this.task,
    required this.onChanged,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: task.status == 'Terminada' ? Colors.grey[200] : null,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 16,
                          decoration: task.status == 'Terminada'
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      Text(
                        task.description,
                        style: TextStyle(
                          decoration: task.status == 'Terminada'
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildActionButton(),
                if (task.status == 'En Proceso') ...[
                  const SizedBox(width: 4),
                  _buildEditButton(context),
                  const SizedBox(width: 4),
                  _buildDeleteButton(context), // Pasar el contexto aquí
                ],
              ],
            ),
            Text('Estado: ${task.status}'),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return IconButton(
      icon: Icon(
        _getActionIcon(),
        color: _getActionColor(),
      ),
      onPressed: () {
        final newTask = Task(
          title: task.title,
          description: task.description,
          status: _getNextStatus(),
        );
        onChanged(newTask);
      },
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.edit, color: Colors.orange),
      onPressed: () => _showEditDialog(context),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete, color: Colors.red),
      onPressed: () async {
        final confirm = await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: const Text('¿Eliminar esta tarea en proceso?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        );
        if (confirm == true) onDeleted();
      },
    );
  }

  void _showEditDialog(BuildContext context) {
    final titleController = TextEditingController(text: task.title);
    final descController = TextEditingController(text: task.description);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Tarea'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController),
            TextField(controller: descController),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final newTask = Task(
                title: titleController.text,
                description: descController.text,
                status: 'En Proceso',
              );
              onChanged(newTask);
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  String _getNextStatus() {
    switch (task.status) {
      case 'Creada':
        return 'En Proceso';
      case 'En Proceso':
        return 'Terminada';
      case 'Terminada':
        return 'En Proceso';
      default:
        return 'Creada';
    }
  }

  IconData _getActionIcon() {
    switch (task.status) {
      case 'Creada':
        return Icons.arrow_forward;
      case 'En Proceso':
        return Icons.check;
      case 'Terminada':
        return Icons.undo;
      default:
        return Icons.error;
    }
  }

  Color _getActionColor() {
    switch (task.status) {
      case 'Creada':
        return Colors.blue;
      case 'En Proceso':
        return Colors.green;
      case 'Terminada':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
