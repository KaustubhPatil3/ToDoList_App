import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskDetailPage extends StatelessWidget {
  final Task task;
  const TaskDetailPage({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Task Details")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.title, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 10),
            Text(task.description),
            const SizedBox(height: 10),
            Text("Date: ${task.date}"),
            const SizedBox(height: 10),
            Text("Priority: ${task.priority}"),
          ],
        ),
      ),
    );
  }
}
