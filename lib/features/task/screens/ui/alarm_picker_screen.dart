import 'package:flutter/material.dart';
import 'package:aturin_app/features/task/screens/widgets/alarm_picker_bottom.dart';
import 'package:google_fonts/google_fonts.dart';

class AlarmPickerScreen extends StatefulWidget {
  final String? selectedOption;

  const AlarmPickerScreen({Key? key, this.selectedOption}) : super(key: key);

  @override
  State<AlarmPickerScreen> createState() => _AlarmPickerScreenState();
}

class _AlarmPickerScreenState extends State<AlarmPickerScreen> {
  String? selectedAlarmOption;

  final List<AlarmOption> alarmOptions = [
    AlarmOption(id: 'on_time', title: 'Ketika batas waktu'),
    AlarmOption(id: '15_minutes', title: '15 menit sebelum batas waktu'),
    AlarmOption(id: '30_minutes', title: '30 menit sebelum batas waktu'),
    AlarmOption(id: '45_minutes', title: '45 menit sebelum batas waktu'),
    AlarmOption(id: '1_hour', title: '1 jam sebelum batas waktu'),
  ];

  @override
  void initState() {
    super.initState();
    selectedAlarmOption = widget.selectedOption;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(selectedAlarmOption),
        ),
        title: Text(
          'Alarm',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300, width: 1.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: alarmOptions.length,
                itemBuilder: (context, index) {
                  final option = alarmOptions[index];
                  return _buildAlarmOptionTile(option);
                },
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () async {
                  // Atur batas waktu maksimal alarm (misal, 1 jam sebelum deadline)
                  final now = DateTime.now();
                  final maxDateTime = now.add(
                    const Duration(days: 7),
                  ); // Ganti sesuai kebutuhan

                  final result = await showAlarmPickerBottomSheet(
                    context,
                    maxDateTime: maxDateTime,
                  );
                  if (result != null) {
                    // Kirim hasil custom ke parent, misal format: 'custom:<datetime>'
                    Navigator.of(
                      context,
                    ).pop('custom:${result.toIso8601String()}');
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300, width: 1.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kustom',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey.shade400,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlarmOptionTile(AlarmOption option) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedAlarmOption = option.id;
          });
          // Return the selected option immediately
          Navigator.of(context).pop(option.id);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  option.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        selectedAlarmOption == option.id
                            ? Colors.black
                            : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child:
                    selectedAlarmOption == option.id
                        ? Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black,
                            ),
                          ),
                        )
                        : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AlarmOption {
  final String id;
  final String title;

  AlarmOption({required this.id, required this.title});
}
