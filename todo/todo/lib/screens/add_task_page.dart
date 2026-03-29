import 'package:flutter/material.dart';
import '../models/task.dart';
import 'package:intl/intl.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  DateTime date = DateTime.now();
  String priority = "Low";

  final priorityColors = {
    "Low": Colors.green.shade700,
    "Medium": Colors.orange.shade700,
    "High": Colors.red.shade700,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 18, 17, 17),
      appBar: AppBar(
        title: const Text("Add Task"),
        backgroundColor: Colors.green.shade700,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "New Task",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700),
            ),
            const SizedBox(height: 20),

            // Title input
            Card(
              color: const Color.fromARGB(255, 39, 38, 38),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              shadowColor: Colors.black26,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    labelText: "Title",
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description input
            Card(
              color: const Color.fromARGB(255, 52, 51, 51),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              shadowColor: Colors.black26,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    labelText: "Description",
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Priority selector
            Text(
              "Priority",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 8),
            Row(
              children: ["Low", "Medium", "High"].map((p) {
                final isSelected = priority == p;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(p),
                    selected: isSelected,
                    selectedColor: priorityColors[p]!.withOpacity(0.85),
                    backgroundColor: const Color.fromARGB(255, 71, 69, 69),
                    labelStyle: TextStyle(
                        color: isSelected
                            ? const Color.fromARGB(255, 45, 43, 43)
                            : Colors.black87),
                    onSelected: (_) {
                      setState(() => priority = p);
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Date picker
            Text(
              "Task Date",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2035),
                );
                if (picked != null) setState(() => date = picked);
              },
              child: Card(
                color: const Color.fromARGB(255, 40, 38, 38),
                elevation: 3,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('EEEE, dd MMM yyyy').format(date),
                        style: const TextStyle(fontSize: 16),
                      ),
                      Icon(Icons.calendar_month, color: Colors.green.shade700),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (titleController.text.isEmpty) return;

          Navigator.pop(
              context,
              Task(
                title: titleController.text,
                description: descController.text,
                date: date,
                priority: priority,
                done: false,
              ));
        },
        label: const Text("Save Task"),
        icon: const Icon(Icons.check),
        backgroundColor: Colors.green.shade700,
      ),
    );
  }
}
