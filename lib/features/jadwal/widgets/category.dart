import 'package:flutter/material.dart';

class CategoryOption {
  final String name;
  final String iconPath;
  final Color color;
  final String category;
  final String activity;

  const CategoryOption({
    required this.name,
    required this.iconPath,
    required this.color,
    required this.category,
    required this.activity,
  });
}

const List<CategoryOption> categories = [
  CategoryOption(
    name: 'Akademik',
    iconPath: 'assets/activitycategory/iconcard/akademik.png',
    color: Color(0xFF3498DB),
    category: 'assets/activitycategory/chip/akademik_detail.svg',
    activity: 'assets/activitycategory/chip/aktivitas_detail.svg',
  ),
  CategoryOption(
    name: 'Hiburan',
    iconPath: 'assets/activitycategory/iconcard/hiburan.png',
    color: Color(0xFF9B59B6),
    category: 'assets/activitycategory/chip/hiburan_detail.svg',
    activity: 'assets/activitycategory/chip/aktivitas_detail.svg',
  ),
  CategoryOption(
    name: 'Pekerjaan',
    iconPath: 'assets/activitycategory/iconcard/pekerjaan.png',
    color: Color(0xFF8E5C42),
    category: 'assets/activitycategory/chip/pekerjaan_detail.svg',
    activity: 'assets/activitycategory/chip/aktivitas_detail.svg',
  ),
  CategoryOption(
    name: 'Olahraga',
    iconPath: 'assets/activitycategory/iconcard/olahraga.png',
    color: Color(0xFFE74C3C),
    category: 'assets/activitycategory/chip/olahraga_detail.svg',
    activity: 'assets/activitycategory/chip/aktivitas_detail.svg',
  ),
  CategoryOption(
    name: 'Sosial',
    iconPath: 'assets/activitycategory/iconcard/sosial.png',
    color: Color(0xFFE67E22),
    category: 'assets/activitycategory/chip/sosial_detail.svg',
    activity: 'assets/activitycategory/chip/aktivitas_detail.svg',
  ),
  CategoryOption(
    name: 'Spiritual',
    iconPath: 'assets/activitycategory/iconcard/spiritual.png',
    color: Color(0xFF27AE60),
    category: 'assets/activitycategory/chip/spiritual_detail.svg',
    activity: 'assets/activitycategory/chip/aktivitas_detail.svg',
  ),
  CategoryOption(
    name: 'Pribadi',
    iconPath: 'assets/activitycategory/iconcard/pribadi.png',
    color: Color(0xFFF1C40F),
    category: 'assets/activitycategory/chip/pribadi_detail.svg',
    activity: 'assets/activitycategory/chip/aktivitas_detail.svg',
  ),
  CategoryOption(
    name: 'Istirahat',
    iconPath: 'assets/activitycategory/iconcard/istirahat.png',
    color: Color(0xFF283593),
    category: 'assets/activitycategory/chip/istirahat_detail.svg',
    activity: 'assets/activitycategory/chip/aktivitas_detail.svg',
  ),
];