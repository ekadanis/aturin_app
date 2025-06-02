import 'package:flutter/material.dart';
import 'package:aturin_app/core/services/api/task/task_api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('====== TEST UNCOMPLETED TASKS TODAY ======');
  
  final taskApiService = TaskApiService();
  
  try {
    print('🔄 Testing getUncompletedTasksToday...');
    final uncompletedTasks = await taskApiService.getUncompletedTasksToday();
    
    print('✅ SUCCESS: getUncompletedTasksToday');
    print('📊 Uncompleted tasks count: ${uncompletedTasks.length}');
    
    if (uncompletedTasks.isNotEmpty) {
      print('📋 Uncompleted tasks today:');
      for (int i = 0; i < uncompletedTasks.length; i++) {
        final task = uncompletedTasks[i];
        print('  ${i + 1}. ${task.title}');
        print('     Status: ${task.status}');
        print('     Deadline: ${task.deadline}');
        print('     Category: ${task.category}');
        print('');
      }
    } else {
      print('🎉 No uncompleted tasks today! All tasks are completed.');
    }
    
    print('🔄 Testing fetchUncompletedTasksToday...');
    await taskApiService.fetchUncompletedTasksToday();
    
    print('✅ SUCCESS: fetchUncompletedTasksToday');
    print('📊 Tasks in service after fetch: ${taskApiService.tasks.length}');
    
    // Compare results
    print('🔍 Comparing direct call vs service fetch:');
    print('  Direct call count: ${uncompletedTasks.length}');
    print('  Service fetch count: ${taskApiService.tasks.length}');
    
    if (uncompletedTasks.length == taskApiService.tasks.length) {
      print('✅ Both methods return same count - CONSISTENT!');
    } else {
      print('⚠️ Different counts - might need investigation');
    }
    
  } catch (e) {
    print('❌ ERROR: $e');
    print('Stack trace:');
    print(e.toString());
  }
  
  print('====== TEST COMPLETED ======');
}
