// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:aturin_app/features/home/providers/home_widget_provider.dart';
// import 'package:aturin_app/features/home/services/home_widget_service.dart';

// /// Widget test page untuk test dan debug home widget
// class WidgetTestPage extends StatefulWidget {
//   const WidgetTestPage({Key? key}) : super(key: key);

//   @override
//   State<WidgetTestPage> createState() => _WidgetTestPageState();
// }

// class _WidgetTestPageState extends State<WidgetTestPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Widget Test & Debug'),
//         backgroundColor: const Color(0xFF5263F3),
//         foregroundColor: Colors.white,
//       ),
//       body: Consumer<HomeWidgetProvider>(
//         builder: (context, provider, child) {
//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // Status info
//                 Card(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Widget Status',
//                           style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         _buildStatusRow('Initialized', provider.isInitialized),
//                         _buildStatusRow('Updating', provider.isUpdating),
//                         if (provider.lastUpdate != null)
//                           Text('Last Update: ${provider.lastUpdate.toString()}'),
//                         if (provider.error != null)
//                           Text('Error: ${provider.error}', 
//                                style: const TextStyle(color: Colors.red)),
//                       ],
//                     ),
//                   ),
//                 ),
                
//                 const SizedBox(height: 16),
                
//                 // Test buttons
//                 Text(
//                   'Widget Tests',
//                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
                
//                 const SizedBox(height: 8),
                
//                 ElevatedButton(
//                   onPressed: provider.isUpdating ? null : () async {
//                     debugPrint('🧪 Testing widget with real data...');
                    
//                     // Sample real data format (ganti dengan data API Anda)
//                     final sampleActivities = [
//                       {
//                         'id': '1',
//                         'name': 'Meeting Tim Proyek',
//                         'date': DateTime.now().toIso8601String(),
//                         'time': '08:00',
//                       }
//                     ];
                    
//                     final sampleTasks = <Map<String, dynamic>>[];
                    
//                     await provider.updateWithRealData(
//                       activities: sampleActivities,
//                       tasks: sampleTasks,
//                     );
                    
//                     // Show confirmation
//                     if (context.mounted) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text('Widget updated with ${sampleActivities.length} activities, ${sampleTasks.length} tasks!'),
//                           backgroundColor: const Color(0xFF5263F3),
//                         ),
//                       );
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF5263F3),
//                     foregroundColor: Colors.white,
//                   ),
//                   child: const Text('Update Widget dengan Data Real'),
//                 ),
                
//                 const SizedBox(height: 8),
                
//                 ElevatedButton(
//                   onPressed: provider.isUpdating ? null : () async {
//                     debugPrint('🔄 Force refresh widget...');
//                     await provider.forceRefresh();
                    
//                     if (context.mounted) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text('Widget force refreshed'),
//                           backgroundColor: Colors.blue,
//                         ),
//                       );
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue,
//                     foregroundColor: Colors.white,
//                   ),
//                   child: const Text('Force Refresh Widget'),
//                 ),
                
//                 const SizedBox(height: 16),
                
//                 // Widget data preview
//                 if (provider.lastWidgetData != null) ...[
//                   Text(
//                     'Last Widget Data',
//                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Card(
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('Date: ${provider.lastWidgetData!['date'] ?? 'N/A'}'),
//                           Text('Total Items: ${provider.lastWidgetData!['totalItems'] ?? 0}'),
//                           Text('Activities: ${provider.lastWidgetData!['totalActivities'] ?? 0}'),
//                           Text('Tasks: ${provider.lastWidgetData!['totalTasks'] ?? 0}'),
//                           Text('Is Empty: ${provider.lastWidgetData!['isEmpty'] ?? true}'),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
                
//                 const SizedBox(height: 16),
                
//                 // Instructions
//                 Card(
//                   color: Colors.blue.shade50,
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Instructions',
//                           style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         const Text('1. Tap "Update Widget with Sample Data" to test the widget UI'),
//                         const Text('2. Go to home screen and add Aturin widget if not already added'),
//                         const Text('3. The widget should show 3 sample items with titles, times, and categories'),
//                         const Text('4. Use "Update Widget with Real Data" to show actual schedule'),
//                         const Text('5. Check debug console for detailed logs'),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildStatusRow(String label, bool status) {
//     return Row(
//       children: [
//         Text('$label: '),
//         Icon(
//           status ? Icons.check_circle : Icons.cancel,
//           color: status ? Colors.green : Colors.red,
//           size: 16,
//         ),
//         const SizedBox(width: 4),
//         Text(status ? 'Yes' : 'No'),
//       ],
//     );
//   }
// }
