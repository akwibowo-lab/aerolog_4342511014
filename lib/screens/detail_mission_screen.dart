import 'package:flutter/material.dart';
import '../models/mission_model.dart';
import '../theme/app_theme.dart';
import '../viewmodels/aerolog_viewmodel.dart';

class DetailMissionScreen extends StatelessWidget {
  final AeroLogViewModel viewModel;
  final String missionId;

  const DetailMissionScreen({
    super.key,
    required this.viewModel,
    required this.missionId,
  });

  void _confirmDelete(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Jadwal Misi?'),
        content: Text('Apakah Anda yakin ingin menghapus misi "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              viewModel.deleteMission(missionId);
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Misi "$title" telah dihapus.')),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final idx =
            viewModel.allMissions.indexWhere((m) => m.id == missionId);
        if (idx == -1) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Misi')),
            body: const Center(child: Text('Data misi tidak ditemukan.')),
          );
        }

        final mission = viewModel.allMissions[idx];

        return Scaffold(
          appBar: AppBar(
            title: Text('Detail Misi ${mission.id}'),
            actions: [
              IconButton(
                tooltip: mission.isPinned ? 'Lepas Sematan' : 'Sematkan Misi',
                icon: Icon(
                  mission.isPinned
                      ? Icons.push_pin_rounded
                      : Icons.push_pin_outlined,
                  color: mission.isPinned ? AppTheme.primaryNavy : null,
                ),
                onPressed: () => viewModel.togglePinMission(mission.id),
              ),
              IconButton(
                tooltip: 'Hapus Misi',
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Colors.redAccent),
                onPressed: () => _confirmDelete(context, mission.title),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  color: AppTheme.getCategoryColor(mission.category),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Chip(label: Text(mission.category)),
                            Chip(
                              label: Text(
                                mission.status,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          mission.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text('Lokasi Operasi: ${mission.location}'),
                        Text('Unit Armada: ${mission.droneModel}'),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMetric('Luas Area', '${mission.areaHa} Ha'),
                            _buildMetric(
                                'Angin', '${mission.windSpeedKnots} Kt'),
                            _buildMetric(
                                'Durasi', '${mission.estimatedMinutes} Mnt'),
                            _buildMetric(
                                'Baterai', '${mission.batteriesRequired} Unit'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Status Pelaksanaan Misi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          children: ['Terjadwal', 'Siap Terbang', 'Selesai']
                              .map((st) {
                            return ChoiceChip(
                              label: Text(st),
                              selected: mission.status == st,
                              onSelected: (_) => viewModel.updateMissionStatus(
                                  mission.id, st),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Pre-Flight Safety Checklist',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${(mission.checklistProgress * 100).toInt()}% Selesai',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryNavy,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...List.generate(
                          DummyMissions.checklistLabels.length,
                          (i) => CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              DummyMissions.checklistLabels[i],
                              style: const TextStyle(fontSize: 14),
                            ),
                            value: mission.preFlightChecks[i],
                            onChanged: (val) => viewModel.toggleChecklistItem(
                              mission.id,
                              i,
                              val ?? false,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
      ],
    );
  }
}
