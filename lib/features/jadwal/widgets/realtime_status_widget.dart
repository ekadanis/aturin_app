import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/aktivitas_service.dart';

class RealtimeStatusWidget extends StatelessWidget {
  const RealtimeStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AktivitasService>(
      builder: (context, aktivitasService, child) {
        return StreamBuilder<List<dynamic>>(
          stream: aktivitasService.aktivitasStream,
          builder: (context, snapshot) {
            final isConnected = snapshot.connectionState == ConnectionState.active;
            
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isConnected ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isConnected ? Colors.green : Colors.orange,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isConnected ? Icons.wifi : Icons.wifi_off,
                    size: 12,
                    color: isConnected ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isConnected ? 'Live' : 'Offline',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isConnected ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
