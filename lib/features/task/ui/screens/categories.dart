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
  CategoryOption(name: 'Akademik', iconPath: 'assets/images/akademik.svg', color: Colors.blue),
  CategoryOption(name: 'Hiburan', iconPath: 'assets/images/hiburan.svg', color: Colors.purple),
  CategoryOption(name: 'Pekerjaan', iconPath: 'assets/images/pekerjaan.svg', color: Colors.brown),
  CategoryOption(name: 'Olahraga', iconPath: 'assets/images/olahraga.svg', color: Colors.red),
  CategoryOption(name: 'Sosial', iconPath: 'assets/images/sosial.svg', color: Colors.orange),
  CategoryOption(name: 'Spiritual', iconPath: 'assets/images/spiritual.svg', color: Colors.green),
  CategoryOption(name: 'Pribadi', iconPath: 'assets/images/pribadi.svg', color: Colors.amber),
  CategoryOption(name: 'Istirahat', iconPath: 'assets/images/istirahat.svg', color: Colors.indigo),
];
