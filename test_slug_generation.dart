// Test script to verify slug generation logic
import 'dart:io';
import 'lib/features/jadwal/services/aktivitas_service.dart';
import 'lib/features/jadwal/model/aktivitas_model.dart';

void main() async {
  print('Testing slug generation logic...');
  
  // Test slug generation for same titles
  final service = AktivitasService();
  
  try {
    // Create test activities with the same title
    final testActivity = AktivitasModel(
      id: null,
      userId: 1,
      activityTitle: 'aaa',
      activityDate: DateTime.now(),
      activityStartTime: DateTime.now(),
      activityCompleteTime: DateTime.now().add(Duration(hours: 1)),
      activityCategory: ActivityCategory.akademik,
      alarmId: null,
      slug: null,
    );
    
    print('Attempting to create multiple activities with title "aaa"...');
    
    // First activity
    final slug1 = await service.addAktivitas(testActivity, null);
    print('First activity slug: $slug1');
    
    // Second activity with same title
    final slug2 = await service.addAktivitas(testActivity, null);
    print('Second activity slug: $slug2');
    
    // Third activity with same title
    final slug3 = await service.addAktivitas(testActivity, null);
    print('Third activity slug: $slug3');
    
    if (slug1 != null && slug2 != null && slug3 != null) {
      if (slug1 != slug2 && slug2 != slug3 && slug1 != slug3) {
        print('✅ SUCCESS: All slugs are unique!');
        print('Slugs generated: [$slug1, $slug2, $slug3]');
      } else {
        print('❌ FAIL: Duplicate slugs found');
        print('Slugs generated: [$slug1, $slug2, $slug3]');
      }
    } else {
      print('❌ FAIL: Some activities failed to create');
      print('Slugs generated: [$slug1, $slug2, $slug3]');
    }
    
  } catch (e) {
    print('❌ ERROR during testing: $e');
  }
}
