import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../viewmodels/aerolog_viewmodel.dart';
import 'catalog_screen.dart';
import 'add_mission_screen.dart';
import 'detail_mission_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  final AeroLogViewModel viewModel;
  const DashboardScreen({super.key, required this.viewModel});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  void _syncWeatherTelemetry() {
    // Penanganan Error (Exception Handling) ketika koneksi simulasi terputus
    try {
      if (widget.viewModel.isOfflineSimulated) {
        throw Exception(
          'Koneksi internet terputus! Gagal mengambil data cuaca & kecepatan angin BMKG Hang Nadim Batam.',
        );
      }
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(
            Icons.cloud_done_rounded,
            color: AppTheme.accentTeal,
            size: 48,
          ),
          title: const Text('Telemetri Cuaca Terhubung'),
          content: const Text(
            'Stasiun: BMKG Hang Nadim Batam\n'
            'Kondisi: Cerah Berawan (Visibilitas 10 km)\n'
            'Angin Permukaan: 10.5 Knot (Aman < 20 Knot)\n'
            'Status Satelit GNSS: Optimal (16 Satelit)',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(
            Icons.wifi_off_rounded,
            color: Colors.redAccent,
            size: 48,
          ),
          title: const Text('Peringatan Koneksi Terputus'),
          content: Text(e.toString().replaceAll('Exception: ', '')),
          actions: [
            TextButton(
              onPressed: () {
                widget.viewModel.toggleOfflineSimulation(false);
                Navigator.of(ctx).pop();
              },
              child: const Text('Pulihkan Koneksi'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Mengerti'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final pages = [
          _buildOverviewTab(context),
          CatalogScreen(viewModel: widget.viewModel),
        ];

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AeroLog Mission Control',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  'Halo, ${widget.viewModel.pilotName} (${widget.viewModel.pilotCallsign}) 👋',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
            actions: [
              Row(
                children: [
                  const Text('Simulasi Offline', style: TextStyle(fontSize: 11)),
                  Switch(
                    value: widget.viewModel.isOfflineSimulated,
                    onChanged: (val) {
                      widget.viewModel.toggleOfflineSimulation(val);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            val
                                ? 'Mode Offline Diaktifkan (Simulasi Koneksi Putus)'
                                : 'Mode Online Aktif Kembali',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
              IconButton(
                tooltip: 'Keluar (Logout)',
                icon: const Icon(Icons.logout_rounded),
                onPressed: () {
                  widget.viewModel.logout();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => LoginScreen(viewModel: widget.viewModel),
                    ),
                  );
                },
              ),
            ],
          ),
          body: pages[_selectedIndex],
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddMissionScreen(viewModel: widget.viewModel),
                ),
              );
            },
            icon: const Icon(Icons.add_task_rounded),
            label: const Text('+ Misi & Hitung Baterai'),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (idx) =>
                setState(() => _selectedIndex = idx),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_rounded),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.list_alt_outlined),
                selectedIcon: Icon(Icons.list_alt_rounded),
                label: 'Katalog Misi',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverviewTab(BuildContext context) {
    final missions = widget.viewModel.allMissions;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner Ringkasan Operasional
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryNavy, AppTheme.primaryDark],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.airplanemode_active_rounded,
                  color: Colors.white,
                  size: 42,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ringkasan Flight Log & Telemetri',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${missions.length} Misi Tersimpan • ${widget.viewModel.pinnedCount} Disematkan (Pinned)',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: _syncWeatherTelemetry,
                  icon: const Icon(Icons.cloud_sync_rounded),
                  label: const Text('Cek Cuaca'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Grid Statistik Adaptif (Responsif saat rotasi layar)
          LayoutBuilder(
            builder: (context, constraints) {
              final isLandscape = constraints.maxWidth > 600;
              return GridView.count(
                crossAxisCount: isLandscape ? 4 : 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: isLandscape ? 1.8 : 1.55,
                children: [
                  _buildStatCard(
                    'Total Misi',
                    '${missions.length} Misi',
                    Icons.assignment_outlined,
                    AppTheme.primaryNavy,
                  ),
                  _buildStatCard(
                    'Siap / Selesai',
                    '${widget.viewModel.readyOrCompletedCount} Misi',
                    Icons.verified_outlined,
                    AppTheme.accentTeal,
                  ),
                  _buildStatCard(
                    'Estimasi Jam Terbang',
                    '${widget.viewModel.totalFlightMinutes} Menit',
                    Icons.timer_outlined,
                    Colors.amber.shade800,
                  ),
                  _buildStatCard(
                    'Status Koneksi',
                    widget.viewModel.isOfflineSimulated ? 'OFFLINE' : 'ONLINE',
                    widget.viewModel.isOfflineSimulated
                        ? Icons.wifi_off_rounded
                        : Icons.wifi_rounded,
                    widget.viewModel.isOfflineSimulated
                        ? Colors.redAccent
                        : Colors.green,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Jadwal Misi Prioritas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () => setState(() => _selectedIndex = 1),
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Buka Katalog'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          ...missions.take(3).map(
                (m) => Card(
                  color: AppTheme.getCategoryColor(m.category),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryNavy,
                      foregroundColor: Colors.white,
                      child: Icon(
                        m.isPinned
                            ? Icons.push_pin_rounded
                            : Icons.flight_takeoff_rounded,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      m.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${m.location} • ${m.droneModel}'),
                    trailing: Chip(
                      label: Text(
                        m.status,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DetailMissionScreen(
                            viewModel: widget.viewModel,
                            missionId: m.id,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 26),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
