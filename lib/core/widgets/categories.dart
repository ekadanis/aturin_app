import 'package:flutter/material.dart';
import 'package:aturin_app/core/theme/app_theme.dart';

class CategoryOption {
  final String name;
  final String iconPath;
  final Color textColor;
  final Color backgroundColor;

  const CategoryOption({
    required this.name,
    required this.iconPath,
    required this.textColor,
    required this.backgroundColor,
  });
}

final List<CategoryOption> categories = [
  CategoryOption(
    name: 'Akademik', 
    iconPath: 'assets/images/akademik.svg',
    textColor: AppTheme.akademikText,
    backgroundColor: AppTheme.akademikBackground,
  ),
  CategoryOption(
    name: 'Hiburan',
    iconPath: 'assets/images/hiburan.svg',
    textColor: AppTheme.hiburanText,
    backgroundColor: AppTheme.hiburanBackground,
  ),
  CategoryOption(
    name: 'Pekerjaan', 
    iconPath: 'assets/images/pekerjaan.svg',
    textColor: AppTheme.pekerjaanText,
    backgroundColor: AppTheme.pekerjaanBackground,
  ),
  CategoryOption(
    name: 'Olahraga', 
    iconPath: 'assets/images/olahraga.svg',
    textColor: AppTheme.olahragaText,
    backgroundColor: AppTheme.olahragaBackground,
  ),
  CategoryOption(
    name: 'Sosial', 
    iconPath: 'assets/images/sosial.svg',
    textColor: AppTheme.sosialText,
    backgroundColor: AppTheme.sosialBackground,
  ),
  CategoryOption(
    name: 'Spiritual', 
    iconPath: 'assets/images/spiritual.svg',
    textColor: AppTheme.spiritualText,
    backgroundColor: AppTheme.spiritualBackground,
  ),
  CategoryOption(
    name: 'Pribadi', 
    iconPath: 'assets/images/pribadi.svg',
    textColor: AppTheme.pribadiText,
    backgroundColor: AppTheme.pribadiBackground,
  ),
  CategoryOption(
    name: 'Istirahat', 
    iconPath: 'assets/images/istirahat.svg',
    textColor: AppTheme.istirahatText,
    backgroundColor: AppTheme.istirahatBackground,
  ),
];
