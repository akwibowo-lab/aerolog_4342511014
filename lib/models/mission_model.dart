class DroneMission {
  final String id;
  final String title;
  final String location;
  final String droneModel;
  final String category; // Pemetaan, Inspeksi, Dokumentasi
  final double areaHa;
  final double windSpeedKnots;
  final int estimatedMinutes;
  final int batteriesRequired;
  String status; // Terjadwal, Siap Terbang, Selesai
  bool isPinned;
  List<bool> preFlightChecks;

  DroneMission({
    required this.id,
    required this.title,
    required this.location,
    required this.droneModel,
    required this.category,
    required this.areaHa,
    required this.windSpeedKnots,
    required this.estimatedMinutes,
    required this.batteriesRequired,
    this.status = 'Terjadwal',
    this.isPinned = false,
    List<bool>? preFlightChecks,
  }) : preFlightChecks = preFlightChecks ?? [false, false, false, false, false];

  double get checklistProgress {
    if (preFlightChecks.isEmpty) return 0;
    final completed = preFlightChecks.where((c) => c).length;
    return completed / preFlightChecks.length;
  }
}

class DummyMissions {
  static const List<String> checklistLabels = [
    'Kalibrasi Kompas & Sensor IMU Selesai',
    'Baterai Drone & Remote Controller >= 90%',
    'Kartu MicroSD Terpasang & Ruang Penyimpanan Cukup',
    'Sinyal Satelit GNSS/RTK Terkunci (>= 12 Satelit)',
    'Kecepatan Angin & Cuaca Aman (< 20 Knot)',
  ];

  static List<DroneMission> getInitialMissions() {
    return [
      DroneMission(
        id: 'MSN-101',
        title: 'Pemetaan Fotogrametri Kawasan Industri',
        location: 'Kawasan Industri Kabil, Batam',
        droneModel: 'DJI Mavic 3 Enterprise RTK',
        category: 'Pemetaan',
        areaHa: 45.0,
        windSpeedKnots: 11.5,
        estimatedMinutes: 68,
        batteriesRequired: 3,
        status: 'Siap Terbang',
        isPinned: true,
        preFlightChecks: [true, true, true, true, true],
      ),
      DroneMission(
        id: 'MSN-102',
        title: 'Inspeksi Struktur Crane Galangan Kapal',
        location: 'Tanjung Uncang, Batam',
        droneModel: 'DJI Matrice 350 RTK',
        category: 'Inspeksi',
        areaHa: 12.0,
        windSpeedKnots: 14.0,
        estimatedMinutes: 35,
        batteriesRequired: 2,
        status: 'Terjadwal',
        isPinned: true,
        preFlightChecks: [true, true, false, false, false],
      ),
      DroneMission(
        id: 'MSN-103',
        title: 'Dokumentasi Udara Konservasi Terumbu Karang',
        location: 'Pulau Abang, Batam',
        droneModel: 'DJI Air 3S',
        category: 'Dokumentasi',
        areaHa: 18.5,
        windSpeedKnots: 9.0,
        estimatedMinutes: 42,
        batteriesRequired: 2,
        status: 'Selesai',
        isPinned: false,
        preFlightChecks: [true, true, true, true, true],
      ),
      DroneMission(
        id: 'MSN-104',
        title: 'Aerial Cinematic Resort & Garis Pantai',
        location: 'Lagoi Bay, Bintan',
        droneModel: 'BetaFPV Pavo20 DJI O3',
        category: 'Dokumentasi',
        areaHa: 5.0,
        windSpeedKnots: 8.5,
        estimatedMinutes: 20,
        batteriesRequired: 4,
        status: 'Terjadwal',
        isPinned: false,
        preFlightChecks: [true, false, false, false, false],
      ),
    ];
  }
}
