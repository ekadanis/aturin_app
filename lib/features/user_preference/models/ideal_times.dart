class IdealTimeOption {
  final String name;
  final String iconPath;

  const IdealTimeOption({
    required this.name,
    required this.iconPath,
  });
}

final List<IdealTimeOption> idealTimes = [
  IdealTimeOption(
    name: 'Pagi (06:00 - 10:00)', 
    iconPath: 'assets/icons/cloud-sunny.svg',
  ),
  IdealTimeOption(
    name: 'Siang (10:00 - 14:00)',
    iconPath: 'assets/icons/sun-light.svg',
  ),
  IdealTimeOption(
    name: 'Sore (14:00 - 18:00)', 
    iconPath: 'assets/icons/sea-and-sun.svg',
  ),
  IdealTimeOption(
    name: 'Malam (18:00 - 22:00)', 
    iconPath: 'assets/icons/half-moon.svg',
  ),
];
