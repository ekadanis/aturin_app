import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:aturin_app/features/home/presentation/providers/home_widget_provider.dart';

/// Widget untuk menampilkan status dan kontrol Home Widget
class HomeWidgetControlCard extends StatelessWidget {
  const HomeWidgetControlCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeWidgetProvider>(
      builder: (context, provider, child) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: Colors.grey.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5263F3).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.widgets,
                      color: const Color(0xFF5263F3),
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Home Screen Widget',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        Text(
                          'Jadwal hari ini di layar utama',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status indicator
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: provider.isInitialized
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      provider.isInitialized ? 'Aktif' : 'Setup',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: provider.isInitialized
                            ? Colors.green[700]
                            : Colors.orange[700],
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 3.h),
              
              // Status Info
              if (provider.lastUpdate != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Terakhir diperbarui: ${_formatLastUpdate(provider.lastUpdate!)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
              ],
              
              // Widget Data Info
              if (provider.lastWidgetData != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.event_note,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      '${provider.lastWidgetData!['totalActivities'] ?? 0} aktivitas, ${provider.lastWidgetData!['totalTasks'] ?? 0} tugas',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
              ],
              
              // Error display
              if (provider.error != null) ...[
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red[700],
                        size: 18,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          provider.error!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: Colors.red[700],
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: provider.clearError,
                        icon: Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.red[700],
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.h),
              ],
              
              // Action buttons
              Row(
                children: [
                  // Initialize/Update button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: provider.isUpdating
                          ? null
                          : () async {
                              if (!provider.isInitialized) {
                                await provider.initialize();
                              } else {
                                await provider.forceRefresh();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5263F3),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: provider.isUpdating
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  'Memperbarui...',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              provider.isInitialized ? 'Perbarui Widget' : 'Setup Widget',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),
                  
                  SizedBox(width: 3.w),
                  
                  // Settings button
                  IconButton(
                    onPressed: () => _showWidgetSettings(context),
                    icon: Icon(
                      Icons.settings,
                      color: Colors.grey[600],
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.withOpacity(0.1),
                      padding: EdgeInsets.all(3.w),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatLastUpdate(DateTime lastUpdate) {
    final now = DateTime.now();
    final difference = now.difference(lastUpdate);
    
    if (difference.inMinutes < 1) {
      return 'baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else {
      return '${difference.inDays} hari lalu';
    }
  }

  void _showWidgetSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(5.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pengaturan Widget',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text(
                'Cara Menambah Widget',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                'Tekan dan tahan pada layar utama, pilih Widget, cari "Aturin"',
                style: GoogleFonts.plusJakartaSans(fontSize: 12),
              ),
              onTap: () => _showHowToAdd(context),
            ),
            
            ListTile(
              leading: Icon(Icons.refresh),
              title: Text(
                'Update Otomatis',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                'Widget diperbarui setiap 15 menit',
                style: GoogleFonts.plusJakartaSans(fontSize: 12),
              ),
            ),
            
            SizedBox(height: 3.h),
          ],
        ),
      ),
    );
  }

  void _showHowToAdd(BuildContext context) {
    Navigator.pop(context); // Close settings sheet
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Cara Menambah Widget',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStep('1.', 'Tekan dan tahan pada layar utama'),
            _buildStep('2.', 'Pilih "Widget" dari menu yang muncul'),
            _buildStep('3.', 'Cari "Aturin" dalam daftar widget'),
            _buildStep('4.', 'Drag widget ke layar utama'),
            _buildStep('5.', 'Widget akan menampilkan jadwal hari ini'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Mengerti',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF5263F3),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6.w,
            child: Text(
              number,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF5263F3),
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
