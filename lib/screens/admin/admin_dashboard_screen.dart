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
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
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
                  backgroundColor: Colors.white,
                  elevation: 2,
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
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: BottomNavigationBar(
                  currentIndex: _selectedIndex,
                  onTap: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.white,
                  selectedItemColor: Colors.blue,
                  unselectedItemColor: Colors.grey,
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
                  _buildRecentRegistrations(pendaftaranProvider.pendaftaranList),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
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
            const SizedBox(height: 4),
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

  Widget _buildRecentRegistrations(List<dynamic> pendaftaranList) {
    if (pendaftaranList.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Belum ada pendaftaran',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Sort by date, most recent first
    pendaftaranList.sort((a, b) => b.tanggalPendaftaran.compareTo(a.tanggalPendaftaran));

    // Take only the 5 most recent
    final recentPendaftaran = pendaftaranList.take(5).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recentPendaftaran.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final pendaftaran = recentPendaftaran[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(pendaftaran.status).withOpacity(0.1),
              child: Icon(
                _getStatusIcon(pendaftaran.status),
                color: _getStatusColor(pendaftaran.status),
              ),
            ),
            title: Text(
              pendaftaran.user.namaLengkap,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${pendaftaran.paketMcu.namaPaket} - ${pendaftaran.tanggalPendaftaran.toString().split(' ')[0]}',
            ),
            trailing: Chip(
              label: Text(
                pendaftaran.status,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              backgroundColor: _getStatusColor(pendaftaran.status),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.pending;
      case 'confirmed':
        return Icons.check_circle;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  Widget _buildPaketMcuContent() {
    return Consumer<PaketMCUProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Paket MCU',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement add new package
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Paket'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: provider.paketList.length,
                  itemBuilder: (context, index) {
                    final paket = provider.paketList[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    paket.namaPaket,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    // TODO: Implement edit package
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Rp ${paket.harga.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Text(
                                paket.deskripsi,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildPasienContent() {
    return Consumer<PendaftaranProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Daftar Pasien',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Cari pasien...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.blue),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.pendaftaranList.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final pendaftaran = provider.pendaftaranList[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.withOpacity(0.1),
                          child: Text(
                            pendaftaran.user.namaLengkap[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          pendaftaran.user.namaLengkap,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(pendaftaran.user.email ?? 'No email'),
                            Text(
                              'Paket: ${pendaftaran.paketMcu.namaPaket}',
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        trailing: Chip(
                          label: Text(
                            pendaftaran.status,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          backgroundColor: _getStatusColor(pendaftaran.status),
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

  Widget _buildJadwalContent() {
    return Consumer<PendaftaranProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Jadwal MCU',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement add new schedule
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Jadwal'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.pendaftaranList.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final pendaftaran = provider.pendaftaranList[index];
                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                pendaftaran.tanggalPendaftaran.day.toString(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              Text(
                                _getMonthName(pendaftaran.tanggalPendaftaran.month),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        title: Text(
                          pendaftaran.user.namaLengkap,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${pendaftaran.paketMcu.namaPaket} - ${pendaftaran.tanggalPendaftaran.hour}:${pendaftaran.tanggalPendaftaran.minute.toString().padLeft(2, '0')}',
                        ),
                        trailing: Chip(
                          label: Text(
                            pendaftaran.status,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          backgroundColor: _getStatusColor(pendaftaran.status),
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

  Widget _buildLaporanContent() {
    return Consumer<PendaftaranProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final totalPendaftaran = provider.pendaftaranList.length;
        final totalPendapatan = provider.pendaftaranList.fold(
          0.0,
          (sum, item) => sum + item.totalHarga,
        );
        final completedPendaftaran = provider.pendaftaranList
            .where((p) => p.status.toLowerCase() == 'completed')
            .length;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Laporan MCU',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard(
                    'Total Pendaftaran',
                    totalPendaftaran.toString(),
                    Icons.assignment,
                    Colors.blue,
                  ),
                  _buildStatCard(
                    'Total Pendapatan',
                    'Rp ${totalPendapatan.toStringAsFixed(0)}',
                    Icons.attach_money,
                    Colors.green,
                  ),
                  _buildStatCard(
                    'MCU Selesai',
                    completedPendaftaran.toString(),
                    Icons.check_circle,
                    Colors.purple,
                  ),
                ],
              ),
              const SizedBox(height: 32),
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
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.pendaftaranList.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final pendaftaran = provider.pendaftaranList[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(pendaftaran.status).withOpacity(0.1),
                          child: Icon(
                            _getStatusIcon(pendaftaran.status),
                            color: _getStatusColor(pendaftaran.status),
                          ),
                        ),
                        title: Text(
                          pendaftaran.user.namaLengkap,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${pendaftaran.paketMcu.namaPaket} - ${pendaftaran.tanggalPendaftaran.toString().split(' ')[0]}',
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Rp ${pendaftaran.totalHarga.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Chip(
                              label: Text(
                                pendaftaran.status,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              backgroundColor: _getStatusColor(pendaftaran.status),
                            ),
                          ],
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

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return months[month - 1];
  }
}
