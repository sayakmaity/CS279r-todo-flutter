import 'package:flutter_todo_app/models/task.dart';
import 'package:flutter_todo_app/providers/database_provider.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final Rx<DateTime> _selectedDate = DateTime.now().obs;

  DateTime get selectedDate => _selectedDate.value;

  final Rx<List<Task>> _myTasks = Rx<List<Task>>([]);

  List<Task> get myTasks => _myTasks.value;

  @override
  void onInit() {
    super.onInit();
    getTasks();
  }

  /// It gets all the tasks from the database and assigns them to the _myTasks variable.
  getTasks() async {
    final List<Task> tasksFromDB = [];
    List<Map<String, dynamic>> tasks = await DatabaseProvider.queryTasks();
    tasksFromDB.assignAll(
        tasks.reversed.map((data) => Task().fromJson(data)).toList());
    _myTasks.value = tasksFromDB;
  }

  /// deletes a task
  Future<int> deleteTask(String id) async {
    return await DatabaseProvider.deleteTask(id);
  }

  /// updates a task
  Future<int> upDateTask(String id) async {
    return await DatabaseProvider.updateTask(id);
  }

  /// It updates the selected date.
  updateSelectedDate(DateTime date) {
    _selectedDate.value = date;
    getTasks();
  }
}
