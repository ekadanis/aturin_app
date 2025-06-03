import 'package:flutter/material.dart';
import 'package:aturin_app/core/services/api/task/task_api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('====== CALENDAR TASK DATA ANALYSIS ======');
  
  final taskApiService = TaskApiService();
  
  try {
    print('🔄 Fetching ALL tasks...');
    final allTasks = await taskApiService.getAllTasks();
    
    print('✅ All tasks count: ${allTasks.length}');
    
    print('🔄 Fetching UNCOMPLETED tasks for today...');
    final uncompletedTasks = await taskApiService.getUncompletedTasksToday();
    
    print('✅ Uncompleted tasks today count: ${uncompletedTasks.length}');
    
    print('\n📊 COMPARISON:');
    print('All tasks: ${allTasks.length}');
    print('Uncompleted today: ${uncompletedTasks.length}');
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Find today's tasks in all tasks
    final todayTasksFromAll = allTasks.where((task) {
      final taskDate = DateTime(task.deadline.year, task.deadline.month, task.deadline.day);
      return taskDate.isAtSameMomentAs(today);
    }).toList();
    
    print('Today\'s tasks from all tasks: ${todayTasksFromAll.length}');
    
    print('\n🔍 TODAY\'S TASKS ANALYSIS:');
    print('From getAllTasks():');
    for (var task in todayTasksFromAll) {
      print('  - ${task.title} (${task.taskStatus}, completed: ${task.isCompleted})');
    }
    
    print('\nFrom getUncompletedTasksToday():');
    for (var task in uncompletedTasks) {
      print('  - ${task.title} (${task.taskStatus}, completed: ${task.isCompleted})');
    }
    
    print('\n⚠️ CALENDAR YELLOW DOT ISSUE:');
    print('Calendar uses taskApiService.tasks which contains:');
    print('- When today is selected: ${uncompletedTasks.length} tasks (uncompleted only)');
    print('- When other dates selected: ${allTasks.length} tasks (all tasks)');
    print('This inconsistency causes yellow dots to not update properly!');
    
    // Test calendar logic simulation
    print('\n🎯 CALENDAR DOT LOGIC SIMULATION:');
    
    // Simulate today with uncompleted tasks data
    final hasTodayDotsUncompleted = uncompletedTasks.any((task) {
      final taskDate = DateTime(task.deadline.year, task.deadline.month, task.deadline.day);
      return taskDate.isAtSameMomentAs(today);
    });
    
    // Simulate today with all tasks data
    final hasTodayDotsAll = allTasks.any((task) {
      final taskDate = DateTime(task.deadline.year, task.deadline.month, task.deadline.day);
      return taskDate.isAtSameMomentAs(today);
    });
    
    print('Calendar dots for today using uncompleted data: ${hasTodayDotsUncompleted ? 'YES' : 'NO'}');
    print('Calendar dots for today using all tasks data: ${hasTodayDotsAll ? 'YES' : 'NO'}');
    
    if (hasTodayDotsUncompleted != hasTodayDotsAll) {
      print('❌ INCONSISTENCY DETECTED! This explains the yellow dot bug.');
    } else {
      print('✅ No inconsistency detected in this test.');
    }
    
  } catch (e) {
    print('❌ ERROR: $e');
  }
  
  print('====== TEST COMPLETED ======');
}
