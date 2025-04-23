import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/task/ui/screens/home_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const myApp());
}

class myApp extends StatelessWidget{
  const myApp({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'Aturin',
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}