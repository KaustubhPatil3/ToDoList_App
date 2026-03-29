import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class StorageService {
  static const String key = "tasks";

  static Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final data = tasks.map((task) => task.toJson()).toList();
    await prefs.setString(key, jsonEncode(data));
  }

  static Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(key);

    if (data != null) {
      final List decoded = jsonDecode(data);
      return decoded.map((e) => Task.fromJson(e)).toList();
    }

    return [];
  }
}
