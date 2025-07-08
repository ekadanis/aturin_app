import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ConfirmDiscardChangesDialog extends StatelessWidget {
  const ConfirmDiscardChangesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.w)),
      insetPadding: EdgeInsets.all(4.w),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 92.w),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_rounded,
                size: 15.w,
                color: Colors.red,
              ),
              SizedBox(height: 2.h),
              Text(
                'Batal menyimpan perubahan?',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 2.h),
              Text(
                'Perubahan yang belum disimpan akan hilang.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6D717F),
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 0.5.w,
                        ),
                        minimumSize: Size(double.infinity, 6.h),
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 1.5.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2.w),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: TextStyle(
                          fontSize: 17.5.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 6.h),
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 1.5.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2.w),
                        ),
                      ),
                      child: Text(
                        'Keluar',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17.5.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
