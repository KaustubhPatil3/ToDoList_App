import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/* ================= APP ROOT ================= */

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

/* ================= LOGIN PAGE ================= */

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String error = "";

  final users = [
    {"name": "Rahul", "email": "user1@gmail.com", "password": "1111"},
    {"name": "Sneha", "email": "user2@gmail.com", "password": "2222"},
    {"name": "Amit", "email": "user3@gmail.com", "password": "3333"},
  ];

  void login() {
    for (var user in users) {
      if (user["email"] == emailController.text.trim() &&
          user["password"] == passwordController.text.trim()) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => TodoPage(userName: user["name"]!),
          ),
        );
        return;
      }
    }
    setState(() => error = "Invalid Email or Password");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade200,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("LOGIN",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 25),

              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: "Email",
                ),
              ),
              const SizedBox(height: 15),

              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: "Password",
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton(onPressed: login, child: const Text("Login")),

              if (error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(error, style: const TextStyle(color: Colors.red)),
                )
            ],
          ),
        ),
      ),
    );
  }
}

/* ================= TODO PAGE ================= */

class TodoPage extends StatefulWidget {
  final String userName;
  const TodoPage({super.key, required this.userName});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final taskController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  DateTime taskDate = DateTime.now();
  bool showAll = false;

  final List<Map<String, dynamic>> tasks = [];

  void addTask() {
    if (taskController.text.isEmpty) return;

    setState(() {
      tasks.add({
        "title": taskController.text,
        "date": DateTime(taskDate.year, taskDate.month, taskDate.day),
        "done": false,
      });
      taskController.clear();
      taskDate = selectedDate;
    });
  }

  void logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = showAll
        ? tasks
        : tasks.where((task) {
            final d = task["date"];
            return d.year == selectedDate.year &&
                d.month == selectedDate.month &&
                d.day == selectedDate.day;
          }).toList();

    Map<String, List<Map<String, dynamic>>> groupedTasks = {};
    for (var task in filteredTasks) {
      final key =
          "${task["date"].day}/${task["date"].month}/${task["date"].year}";
      groupedTasks.putIfAbsent(key, () => []).add(task);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Hello, ${widget.userName}"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2035),
              );
              if (picked != null) {
                setState(() {
                  selectedDate = picked;
                  showAll = false;
                });
              }
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "all") {
                setState(() => showAll = true);
              } else if (value == "logout") {
                logout();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: "all", child: Text("View All Tasks")),
              PopupMenuItem(value: "logout", child: Text("Logout")),
            ],
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(10),
        children: groupedTasks.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  entry.key,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...entry.value.map((task) {
                return Card(
                  child: ListTile(
                    title: Text(task["title"]),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: task["done"],
                          onChanged: (v) =>
                              setState(() => task["done"] = v),
                        ),
                        if (task["done"])
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                setState(() => tasks.remove(task)),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        }).toList(),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.green,
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("Add Task"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: taskController,
                            decoration:
                                const InputDecoration(hintText: "Enter task"),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_month),
                          onPressed: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: taskDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2035),
                            );
                            if (picked != null) {
                              setState(() => taskDate = picked);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Task date: ${taskDate.day}/${taskDate.month}/${taskDate.year}",
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      addTask();
                      Navigator.pop(context);
                    },
                    child: const Text("ADD"),
                  ),
                ],
              ),
            );
          },
          child: const Text("ADD TASK",
              style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}
