class Task {
  String title;
  String description;
  DateTime date;
  bool done;
  String priority;

  Task({
    required this.title,
    required this.description,
    required this.date,
    this.done = false,
    this.priority = "Low",
  });

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "description": description,
      "date": date.toIso8601String(),
      "done": done,
      "priority": priority,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json["title"],
      description: json["description"] ?? "",
      date: DateTime.parse(json["date"]),
      done: json["done"] ?? false,
      priority: json["priority"] ?? "Low",
    );
  }
}
