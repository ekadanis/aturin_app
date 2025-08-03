import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:aturin_app/core/services/api/profile/profile_service.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart'; // Added import
import 'package:aturin_app/features/alarm/services/alarm_service.dart';

class PengaturanCard extends StatefulWidget {
  final String title;
  final String description;

  const PengaturanCard({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  _PengaturanCardState createState() => _PengaturanCardState();
}

class _PengaturanCardState extends State<PengaturanCard> {
  bool _isAlarmEnabled = false;
  bool _isLoading = false;
  bool _isInitialized = false;
  final ProfileService _profileService = ProfileService();
  final AlarmService _alarmService = AlarmService();

  @override
  void initState() {
    super.initState();
    // Hanya load alarm status sekali saat pertama kali inisialisasi
    if (!_isInitialized) {
      _loadAlarmStatus();
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadAlarmStatus() async {
    // Hanya set loading jika benar-benar pertama kali load
    if (!_isInitialized) {
      setState(() => _isLoading = true);
    }
    
    try {
      final isEnabled = await _profileService.getGlobalAlarmStatus();
      if (mounted) {
        setState(() {
          _isAlarmEnabled = isEnabled ?? false;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading alarm status: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleGlobalAlarm(bool value) async {
    // Langsung update UI tanpa loading indicator
    setState(() {
      _isAlarmEnabled = value;
    });
    
    try {
      // Panggil sinkronisasi ke AlarmService di background
      await _alarmService.setGlobalAlarmEnabled(value);
    } catch (e) {
      debugPrint('Error toggling global alarm: $e');
      // Jika error, kembalikan ke nilai sebelumnya
      if (mounted) {
        setState(() {
          _isAlarmEnabled = !value; // Kembalikan ke nilai sebelumnya
        });
        
        // Tampilkan error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengubah pengaturan alarm'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
     return Card(
      color: AppTheme.lightCardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppTheme.lightDividerColor, 
          width: 1,
        ),
      ),
      //margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTextColor,
                  ),
                ),
                Text(
                  widget.description,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: AppTheme.upcomingTextColor,
                  ),
                ),
              ],
            ),

            RepaintBoundary(
              child: _isLoading 
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.primaryColor,
                    ),
                  )
                : AnimatedToggleSwitch<bool>.rolling(
                    current: _isAlarmEnabled,
                    values: const [false, true],
                    onChanged: (value) {
                      // Langsung toggle tanpa loading berputar
                      _toggleGlobalAlarm(value);
                    },
                    iconBuilder: (value, size) {
                      return value 
                        ? Icon(
                            Icons.alarm_on_rounded,
                            size: 18,
                            color: Colors.white,
                          )
                        : Icon(
                            Icons.alarm_off_rounded,
                            size: 18,
                            color: Colors.grey.shade700,
                          );
                    },
                    borderWidth: 3.0,
                    height: 36,
                    animationDuration: const Duration(milliseconds: 100),
                    animationCurve: Curves.fastLinearToSlowEaseIn,
                    style: ToggleStyle(
                      indicatorColor: _isAlarmEnabled ? AppTheme.primaryColor : const Color(0xFFE5E7EA),
                      backgroundColor: _isAlarmEnabled ? AppTheme.primaryColor.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                      borderColor: Colors.transparent,
                      borderRadius: BorderRadius.circular(24.0),
                      boxShadow: [
                        const BoxShadow(
                          color: Colors.black12,
                          spreadRadius: 0.5,
                          blurRadius: 1.0,
                          offset: Offset(0, 1.0),
                        ),
                      ],
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
