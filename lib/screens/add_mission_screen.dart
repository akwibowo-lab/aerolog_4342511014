import 'package:flutter/material.dart';
import '../models/mission_model.dart';
import '../theme/app_theme.dart';
import '../viewmodels/aerolog_viewmodel.dart';

class AddMissionScreen extends StatefulWidget {
  final AeroLogViewModel viewModel;
  const AddMissionScreen({super.key, required this.viewModel});

  @override
  State<AddMissionScreen> createState() => _AddMissionScreenState();
}

class _AddMissionScreenState extends State<AddMissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _areaController = TextEditingController(text: '25');
  final _windController = TextEditingController(text: '10');

  String _selectedDrone = 'DJI Mavic 3 Enterprise RTK';
  String _selectedCategory = 'Pemetaan';

  int _calculatedMinutes = 38;
  int _calculatedBatteries = 2;
  String? _safetyWarning;

  final List<String> _droneOptions = const [
    'DJI Mavic 3 Enterprise RTK',
    'DJI Matrice 350 RTK',
    'DJI Air 3S',
    'BetaFPV Pavo20 DJI O3',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _areaController.dispose();
    _windController.dispose();
    super.dispose();
  }

  // Fitur Dinamis 3: Kalkulator Otomatis Durasi Terbang & Baterai
  void _recalculateEstimate() {
    final area = double.tryParse(_areaController.text.trim());
    final wind = double.tryParse(_windController.text.trim());

    if (area == null || area <= 0 || wind == null || wind < 0) {
      setState(() {
        _safetyWarning =
            'Masukkan angka luas area (> 0) dan kecepatan angin yang valid.';
      });
      return;
    }

    String? warning;
    if (wind > 20.0) {
      warning =
          'PERINGATAN BAHAYA: Kecepatan angin $wind Knot melebihi batas aman penerbangan (20 Knot)!';
    }

    final windFactor = 1.0 + (wind / 40.0);
    final estMinutes = (area * 1.35 * windFactor).ceil().clamp(10, 300);
    final estBatteries = (estMinutes / 25.0).ceil().clamp(1, 20);

    setState(() {
      _calculatedMinutes = estMinutes;
      _calculatedBatteries = estBatteries;
      _safetyWarning = warning;
    });
  }

  void _saveMission() {
    _recalculateEstimate();
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Validasi Gagal: Periksa kembali kolom yang kosong/salah!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final area = double.parse(_areaController.text.trim());
    final wind = double.parse(_windController.text.trim());

    if (wind > 20.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Penyimpanan ditolak demi keselamatan: Kecepatan angin > 20 Knot!',
          ),
          backgroundColor: Colors.deepOrange,
        ),
      );
      return;
    }

    final newMission = DroneMission(
      id: 'MSN-${100 + widget.viewModel.allMissions.length + 1}',
      title: _titleController.text.trim(),
      location: _locationController.text.trim(),
      droneModel: _selectedDrone,
      category: _selectedCategory,
      areaHa: area,
      windSpeedKnots: wind,
      estimatedMinutes: _calculatedMinutes,
      batteriesRequired: _calculatedBatteries,
    );

    widget.viewModel.addMission(newMission);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Misi "${newMission.title}" berhasil disimpan!'),
        backgroundColor: AppTheme.accentTeal,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Misi & Kalkulator Baterai'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Misi Penerbangan',
                  hintText: 'Contoh: Pemetaan Topografi Jembatan Barelang',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? 'Judul misi tidak boleh kosong!'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Lokasi Penerbangan',
                  hintText: 'Contoh: Galang, Batam',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? 'Lokasi penerbangan wajib diisi!'
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedDrone,
                decoration: const InputDecoration(
                  labelText: 'Pilih Armada Drone',
                  prefixIcon: Icon(Icons.flight_rounded),
                ),
                items: _droneOptions
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedDrone = val);
                },
              ),
              const SizedBox(height: 12),
              const Text(
                'Kategori Misi',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: ['Pemetaan', 'Inspeksi', 'Dokumentasi'].map((cat) {
                  return ChoiceChip(
                    label: Text(cat),
                    selected: _selectedCategory == cat,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _areaController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _recalculateEstimate(),
                      decoration: const InputDecoration(
                        labelText: 'Luas Area (Ha)',
                      ),
                      validator: (val) {
                        final v = double.tryParse(val ?? '');
                        if (v == null || v <= 0) return 'Wajib angka > 0';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _windController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _recalculateEstimate(),
                      decoration: const InputDecoration(
                        labelText: 'Angin (Knot)',
                      ),
                      validator: (val) {
                        final v = double.tryParse(val ?? '');
                        if (v == null || v < 0) return 'Angka tidak valid';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_safetyWarning != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.redAccent),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _safetyWarning!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Card(
                color: AppTheme.pastelMapping,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('Estimasi Waktu Terbang'),
                          const SizedBox(height: 4),
                          Text(
                            '$_calculatedMinutes Menit',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryNavy,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Kebutuhan Baterai'),
                          const SizedBox(height: 4),
                          Text(
                            '$_calculatedBatteries Unit',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentTeal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _saveMission,
                icon: const Icon(Icons.save_rounded),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                  child: Text(
                    'Simpan Misi Penerbangan',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
