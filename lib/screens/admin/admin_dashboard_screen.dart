import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pendaftaran_provider.dart';
import '../../providers/paket_mcu_provider.dart';
import 'jadwal_admin_screen.dart';
import 'paket_mcu_admin_screen.dart';
import 'pasien_admin_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    Future.microtask(() async {
      if (!mounted) return;
      await _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      await Future.wait([
        context.read<PendaftaranProvider>().loadPendaftaranList(),
        context.read<PaketMCUProvider>().loadPaketList(),
      ]);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWebLayout = constraints.maxWidth > 600;

          if (isWebLayout) {
            return Row(
              children: [
                NavigationRail(
                  extended: constraints.maxWidth > 800,
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (int index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.dashboard),
                      selectedIcon: Icon(Icons.dashboard),
                      label: Text('Dashboard'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.medical_services),
                      selectedIcon: Icon(Icons.medical_services),
                      label: Text('Paket MCU'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.people),
                      selectedIcon: Icon(Icons.people),
                      label: Text('Pasien'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.schedule),
                      selectedIcon: Icon(Icons.schedule),
                      label: Text('Jadwal'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.bar_chart),
                      selectedIcon: Icon(Icons.bar_chart),
                      label: Text('Laporan'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: _buildSelectedScreen(),
                ),
              ],
            );
          }

          return Column(
            children: [
              Expanded(
                child: _buildSelectedScreen(),
              ),
              BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                type: BottomNavigationBarType.fixed,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard),
                    label: 'Dashboard',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.medical_services),
                    label: 'Paket MCU',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.people),
                    label: 'Pasien',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.schedule),
                    label: 'Jadwal',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.bar_chart),
                    label: 'Laporan',
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return _buildPaketMcuContent();
      case 2:
        return _buildPasienContent();
      case 3:
        return _buildJadwalContent();
      case 4:
        return _buildLaporanContent();
      default:
        return const Center(
          child: Text('Halaman tidak ditemukan'),
        );
    }
  }

  Widget _buildDashboardContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Consumer2<PendaftaranProvider, PaketMCUProvider>(
      builder: (context, pendaftaranProvider, paketProvider, child) {
        if (pendaftaranProvider.isLoading || paketProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final totalPendaftaran = pendaftaranProvider.pendaftaranList.length;
        final totalPaket = paketProvider.paketList.length;
        final pendingPendaftaran = pendaftaranProvider.pendaftaranList
            .where((p) => p.status.toLowerCase() == 'pending')
            .length;
        final completedPendaftaran = pendaftaranProvider.pendaftaranList
            .where((p) => p.status.toLowerCase() == 'completed')
            .length;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWebLayout = constraints.maxWidth > 600;
            final crossAxisCount = isWebLayout ? 4 : 2;
            final childAspectRatio = isWebLayout ? 1.5 : 1.3;
            final padding = isWebLayout ? 24.0 : 16.0;

            return SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ringkasan',
                    style: TextStyle(
                      fontSize: isWebLayout ? 28 : 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: isWebLayout ? 24 : 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: childAspectRatio,
                    children: [
                      _buildStatCard(
                        'Total Pendaftaran',
                        totalPendaftaran.toString(),
                        Icons.assignment,
                        Colors.blue,
                      ),
                      _buildStatCard(
                        'Menunggu',
                        pendingPendaftaran.toString(),
                        Icons.pending,
                        Colors.orange,
                      ),
                      _buildStatCard(
                        'Selesai',
                        completedPendaftaran.toString(),
                        Icons.check_circle,
                        Colors.green,
                      ),
                      _buildStatCard(
                        'Total Paket',
                        totalPaket.toString(),
                        Icons.medical_services,
                        Colors.purple,
                      ),
                    ],
                  ),
                  SizedBox(height: isWebLayout ? 40 : 32),
                  Text(
                    'Pendaftaran Terbaru',
                    style: TextStyle(
                      fontSize: isWebLayout ? 24 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount:
                        pendaftaranProvider.pendaftaranList.take(5).length,
                    itemBuilder: (context, index) {
                      final pendaftaran =
                          pendaftaranProvider.pendaftaranList[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(pendaftaran.user.namaLengkap),
                          subtitle: Text(
                            '${pendaftaran.paketMcu.namaPaket} - ${pendaftaran.tanggalPendaftaran.toString().split(' ')[0]}',
                          ),
                          trailing: _buildStatusChip(pendaftaran.status),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        icon = Icons.pending;
        break;
      case 'confirmed':
        color = Colors.blue;
        icon = Icons.check_circle;
        break;
      case 'completed':
        color = Colors.green;
        icon = Icons.done_all;
        break;
      case 'cancelled':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }

    return Chip(
      avatar: Icon(
        icon,
        color: Colors.white,
        size: 16,
      ),
      label: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      backgroundColor: color,
    );
  }

  Widget _buildPaketMcuContent() {
    return const PaketMCUAdminScreen();
  }

  Widget _buildPasienContent() {
    return const PasienAdminScreen();
  }

  Widget _buildJadwalContent() {
    return const JadwalAdminScreen();
  }

  Widget _buildLaporanContent() {
    return Consumer<PendaftaranProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Laporan Pendaftaran MCU',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Pendaftaran',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${provider.pendaftaranList.length}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Pendapatan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Rp ${provider.pendaftaranList.fold(0.0, (sum, item) => sum + item.totalHarga).toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Riwayat Pendaftaran',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Card(
                  child: ListView.builder(
                    itemCount: provider.pendaftaranList.length,
                    itemBuilder: (context, index) {
                      final pendaftaran = provider.pendaftaranList[index];
                      return ListTile(
                        title: Text(pendaftaran.user.namaLengkap),
                        subtitle: Text(
                          '${pendaftaran.paketMcu.namaPaket} - ${pendaftaran.tanggalPendaftaran.toString().split(' ')[0]}',
                        ),
                        trailing: Text(
                          'Rp ${pendaftaran.totalHarga.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
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
      },
    );
  }
}
