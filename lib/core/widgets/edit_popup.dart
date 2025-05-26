import 'package:aturin_app/core/widgets/delete_pop_up.dart';
import 'package:aturin_app/core/widgets/popup_items.dart';
import 'package:aturin_app/features/task/models/task_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_route/auto_route.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:popover/popover.dart';

import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:aturin_app/routers/app_router.dart';
import 'package:aturin_app/core/utils/debouncer.dart';
import 'package:aturin_app/features/task/services/task_services.dart';
import 'package:aturin_app/features/task/ui/widgets/task_card.dart';
import 'package:path/path.dart';

class EditPopup extends StatelessWidget {
  final int currentIndex;
  final Task task;

  const EditPopup({
    super.key,
    required this.currentIndex, required this.task,
  });

  @override
  Widget build(BuildContext context) {
    final task = TaskService().tasks[currentIndex];
    return GestureDetector(
      onTap: () => showPopover(
        context: context, 
        bodyBuilder: (context) => PopupItems(currentIndex: currentIndex, task: task),
      ),
    );
    
  }
}

