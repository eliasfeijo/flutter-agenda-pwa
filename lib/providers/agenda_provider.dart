import 'package:flutter/foundation.dart';
import 'package:todo_flutter/models/task.dart';
import 'package:todo_flutter/repositories/tasks_repository.dart';

class AgendaProvider extends ChangeNotifier {
  // Private fields
  final TasksRepository _repository;

  final List<TaskModel> _tasks = [];
  TaskModel? _selectedTask;
  String _searchQuery = '';
  TaskFilter _currentFilter = TaskFilter.all;

  // Constructor
  AgendaProvider(this._repository);

  // Getters
  List<TaskModel> get tasks => List.unmodifiable(_tasks);
  TaskModel? get selectedTask => _selectedTask;
  String get searchQuery => _searchQuery;
  TaskFilter get currentFilter => _currentFilter;

  // Computed getters
  List<TaskModel> get filteredTasks {
    var filtered = _tasks.where((task) {
      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        if (!task.title.toLowerCase().contains(_searchQuery.toLowerCase())) {
          return false;
        }
      }

      // Apply status filter
      switch (_currentFilter) {
        case TaskFilter.completed:
          return task.isCompleted;
        case TaskFilter.pending:
          return !task.isCompleted;
        case TaskFilter.today:
          return task.isToday;
        case TaskFilter.upcoming:
          return task.isUpcoming && !task.isToday;
        case TaskFilter.overdue:
          return task.isOverdue;
        case TaskFilter.all:
          return true;
      }
    }).toList();

    // Sort by beginDate (earliest first)
    filtered.sort((a, b) => a.beginsAt.compareTo(b.beginsAt));
    return filtered;
  }

  bool get hasSelectedTask => _selectedTask != null;
  bool get isTaskSelected => _selectedTask != null;

  int get totalTasks => _tasks.length;
  int get completedTasksCount =>
      _tasks.where((task) => task.isCompleted).length;
  int get pendingTasksCount => _tasks.where((task) => !task.isCompleted).length;
  int get todayTasksCount => _tasks.where((task) => task.isToday).length;
  int get overdueTasksCount => _tasks.where((task) => task.isOverdue).length;

  // Setters

  // Sets the list of tasks and notifies listeners.
  set tasks(List<TaskModel> tasks) {
    _tasks.clear();
    _tasks.addAll(tasks);
    notifyListeners();
  }

  // Methods

  // Loading from repository
  Future<void> loadTasks() async {
    final storedTasks = await _repository.loadTasks();
    _tasks
      ..clear()
      ..addAll(storedTasks);
    notifyListeners();
  }

  // Task Management Methods
  Future<void> addTask(TaskModel task) async {
    _tasks.add(task);
    await _repository.saveTasks(_tasks);
    notifyListeners();
  }

  Future<void> updateTask(TaskModel updatedTask) async {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      await _repository.saveTasks(_tasks);
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((task) => task.id == taskId);
    if (_selectedTask?.id == taskId) {
      _selectedTask = null; // Clear selection if deleted task was selected
    }
    await _repository.saveTasks(_tasks);
    notifyListeners();
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      _tasks[index].toggleCompletion();
      await _repository.saveTasks(_tasks);
      notifyListeners();
    }
  }

  Future<void> clearAllTasks() async {
    _tasks.clear();
    await _repository.clearTasks();
    notifyListeners();
  }

  // Selected Task Management
  void selectTask(TaskModel task) {
    _selectedTask = task;
    notifyListeners();
  }

  void selectTaskById(String taskId) {
    final task = _tasks.firstWhere(
      (task) => task.id == taskId,
      orElse: () => throw ArgumentError('Task with id $taskId not found'),
    );
    selectTask(task);
  }

  void clearSelection() {
    _selectedTask = null;
    notifyListeners();
  }

  void selectNextTask() {
    if (_selectedTask == null || _tasks.isEmpty) return;

    final currentIndex = _tasks.indexWhere(
      (task) => task.id == _selectedTask!.id,
    );
    if (currentIndex != -1 && currentIndex < _tasks.length - 1) {
      _selectedTask = _tasks[currentIndex + 1];
      notifyListeners();
    }
  }

  void selectPreviousTask() {
    if (_selectedTask == null || _tasks.isEmpty) return;

    final currentIndex = _tasks.indexWhere(
      (task) => task.id == _selectedTask!.id,
    );
    if (currentIndex > 0) {
      _selectedTask = _tasks[currentIndex - 1];
      notifyListeners();
    }
  }

  // Search and Filter Methods
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  void setFilter(TaskFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  void clearFilter() {
    _currentFilter = TaskFilter.all;
    notifyListeners();
  }

  // Bulk Operations
  void markAllAsCompleted() {
    for (var task in _tasks) {
      if (!task.isCompleted) {
        task.toggleCompletion();
      }
    }
    notifyListeners();
  }

  void clearCompletedTasks() {
    // final completedTaskIds = _tasks
    //     .where((task) => task.isCompleted)
    //     .map((task) => task.id)
    //     .toList();

    // Clear selection if selected task is completed
    if (_selectedTask?.isCompleted == true) {
      _selectedTask = null;
    }

    _tasks.removeWhere((task) => task.isCompleted);
    notifyListeners();
  }

  // Utility Methods
  TaskModel? getTaskById(String id) {
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }

  bool isTaskInFiltered(String taskId) {
    return filteredTasks.any((task) => task.id == taskId);
  }

  // Debug helper
  void printTasks() {
    debugPrint('=== AGENDA DEBUG ===');
    debugPrint('Total tasks: ${_tasks.length}');
    debugPrint('Selected task: ${_selectedTask?.title ?? 'None'}');
    debugPrint('Current filter: $_currentFilter');
    debugPrint('Search query: "$_searchQuery"');
    debugPrint('Filtered tasks: ${filteredTasks.length}');
    for (var task in _tasks) {
      debugPrint('- ${task.title} (${task.isCompleted ? 'Done' : 'Pending'})');
    }
    debugPrint('==================');
  }

  // Refresh method
  void refresh() {
    // This method can be used to trigger a UI refresh if needed
    notifyListeners();
  }
}
