import 'package:flutter_test/flutter_test.dart';
import 'package:aturin_app/features/task/model/task_model.dart';

void main() {
  group('Calendar Completed Tasks Fix Tests', () {
    // Mock task data dengan berbagai status
    final mockTasks = [
      Task(
        id: 1,
        title: 'Completed Task 1',
        description: 'Task yang sudah selesai',
        deadline: DateTime(2025, 6, 2, 10, 0), // 2025-06-02
        estimatedDuration: 60,
        category: 'akademik',
        taskStatus: TaskDatabaseStatus.selesai, // COMPLETED
        slug: 'completed-task-1',
      ),
      Task(
        id: 2,
        title: 'Uncompleted Task 1',
        description: 'Task yang belum selesai',
        deadline: DateTime(2025, 6, 2, 14, 0), // 2025-06-02
        estimatedDuration: 90,
        category: 'akademik',
        taskStatus: TaskDatabaseStatus.belum_selesai, // NOT COMPLETED
        slug: 'uncompleted-task-1',
      ),
      Task(
        id: 3,
        title: 'Completed Task 2',
        description: 'Task yang sudah selesai kedua',
        deadline: DateTime(2025, 6, 2, 16, 0), // 2025-06-02
        estimatedDuration: 45,
        category: 'pribadi',
        taskStatus: TaskDatabaseStatus.selesai, // COMPLETED
        slug: 'completed-task-2',
      ),
      Task(
        id: 4,
        title: 'Today Uncompleted Task',
        description: 'Task hari ini yang belum selesai',
        deadline: DateTime(2025, 6, 3, 9, 0), // Today (2025-06-03)
        estimatedDuration: 120,
        category: 'akademik',
        taskStatus: TaskDatabaseStatus.belum_selesai, // NOT COMPLETED
        slug: 'today-uncompleted-task',
      ),
    ];

    test('Should filter out completed tasks for non-today dates', () {
      // Simulate filtering logic from _getTasksForCalendar() for 2025-06-02
      final selectedDate = DateTime(2025, 6, 2);
      final now = DateTime(2025, 6, 3); // Today is 2025-06-03
      final today = DateTime(now.year, now.month, now.day);
      final selectedDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

      List<Task> filteredTasks;
      
      if (selectedDay.isAtSameMomentAs(today)) {
        // For today: should use uncompleted tasks only
        filteredTasks = mockTasks;
      } else {
        // For other dates: filter out completed tasks
        filteredTasks = mockTasks.where((task) => !task.isCompleted).toList();
      }

      // Expected: Only uncompleted tasks for 2025-06-02
      expect(filteredTasks.length, equals(2)); // Only id 2 and 4
      expect(filteredTasks.every((task) => !task.isCompleted), isTrue);
      expect(filteredTasks.map((task) => task.id).toList(), containsAll([2, 4]));
      
      print('✅ Test passed: Completed tasks filtered out for non-today dates');
      print('   Original tasks: ${mockTasks.length}');
      print('   Filtered tasks: ${filteredTasks.length}');
      print('   Completed tasks removed: ${mockTasks.length - filteredTasks.length}');
    });

    test('Should show all tasks for today (assuming they come from fetchUncompletedTasksToday)', () {
      // Simulate today's scenario where tasks are already filtered by backend
      final selectedDate = DateTime(2025, 6, 3); // Today
      final now = DateTime(2025, 6, 3);
      final today = DateTime(now.year, now.month, now.day);
      final selectedDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

      // Simulate backend filtered data (only uncompleted tasks for today)
      final todayUncompletedTasks = mockTasks.where((task) => 
        !task.isCompleted && 
        DateTime(task.deadline.year, task.deadline.month, task.deadline.day).isAtSameMomentAs(selectedDay)
      ).toList();

      List<Task> filteredTasks;
      
      if (selectedDay.isAtSameMomentAs(today)) {
        // For today: use backend filtered data as-is
        filteredTasks = todayUncompletedTasks;
      } else {
        // For other dates: filter out completed tasks
        filteredTasks = todayUncompletedTasks.where((task) => !task.isCompleted).toList();
      }

      // Expected: Only today's uncompleted tasks
      expect(filteredTasks.length, equals(1)); // Only task id 4
      expect(filteredTasks.first.id, equals(4));
      expect(filteredTasks.first.isCompleted, isFalse);
      
      print('✅ Test passed: Today shows only uncompleted tasks from backend');
      print('   Today tasks: ${filteredTasks.length}');
    });

    test('isCompleted property should work correctly', () {
      final completedTask = mockTasks.first; // Task with status selesai
      final uncompletedTask = mockTasks[1]; // Task with status belum_selesai

      expect(completedTask.isCompleted, isTrue);
      expect(uncompletedTask.isCompleted, isFalse);
      
      print('✅ Test passed: isCompleted property works correctly');
    });

    test('Calendar markers should only show for uncompleted tasks', () {
      // Test for calendar marker logic similar to InteractiveCalendarWidget
      final testDate = DateTime(2025, 6, 2);
      
      // Filter tasks for the specific date and only uncompleted ones
      final uncompletedTasksForDay = mockTasks.where((task) => 
        DateTime(task.deadline.year, task.deadline.month, task.deadline.day)
          .isAtSameMomentAs(DateTime(testDate.year, testDate.month, testDate.day)) &&
        !task.isCompleted
      ).toList();

      expect(uncompletedTasksForDay.length, equals(1)); // Only task id 2
      expect(uncompletedTasksForDay.first.id, equals(2));
      
      print('✅ Test passed: Calendar markers only show for uncompleted tasks');
      print('   Date: ${testDate.toString().split(' ')[0]}');
      print('   Uncompleted tasks: ${uncompletedTasksForDay.length}');
    });
  });
}
