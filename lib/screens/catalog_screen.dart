import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../viewmodels/aerolog_viewmodel.dart';
import 'detail_mission_screen.dart';

class CatalogScreen extends StatelessWidget {
  final AeroLogViewModel viewModel;
  const CatalogScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final categories = ['Semua', 'Pemetaan', 'Inspeksi', 'Dokumentasi'];
    final filtered = viewModel.filteredMissions;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Kolom Pencarian Real-Time
          TextField(
            onChanged: viewModel.setSearchQuery,
            decoration: InputDecoration(
              hintText: 'Cari misi, lokasi (Batam/Bintan), atau tipe drone...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: viewModel.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () => viewModel.setSearchQuery(''),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),

          // Deretan ChoiceChip Filter Kategori
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((cat) {
                final isSelected = viewModel.selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) => viewModel.setCategory(cat),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Daftar Kartu Misi menggunakan ListView.builder (Padanan RecyclerView)
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 56, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          'Tidak ada jadwal misi yang cocok dengan pencarian.',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final mission = filtered[index];
                      final progressPercent =
                          (mission.checklistProgress * 100).toInt();

                      return Card(
                        color: AppTheme.getCategoryColor(mission.category),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => DetailMissionScreen(
                                  viewModel: viewModel,
                                  missionId: mission.id,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        if (mission.isPinned)
                                          const Padding(
                                            padding: EdgeInsets.only(right: 6),
                                            child: Icon(
                                              Icons.push_pin_rounded,
                                              size: 16,
                                              color: AppTheme.primaryNavy,
                                            ),
                                          ),
                                        Text(
                                          '${mission.id} • ${mission.category}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primaryNavy,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Chip(
                                      label: Text(
                                        mission.status,
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  mission.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Lokasi: ${mission.location}\nDrone: ${mission.droneModel} (${mission.areaHa} Ha)',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: LinearProgressIndicator(
                                        value: mission.checklistProgress,
                                        minHeight: 6,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Pre-Flight: $progressPercent%',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
