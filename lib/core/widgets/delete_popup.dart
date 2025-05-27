import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:aturin_app/features/task/models/task_model.dart';

class DeletePopup extends StatelessWidget {
  final int? id;
  final String category;
  final String title;

  const DeletePopup({
    super.key,
    required this.id,
    required this.category,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 328,
      height: 272,
      padding: const EdgeInsets.all(24),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: const Color(0xFFF9FAFB),
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1.50, color: const Color(0xFFF3F4F6)),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 24,
        children: [
          Container(
            width: 274,
            height: 48,
            child: Stack(
              children: [
                Positioned(
                  left: 116,
                  top: 0,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 2,
                          strokeAlign: BorderSide.strokeAlignOutside,
                          color: const Color(0xFFEE443F),
                        ),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 7,
                          top: 7,
                          child: Container(
                            width: 34,
                            height: 34,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(),
                            child: Stack(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 4,
              children: [
                SizedBox(
                  width: 280,
                  child: Text(
                    'Hapus ${_categoryHandler(category)}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(
                        0xFF131927,
                      ) /* Text-Color-text-primary-black */,
                      fontSize: 18,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w600,
                      height: 1.56,
                    ),
                  ),
                ),
                SizedBox(
                  width: 280,
                  child: Text(
                    'Yakin nih kamu mau hapus ${_categoryHandler(category)} “$title”?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(
                        0xFF6D717F,
                      ) /* Text-Color-text-secondary-dark-grey */,
                      fontSize: 16,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1.50,
                          color: const Color(0xFF4E61F6),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Batal',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color(
                                    0xFF4E61F6,
                                  ) /* Text-Color-text-accent */,
                                  fontSize: 16,
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.w600,
                                  height: 1.25,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFEE443F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Hapus',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color:
                                      Colors
                                          .white /* Text-Color-text-primary-white */,
                                  fontSize: 16,
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.w600,
                                  height: 1.25,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _categoryHandler(String category) {
    if(category == "akademik"){
      return "tugas";
    } else {
      return "jadwal";
    }
  }
}
