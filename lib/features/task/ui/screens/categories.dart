import 'package:flutter/material.dart';

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
  CategoryOption(name: 'Akademik', iconPath: 'assets/icons/akademik.svg', color: Colors.blue),
  CategoryOption(name: 'Hiburan', iconPath: 'assets/icons/hiburan.svg', color: Colors.purple),
  CategoryOption(name: 'Pekerjaan', iconPath: 'assets/icons/pekerjaan.svg', color: Colors.brown),
  CategoryOption(name: 'Olahraga', iconPath: 'assets/icons/olahraga.svg', color: Colors.red),
  CategoryOption(name: 'Sosial', iconPath: 'assets/icons/sosial.svg', color: Colors.orange),
  CategoryOption(name: 'Spiritual', iconPath: 'assets/icons/spiritual.svg', color: Colors.green),
  CategoryOption(name: 'Pribadi', iconPath: 'assets/icons/pribadi.svg', color: Colors.amber),
  CategoryOption(name: 'Istirahat', iconPath: 'assets/icons/istirahat.svg', color: Colors.indigo),
];
