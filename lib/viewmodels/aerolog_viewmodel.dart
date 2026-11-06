import 'package:flutter/foundation.dart';
import '../models/mission_model.dart';

class AeroLogViewModel extends ChangeNotifier {
  String _pilotName = 'Akut Wibowo';
  String _pilotCallsign = 'JDB-4342511014';
  bool _isLoggedIn = false;
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  bool _isOfflineSimulated = false;

  final List<DroneMission> _missions = DummyMissions.getInitialMissions();

  // Getters
  String get pilotName => _pilotName;
  String get pilotCallsign => _pilotCallsign;
  bool get isLoggedIn => _isLoggedIn;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  bool get isOfflineSimulated => _isOfflineSimulated;
  List<DroneMission> get allMissions => List.unmodifiable(_missions);

  // Fitur Dinamis 1: Pencarian & Filter Kategori Real-Time
  List<DroneMission> get filteredMissions {
    final list = _missions.where((m) {
      final matchesCategory =
          _selectedCategory == 'Semua' || m.category == _selectedCategory;
      final q = _searchQuery.toLowerCase();
      final matchesQuery = q.isEmpty ||
          m.title.toLowerCase().contains(q) ||
          m.location.toLowerCase().contains(q) ||
          m.droneModel.toLowerCase().contains(q);
      return matchesCategory && matchesQuery;
    }).toList();

    // Tampilkan misi yang di-pin di urutan teratas
    list.sort((a, b) => (b.isPinned ? 1 : 0).compareTo(a.isPinned ? 1 : 0));
    return list;
  }

  int get totalFlightMinutes =>
      _missions.fold(0, (sum, item) => sum + item.estimatedMinutes);

  int get readyOrCompletedCount => _missions
      .where((m) => m.status == 'Siap Terbang' || m.status == 'Selesai')
      .length;

  int get pinnedCount => _missions.where((m) => m.isPinned).length;

  // Actions
  void login(String name, String callsign) {
    _pilotName = name.trim();
    _pilotCallsign = callsign.trim().toUpperCase();
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void toggleOfflineSimulation(bool value) {
    _isOfflineSimulated = value;
    notifyListeners();
  }

  // Fitur Dinamis 2: Pre-Flight Checklist Interaktif & Update Status Otomatis
  void toggleChecklistItem(String missionId, int index, bool value) {
    final idx = _missions.indexWhere((m) => m.id == missionId);
    if (idx != -1) {
      _missions[idx].preFlightChecks[index] = value;
      if (_missions[idx].preFlightChecks.every((c) => c) &&
          _missions[idx].status == 'Terjadwal') {
        _missions[idx].status = 'Siap Terbang';
      }
      notifyListeners();
    }
  }

  void updateMissionStatus(String missionId, String newStatus) {
    final idx = _missions.indexWhere((m) => m.id == missionId);
    if (idx != -1) {
      _missions[idx].status = newStatus;
      notifyListeners();
    }
  }

  void togglePinMission(String missionId) {
    final idx = _missions.indexWhere((m) => m.id == missionId);
    if (idx != -1) {
      _missions[idx].isPinned = !_missions[idx].isPinned;
      notifyListeners();
    }
  }

  // Fitur Dinamis 3: Tambah & Hapus Misi
  void addMission(DroneMission mission) {
    _missions.insert(0, mission);
    notifyListeners();
  }

  void deleteMission(String id) {
    _missions.removeWhere((m) => m.id == id);
    notifyListeners();
  }
}
