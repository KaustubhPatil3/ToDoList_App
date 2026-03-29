import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import '../widgets/task_card.dart';
import 'add_task_page.dart';
import 'task_detail_page.dart';
import 'stats_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Task> tasks = [];

  int currentIndex = 0;
  String filter = "All";
  String sortBy = "Date";

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    tasks = await StorageService.loadTasks();
    setState(() {});
  }

  void saveTasks() {
    StorageService.saveTasks(tasks);
  }

  // 🔥 PROGRESS CALCULATION
  int get completedTasks => tasks.where((t) => t.done).length;
  double get progress => tasks.isEmpty ? 0 : completedTasks / tasks.length;

  // 🔥 TODAY STATS
  bool isToday(DateTime d) {
    final now = DateTime.now();
    return d.day == now.day && d.month == now.month && d.year == now.year;
  }

  int get todayTasks => tasks.where((t) => isToday(t.date)).length;
  int get todayCompleted =>
      tasks.where((t) => isToday(t.date) && t.done).length;

  List<Task> getFilteredTasks() {
    List<Task> filtered = [...tasks];

    if (filter == "Today") {
      filtered = filtered.where((t) => isToday(t.date)).toList();
    } else if (filter == "Completed") {
      filtered = filtered.where((t) => t.done).toList();
    }

    if (currentIndex == 0) {
      if (sortBy == "Date") {
        filtered.sort((a, b) => a.date.compareTo(b.date));
      } else if (sortBy == "Priority") {
        const order = {"High": 1, "Medium": 2, "Low": 3};
        filtered
            .sort((a, b) => order[a.priority]!.compareTo(order[b.priority]!));
      }
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      buildHome(),
      StatsPage(tasks: tasks),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        title: const Text("Task Manager"),
        actions: currentIndex == 0
            ? [
                PopupMenuButton<String>(
                  onSelected: (value) {
                    setState(() => sortBy = value);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: "Date", child: Text("Sort by Date")),
                    PopupMenuItem(
                        value: "Priority", child: Text("Sort by Priority")),
                  ],
                )
              ]
            : null,
      ),
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        currentIndex: currentIndex,
        onTap: (i) => setState(() => currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Tasks"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Stats"),
        ],
      ),
      floatingActionButton: currentIndex == 0
          ? FloatingActionButton.extended(
              backgroundColor: Colors.green,
              onPressed: () async {
                final task = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddTaskPage()),
                );

                if (task != null) {
                  setState(() => tasks.add(task));
                  saveTasks();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text("Add Task"),
            )
          : null,
    );
  }

  Widget buildHome() {
    final filteredTasks = getFilteredTasks();

    return RefreshIndicator(
      onRefresh: loadTasks,
      child: Column(
        children: [
          // 🔥 PROGRESS CARD
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Progress: $completedTasks / ${tasks.length}",
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade800,
                  color: Colors.green,
                ),
              ],
            ),
          ),

          // 🔥 TODAY STATS
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text("$todayTasks",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18)),
                    const Text("Today Tasks",
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
                Column(
                  children: [
                    Text("$todayCompleted",
                        style:
                            const TextStyle(color: Colors.green, fontSize: 18)),
                    const Text("Completed",
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // FILTER
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ["All", "Today", "Completed"].map((f) {
                return ChoiceChip(
                  label: Text(f),
                  selected: filter == f,
                  onSelected: (_) => setState(() => filter = f),
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: filteredTasks.isEmpty
                ? const Center(
                    child: Text(
                      "No tasks found",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (_, i) {
                      final task = filteredTasks[i];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TaskDetailPage(task: task),
                            ),
                          );
                        },
                        child: TaskCard(
                          task: task,
                          onChanged: () {
                            setState(() => task.done = !task.done);
                            saveTasks();
                          },
                          onDelete: () {
                            final removed = task;
                            setState(() => tasks.remove(task));
                            saveTasks();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("${removed.title} deleted"),
                                action: SnackBarAction(
                                  label: "Undo",
                                  onPressed: () {
                                    setState(() => tasks.add(removed));
                                    saveTasks();
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
