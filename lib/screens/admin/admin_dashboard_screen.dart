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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

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
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.selected,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.medical_services),
                label: Text('Paket MCU'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text('Pasien'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.schedule),
                label: Text('Jadwal'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.bar_chart),
                label: Text('Laporan'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _buildSelectedScreen(),
          ),
        ],
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

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ringkasan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildStatCard(
                    'Total Pendaftaran',
                    totalPendaftaran.toString(),
                    Icons.assignment,
                    Colors.blue,
                  ),
                  _buildStatCard(
                    'Menunggu Konfirmasi',
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
                    'Total Paket MCU',
                    totalPaket.toString(),
                    Icons.medical_services,
                    Colors.purple,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Pendaftaran Terbaru',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: pendaftaranProvider.pendaftaranList
                      .take(5)
                      .length, // Show only 5 latest registrations
                  itemBuilder: (context, index) {
                    final pendaftaran =
                        pendaftaranProvider.pendaftaranList[index];
                    return ListTile(
                      title: Text(pendaftaran.user.namaLengkap),
                      subtitle: Text(
                        '${pendaftaran.paketMcu.namaPaket} - ${pendaftaran.tanggalPendaftaran.toString().split(' ')[0]}',
                      ),
                      trailing: _buildStatusChip(pendaftaran.status),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
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
    return const Center(
      child: Text('Halaman Laporan'),
    );
  }
}
