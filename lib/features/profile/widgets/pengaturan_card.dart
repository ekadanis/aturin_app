import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:aturin_app/features/alarm/services/alarm_service.dart';
import 'package:aturin_app/features/task/services/task_services.dart';
import 'package:provider/provider.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart'; // Added import

class PengaturanCard extends StatefulWidget {
  final String Title;
  final String Description;

  const PengaturanCard({
    super.key,
    required this.Title,
    required this.Description,
  });

  @override
  _PengaturanCardState createState() => _PengaturanCardState();
}

class _PengaturanCardState extends State<PengaturanCard> with SingleTickerProviderStateMixin {
  bool _isAlarmEnabled = false;
  bool _isLoading = false;
  bool _isAnimating = false;
  final AlarmService _alarmService = AlarmService();
  late AnimationController _animationController;
  bool _nextValue = false;
  bool _pendingValueChange = false;

  @override
  void initState() {
    super.initState();
    _loadAlarmStatus();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_pendingValueChange) {
          // Jika ada perubahan nilai tertunda, terapkan setelah animasi selesai
          setState(() {
            _isAlarmEnabled = _nextValue;
            _isAnimating = false;
            _pendingValueChange = false;
          });
          _toggleGlobalAlarm(_nextValue);
        } else {
          setState(() {
            _isAnimating = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAlarmStatus() async {
    setState(() => _isLoading = true);
    
    try {
      // Periksa status alarm global dari shared preferences
      final isEnabled = await _alarmService.isGlobalAlarmEnabled();
      if (mounted) {
        setState(() {
          _isAlarmEnabled = isEnabled;
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
    setState(() => _isLoading = true);
    
    try {
      // Simpan status alarm global
      await _alarmService.setGlobalAlarmEnabled(value);
      
      // Dapatkan TaskService untuk memperbarui alarm
      final taskService = Provider.of<TaskService>(context, listen: false);
      
      if (value) {
        // Aktifkan semua alarm yang seharusnya aktif
        await taskService.enableAllAlarms();
      } else {
        // Nonaktifkan semua alarm
        await taskService.disableAllAlarms();
      }
      
      if (mounted) {
        setState(() {
          _isAlarmEnabled = value;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error toggling global alarm: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
      margin: const EdgeInsets.all(16),
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
                  widget.Title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTextColor,
                  ),
                ),
                Text(
                  widget.Description,
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
                      // Cek apakah sedang animasi, jika ya, abaikan toggle
                      if (_isAnimating) return;
                      
                      // Set animating ke true dan toggle alarm
                      setState(() {
                        _isAnimating = true;
                        _nextValue = value;
                        _pendingValueChange = true;
                      });
                      
                      _toggleGlobalAlarm(value);
                      
                      // Menunggu animasi selesai sebelum mengizinkan toggle lagi
                      Future.delayed(const Duration(milliseconds:300),() {
                        if (mounted) {
                          setState(() {
                            _isAnimating = false;
                          });
                        }
                      });
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
