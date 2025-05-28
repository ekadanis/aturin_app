import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class CategoryOption {
  final String name;
  final String iconPath;
  final Color color;

  const CategoryOption({
    required this.name,
    required this.iconPath,
    required this.color,
  });
}

const List<CategoryOption> categories = [
  CategoryOption(
    name: 'Akademik',
    iconPath: 'assets/images/akademik.svg',
    color: Color(0xFF3498DB),
  ),
  CategoryOption(
    name: 'Hiburan',
    iconPath: 'assets/images/hiburan.svg',
    color: Color(0xFF9B59B6),
  ),
  CategoryOption(
    name: 'Pekerjaan',
    iconPath: 'assets/images/pekerjaan.svg',
    color: Color(0xFFE74C3C),
  ),
  CategoryOption(
    name: 'Olahraga',
    iconPath: 'assets/images/olahraga.svg',
    color: Color(0xFFE74C3C),
  ),
  CategoryOption(
    name: 'Sosial',
    iconPath: 'assets/images/sosial.svg',
    color: Color(0xFFE67E22),
  ),
  CategoryOption(
    name: 'Spiritual',
    iconPath: 'assets/images/spiritual.svg',
    color: Color(0xFF27AE60),
  ),
  CategoryOption(
    name: 'Pribadi',
    iconPath: 'assets/images/pribadi.svg',
    color: Color(0xFFF1C40F),
  ),
  CategoryOption(
    name: 'Istirahat',
    iconPath: 'assets/images/istirahat.svg',
    color: Color(0xFF283593),
  ),
];
