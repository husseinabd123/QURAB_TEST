class Governorate {
  final String name;
  final List<City> cities;

  const Governorate({required this.name, required this.cities});
}

class City {
  final String name;
  final double latitude;
  final double longitude;

  const City({
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}

const iraqGovernorates = [
  Governorate(
    name: 'بغداد',
    cities: [
      City(name: 'بغداد', latitude: 33.3152, longitude: 44.3661),
    ],
  ),
  Governorate(
    name: 'النجف',
    cities: [
      City(name: 'النجف', latitude: 31.9985, longitude: 44.3310),
      City(name: 'الكوفة', latitude: 32.0150, longitude: 44.3930),
    ],
  ),
  Governorate(
    name: 'كربلاء',
    cities: [
      City(name: 'كربلاء', latitude: 32.6160, longitude: 44.0246),
      City(name: 'عين التمر', latitude: 32.5681, longitude: 43.3877),
    ],
  ),
  Governorate(
    name: 'البصرة',
    cities: [
      City(name: 'البصرة', latitude: 30.5085, longitude: 47.7804),
      City(name: 'الزبير', latitude: 30.3920, longitude: 47.7011),
    ],
  ),
  Governorate(
    name: 'نينوى',
    cities: [
      City(name: 'الموصل', latitude: 36.3350, longitude: 43.1189),
      City(name: 'تلعفر', latitude: 36.3762, longitude: 42.4498),
    ],
  ),
  Governorate(
    name: 'أربيل',
    cities: [
      City(name: 'أربيل', latitude: 36.1911, longitude: 44.0090),
      City(name: 'شقلاوة', latitude: 36.4058, longitude: 44.3051),
    ],
  ),
];
