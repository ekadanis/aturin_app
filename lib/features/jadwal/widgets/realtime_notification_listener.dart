import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/aktivitas_service.dart';
import '../model/aktivitas_model.dart';

class RealtimeNotificationListener extends StatefulWidget {
  final Widget child;
  
  const RealtimeNotificationListener({
    super.key,
    required this.child,
  });

  @override
  State<RealtimeNotificationListener> createState() => _RealtimeNotificationListenerState();
}

class _RealtimeNotificationListenerState extends State<RealtimeNotificationListener> {
  List<AktivitasModel> _previousData = [];
  bool _isFirstLoad = true;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AktivitasModel>>(
      stream: Provider.of<AktivitasService>(context, listen: false).aktivitasStream,
      builder: (context, snapshot) {
        if (snapshot.hasData && !_isFirstLoad) {
          final currentData = snapshot.data!;
          
          // Check for new activities
          final newActivities = currentData.where((current) {
            return !_previousData.any((previous) => previous.id == current.id);
          }).toList();
          
          // Check for updated activities
          final updatedActivities = currentData.where((current) {
            final previous = _previousData.where((p) => p.id == current.id).firstOrNull;
            return previous != null && previous.updatedAt != current.updatedAt;
          }).toList();
          
          // Check for deleted activities
          final deletedCount = _previousData.where((previous) {
            return !currentData.any((current) => current.id == previous.id);
          }).length;
          
          // Show notifications
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (newActivities.isNotEmpty) {
              _showUpdateNotification(
                context, 
                '${newActivities.length} aktivitas baru ditambahkan',
                Colors.green,
              );
            }
            
            if (updatedActivities.isNotEmpty) {
              _showUpdateNotification(
                context, 
                '${updatedActivities.length} aktivitas diperbarui',
                Colors.blue,
              );
            }
            
            if (deletedCount > 0) {
              _showUpdateNotification(
                context, 
                '$deletedCount aktivitas dihapus',
                Colors.orange,
              );
            }
          });
          
          _previousData = List.from(currentData);
        } else if (snapshot.hasData && _isFirstLoad) {
          _previousData = List.from(snapshot.data!);
          _isFirstLoad = false;
        }
        
        return widget.child;
      },
    );
  }
  
  void _showUpdateNotification(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.sync, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(message, style: const TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
