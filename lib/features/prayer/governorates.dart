class IraqGovernorate {
  final String name;
  final double latitude;
  final double longitude;

  const IraqGovernorate({
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}

class IraqGovernorates {
  static const List<IraqGovernorate> list = [
    IraqGovernorate(name: 'بغداد', latitude: 33.3152, longitude: 44.3661),
    IraqGovernorate(name: 'النجف الأشرف', latitude: 31.9996, longitude: 44.3384),
    IraqGovernorate(name: 'كربلاء المقدسة', latitude: 32.6149, longitude: 44.0245),
    IraqGovernorate(name: 'البصرة', latitude: 30.5085, longitude: 47.7835),
    IraqGovernorate(name: 'الموصل', latitude: 36.3350, longitude: 43.1189),
    IraqGovernorate(name: 'أربيل', latitude: 36.1911, longitude: 44.0092),
    IraqGovernorate(name: 'السليمانية', latitude: 35.5550, longitude: 45.4329),
    IraqGovernorate(name: 'كركوك', latitude: 35.4681, longitude: 44.3922),
    IraqGovernorate(name: 'الأنبار', latitude: 33.4235, longitude: 43.2755),
    IraqGovernorate(name: 'ديالى', latitude: 33.7505, longitude: 45.1667),
    IraqGovernorate(name: 'صلاح الدين', latitude: 34.1954, longitude: 43.6774),
    IraqGovernorate(name: 'نينوى', latitude: 36.3350, longitude: 43.1189),
    IraqGovernorate(name: 'ذي قار', latitude: 31.0586, longitude: 46.2560),
    IraqGovernorate(name: 'القادسية', latitude: 31.9917, longitude: 44.9333),
    IraqGovernorate(name: 'بابل', latitude: 32.4653, longitude: 44.5236),
    IraqGovernorate(name: 'ميسان', latitude: 31.8420, longitude: 47.1471),
    IraqGovernorate(name: 'المثنى', latitude: 29.9667, longitude: 45.2833),
    IraqGovernorate(name: 'واسط', latitude: 32.4833, longitude: 45.7667),
  ];
}
