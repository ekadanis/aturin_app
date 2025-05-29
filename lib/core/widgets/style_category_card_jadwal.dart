import 'package:flutter/material.dart';

class CategoryOptionJadwal {
  final String name;
  final String iconPath;
  final Color color;
  final String iconChip;

  const CategoryOptionJadwal({
    required this.name,
    required this.iconPath,
    required this.color,
    required this.iconChip,
  });
}

const List<CategoryOptionJadwal> categories = [
  CategoryOptionJadwal(
    name: 'Akademik',
    iconPath: 'assets/activitycategory/iconcard/akademik.png',
    iconChip: 'assets/activitycategory/chipicon/akademik.svg',
    color: Color(0xFF3498DB),
  ),
  CategoryOptionJadwal(
    name: 'Hiburan',
    iconPath: 'assets/activitycategory/iconcard/hiburan.png',
    iconChip: 'assets/activitycategory/chipicon/hiburan.svg',
    color: Color(0xFF9B59B6),
  ),
  CategoryOptionJadwal(
    name: 'Pekerjaan',
    iconPath: 'assets/activitycategory/iconcard/pekerjaan.png',
    iconChip: 'assets/activitycategory/chipicon/pekerjaan.svg',
    color: Color(0xFF8E5C42),
  ),
  CategoryOptionJadwal(
    name: 'Olahraga',
    iconPath: 'assets/activitycategory/iconcard/olahraga.png',
    iconChip: 'assets/activitycategory/chipicon/olahraga.svg',
    color: Color(0xFFE74C3C),
  ),
  CategoryOptionJadwal(
    name: 'Sosial',
    iconPath: 'assets/activitycategory/iconcard/sosial.png',
    iconChip: 'assets/activitycategory/chipicon/sosial.svg',
    color: Color(0xFFE67E22),
  ),
  CategoryOptionJadwal(
    name: 'Spiritual',
    iconPath: 'assets/activitycategory/iconcard/spiritual.png',
    iconChip: 'assets/activitycategory/chipicon/spiritual.svg',
    color: Color(0xFF27AE60),
  ),
  CategoryOptionJadwal(
    name: 'Pribadi',
    iconPath: 'assets/activitycategory/iconcard/pribadi.png',
    iconChip: 'assets/activitycategory/chipicon/pribadi.svg',
    color: Color(0xFFF1C40F),
  ),
  CategoryOptionJadwal(
    name: 'Istirahat',
    iconPath: 'assets/activitycategory/iconcard/istirahat.png',
    iconChip: 'assets/activitycategory/chipicon/istirahat.svg',
    color: Color(0xFF283593),
  ),
];