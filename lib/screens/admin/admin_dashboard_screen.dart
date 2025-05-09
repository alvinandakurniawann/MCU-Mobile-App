import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pendaftaran_provider.dart';
import '../../providers/paket_mcu_provider.dart';
import 'jadwal_admin_screen.dart';
import 'paket_mcu_admin_screen.dart';
import 'pasien_admin_screen.dart';
import '../../providers/user_provider.dart';
import '../../models/user.dart';
import '../../models/paket_mcu.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchPasienController = TextEditingController();
  String _searchPasienQuery = '';
  User? _selectedUser;
  PaketMCU? _selectedPaket;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    Future.microtask(() async {
      if (!mounted) return;
      await _loadData();
    });
  }

  @override
  void dispose() {
    _searchPasienController.dispose();
    super.dispose();
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
      backgroundColor: Colors.grey[100],
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWebLayout = constraints.maxWidth > 600;

          if (isWebLayout) {
            return Row(
              children: [
                Container(
                  width: 280,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF1A237E), Color(0xFF5B86E5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          children: [
                            const CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.admin_panel_settings, size: 40, color: Color(0xFF1A237E)),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Admin Panel',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildNavItem(Icons.dashboard, 'Beranda', 0),
                      _buildNavItem(Icons.medical_services, 'Paket MCU', 1),
                      _buildNavItem(Icons.people, 'Pasien', 2),
                      _buildNavItem(Icons.schedule, 'Jadwal', 3),
                      _buildNavItem(Icons.bar_chart, 'Laporan', 4),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.read<AuthProvider>().logout();
                            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                          },
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _buildSelectedScreen(),
                ),
              ],
            );
          }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A237E), Color(0xFF5B86E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.admin_panel_settings, size: 24, color: Color(0xFF1A237E)),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Admin Panel',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.logout, color: Colors.white),
                          onPressed: () {
                            context.read<AuthProvider>().logout();
                            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _buildSelectedScreen(),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF1A237E),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Beranda',
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
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A237E).withOpacity(0.1) : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected ? const Color(0xFF1A237E) : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF1A237E) : Colors.grey,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF1A237E) : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
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
        return JadwalAdminScreen();
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
            .where((p) => p.status.toLowerCase() == 'completed' || p.status.toLowerCase() == 'cancelled')
            .length;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWebLayout = constraints.maxWidth > 600;
            final crossAxisCount = isWebLayout ? 4 : 2;
            final childAspectRatio = isWebLayout ? 1.2 : 1.0;
            final padding = isWebLayout ? 20.0 : 12.0;

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
                      color: const Color(0xFF1A237E),
                    ),
                  ),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(top: 4),
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: childAspectRatio,
                    children: [
                      _buildStatCard(
                        'Total Pendaftaran',
                        totalPendaftaran.toString(),
                        Icons.assignment,
                        const Color(0xFF1A237E),
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
                      color: const Color(0xFF1A237E),
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
    return InkWell(
      onTap: () {
        switch (title) {
          case 'Total Pendaftaran':
            _showRegistrationList(context);
            break;
          case 'Menunggu':
            _showFilteredRegistrationList(context, 'pending');
            break;
          case 'Selesai':
            _showFilteredRegistrationList(context, 'completed');
            break;
          case 'Total Paket':
            _showPaketList(context);
            break;
        }
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
                  style: TextStyle(
                    fontSize: 14,
                    color: color.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRegistrationList(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Daftar Pendaftaran',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: Consumer<PendaftaranProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (provider.pendaftaranList.isEmpty) {
                      return const Center(
                        child: Text('Belum ada pendaftaran'),
                      );
                    }

                    return ListView.separated(
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
                            pendaftaran.user.namaLengkap ?? '-',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(pendaftaran.paketMcu.namaPaket),
                              Text(
                                'Tanggal: ${DateFormat('dd MMM yyyy HH:mm').format(pendaftaran.tanggalPendaftaran)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getStatusColor(pendaftaran.status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              pendaftaran.status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilteredRegistrationList(BuildContext context, String status) {
    String title;
    switch (status) {
      case 'pending':
        title = 'Daftar Pendaftaran Menunggu';
        break;
      case 'completed':
        title = 'Daftar Pendaftaran Selesai';
        break;
      default:
        title = 'Daftar Pendaftaran';
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: Consumer<PendaftaranProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final filteredList = provider.pendaftaranList
                        .where((p) =>
                          status == 'completed'
                            ? (p.status.toLowerCase() == 'completed' || p.status.toLowerCase() == 'cancelled')
                            : p.status.toLowerCase() == status.toLowerCase()
                        )
                        .toList();

                    if (filteredList.isEmpty) {
                      return Center(
                        child: Text('Belum ada pendaftaran ${status.toLowerCase()}'),
                      );
                    }

                    return ListView.separated(
                      itemCount: filteredList.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final pendaftaran = filteredList[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getStatusColor(pendaftaran.status).withOpacity(0.1),
                            child: Icon(
                              _getStatusIcon(pendaftaran.status),
                              color: _getStatusColor(pendaftaran.status),
                            ),
                          ),
                          title: Text(
                            pendaftaran.user.namaLengkap ?? '-',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(pendaftaran.paketMcu.namaPaket),
                              Text(
                                'Tanggal: ${DateFormat('dd MMM yyyy HH:mm').format(pendaftaran.tanggalPendaftaran)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: (status == 'pending')
                              ? PopupMenuButton<String>(
                                  onSelected: (String newStatus) async {
                                    if (newStatus != pendaftaran.status) {
                                      await _updateStatus(pendaftaran.id, newStatus);
                                      Navigator.pop(context);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'completed',
                                      child: Row(
                                        children: const [
                                          Icon(Icons.check_circle, color: Colors.green),
                                          SizedBox(width: 8),
                                          Text('Completed'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'cancelled',
                                      child: Row(
                                        children: const [
                                          Icon(Icons.cancel, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('Cancelled'),
                                        ],
                                      ),
                                    ),
                                  ],
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(pendaftaran.status),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          pendaftaran.status,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.arrow_drop_down, color: Colors.white, size: 20),
                                      ],
                                    ),
                                  ),
                                )
                              : (status == 'completed' || pendaftaran.status.toLowerCase() == 'cancelled')
                                  ? PopupMenuButton<String>(
                                      onSelected: (String newStatus) async {
                                        if (newStatus != pendaftaran.status) {
                                          await _updateStatus(pendaftaran.id, newStatus);
                                          Navigator.pop(context);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          value: 'pending',
                                          child: Row(
                                            children: const [
                                              Icon(Icons.pending, color: Colors.orange),
                                              SizedBox(width: 8),
                                              Text('Pending'),
                                            ],
                                          ),
                                        ),
                                      ],
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(pendaftaran.status),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              pendaftaran.status,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            const Icon(Icons.arrow_drop_down, color: Colors.white, size: 20),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(pendaftaran.status),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        pendaftaran.status,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPaketList(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Daftar Paket MCU',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: Consumer<PaketMCUProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (provider.paketList.isEmpty) {
                      return const Center(
                        child: Text('Belum ada paket MCU'),
                      );
                    }

                    return ListView.separated(
                      itemCount: provider.paketList.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final paket = provider.paketList[index];
                        return ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A237E).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.medical_services,
                              color: Color(0xFF1A237E),
                            ),
                          ),
                          title: Text(
                            paket.namaPaket,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rp ${NumberFormat('#,##0.00', 'id_ID').format(paket.harga)}',
                                style: const TextStyle(
                                  color: Color(0xFF1A237E),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                paket.deskripsi,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentRegistrations(List<dynamic> pendaftaranList) {
    if (pendaftaranList.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Padding(
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

    pendaftaranList.sort((a, b) => b.tanggalPendaftaran.compareTo(a.tanggalPendaftaran));
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
        separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[200]),
        itemBuilder: (context, index) {
          final pendaftaran = recentPendaftaran[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getStatusColor(pendaftaran.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getStatusIcon(pendaftaran.status),
                color: _getStatusColor(pendaftaran.status),
              ),
            ),
            title: Text(
              pendaftaran.user.namaLengkap ?? '-',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${pendaftaran.paketMcu.namaPaket} - ${DateFormat('dd MMM yyyy').format(pendaftaran.tanggalPendaftaran)}',
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (String newStatus) async {
                if (newStatus != pendaftaran.status) {
                  await _updateStatus(pendaftaran.id, newStatus);
                }
              },
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'pending',
                  child: Row(
                    children: const [
                      Icon(Icons.pending, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Pending'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'completed',
                  child: Row(
                    children: const [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Completed'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'cancelled',
                  child: Row(
                    children: const [
                      Icon(Icons.cancel, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Canceled'),
                    ],
                  ),
                ),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _getStatusColor(pendaftaran.status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      pendaftaran.status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
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
        return Icons.check_circle_outline;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
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

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWebLayout = constraints.maxWidth > 600;
            final padding = isWebLayout ? 24.0 : 16.0;

            return Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Paket MCU',
                        style: TextStyle(
                          fontSize: isWebLayout ? 28 : 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A237E),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          _showPaketForm(context, provider);
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah Paket'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A237E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
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
                    child: ListView.separated(
                      itemCount: provider.paketList.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final paket = provider.paketList[index];
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white,
                                  const Color(0xFF1A237E).withOpacity(0.08),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                color: const Color(0xFF1A237E).withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              paket.namaPaket,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1A237E),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF1A237E).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: const Color(0xFF1A237E).withOpacity(0.2),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Text(
                                                'Rp ${NumberFormat('#,##0.00', 'id_ID').format(paket.harga)}',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Color(0xFF1A237E),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF1A237E).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: IconButton(
                                              icon: const Icon(Icons.edit, color: Color(0xFF1A237E), size: 20),
                                              onPressed: () {
                                                _showPaketForm(context, provider, paket: paket);
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE57373).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: IconButton(
                                              icon: const Icon(Icons.delete, color: Color(0xFFE57373), size: 20),
                                              onPressed: () async {
                                                final confirm = await showDialog<bool>(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: const Text('Konfirmasi'),
                                                    content: const Text('Apakah Anda yakin ingin menghapus paket ini?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(context, false),
                                                        child: const Text('Batal'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(context, true),
                                                        child: const Text('Hapus', style: TextStyle(color: Color(0xFFE57373))),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                                if (confirm == true) {
                                                  final success = await provider.deletePaketMCU(paket.id);
                                                  if (success && context.mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(
                                                        content: Text('Paket berhasil dihapus'),
                                                        backgroundColor: Color(0xFF1A237E),
                                                      ),
                                                    );
                                                  } else if (context.mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text(provider.error ?? 'Gagal menghapus paket'),
                                                        backgroundColor: const Color(0xFFE57373),
                                                      ),
                                                    );
                                                  }
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    paket.deskripsi,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: const Color(0xFF1A237E).withOpacity(0.9),
                                      height: 1.5,
                                    ),
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
          },
        );
      },
    );
  }

  void _showPaketForm(BuildContext context, PaketMCUProvider provider, {dynamic paket}) {
    final _formKey = GlobalKey<FormState>();
    final _namaController = TextEditingController(text: paket?.namaPaket ?? '');
    final _hargaController = TextEditingController(text: paket?.harga.toString() ?? '');
    final _deskripsiController = TextEditingController(text: paket?.deskripsi ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          paket == null ? 'Tambah Paket MCU' : 'Edit Paket MCU',
          style: const TextStyle(
            color: Color(0xFF1A237E),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _namaController,
                  decoration: InputDecoration(
                    labelText: 'Nama Paket',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF1A237E)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama paket tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hargaController,
                  decoration: InputDecoration(
                    labelText: 'Harga',
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF1A237E)),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harga tidak boleh kosong';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Harga harus berupa angka';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _deskripsiController,
                  decoration: InputDecoration(
                    labelText: 'Deskripsi',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF1A237E)),
                    ),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Deskripsi tidak boleh kosong';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final paketData = {
                  'nama_paket': _namaController.text,
                  'harga': double.parse(_hargaController.text),
                  'deskripsi': _deskripsiController.text,
                };

                bool success;
                if (paket == null) {
                  success = await provider.createPaket(paketData);
                } else {
                  success = await provider.updatePaket(paket.id, paketData);
                }

                if (success && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        paket == null ? 'Paket berhasil ditambahkan' : 'Paket berhasil diperbarui',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A237E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(paket == null ? 'Tambah' : 'Simpan'),
          ),
        ],
      ),
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

        // Filter data pasien berdasarkan nama
        final filteredList = _searchPasienQuery.isEmpty
            ? provider.pendaftaranList
            : provider.pendaftaranList.where((pendaftaran) =>
                pendaftaran.user.namaLengkap?.toLowerCase().contains(_searchPasienQuery.toLowerCase()) ?? false
              ).toList();

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
                        controller: _searchPasienController,
                        decoration: InputDecoration(
                          hintText: 'Cari pasien berdasarkan nama...',
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
                          suffixIcon: _searchPasienQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchPasienController.clear();
                                    setState(() {
                                      _searchPasienQuery = '';
                                    });
                                  },
                                )
                              : null,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchPasienQuery = value;
                          });
                        },
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
                  child: filteredList.isEmpty
                      ? const Center(
                          child: Text('Tidak ada pasien yang ditemukan'),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredList.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final pendaftaran = filteredList[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue.withOpacity(0.1),
                                child: Text(
                                  (pendaftaran.user.namaLengkap != null && pendaftaran.user.namaLengkap!.isNotEmpty)
                                      ? pendaftaran.user.namaLengkap![0].toUpperCase()
                                      : '-',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                pendaftaran.user.namaLengkap ?? '-',
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

  Widget _buildLaporanContent() {
    return Consumer<PendaftaranProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final totalPendaftaran = provider.pendaftaranList.length;
        final completedPendaftaran = provider.pendaftaranList
            .where((p) => p.status.toLowerCase() == 'completed' || p.status.toLowerCase() == 'cancelled')
            .toList();
        final totalPendapatan = completedPendaftaran
            .where((p) => p.status.toLowerCase() == 'completed')
            .fold(0.0, (sum, item) => sum + item.totalHarga);

        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
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
                  // Baris 1: Total Pendaftaran & MCU Selesai
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _showPendaftaranDetails(context, provider),
                          child: _niceStatCard(
                            icon: Icons.assignment,
                            value: totalPendaftaran.toString(),
                            label: 'Total Pendaftaran',
                            color: Colors.blue,
                            bgColor: Colors.blue.shade50,
                            isRect: false,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () => _showCompletedMCUDetails(context, provider),
                          child: _niceStatCard(
                            icon: Icons.check_circle,
                            value: completedPendaftaran.length.toString(),
                            label: 'MCU Selesai & Dibatalkan',
                            color: Colors.purple,
                            bgColor: Colors.purple.shade50,
                            isRect: false,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Baris 2: Total Pendapatan (persegi panjang, full width)
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _showPendapatanDetails(context, provider),
                          child: _niceStatCard(
                            icon: Icons.currency_exchange,
                            value: 'Rp ${NumberFormat('#,##0.00', 'id_ID').format(totalPendapatan)}',
                            label: 'Total Pendapatan',
                            color: Colors.green,
                            bgColor: Colors.green.shade50,
                            isRect: true,
                          ),
                        ),
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
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: provider.pendaftaranList.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Center(
                              child: Text(
                                'Belum ada pendaftaran',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ),
                          )
                        : SizedBox(
                            height: 350,
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
                                    pendaftaran.user.namaLengkap ?? '-',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    '${pendaftaran.paketMcu.namaPaket} - ${DateFormat('dd MMM yyyy').format(pendaftaran.tanggalPendaftaran)}',
                                  ),
                                  trailing: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(pendaftaran.status),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        pendaftaran.status,
                                        style: const TextStyle(fontSize: 12, color: Colors.white),
                                      ),
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
      },
    );
  }

  void _showPendaftaranDetails(BuildContext context, PendaftaranProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                'Detail Total Pendaftaran',
                style: const TextStyle(fontSize: 20),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: provider.pendaftaranList.length,
            itemBuilder: (context, index) {
              final pendaftaran = provider.pendaftaranList[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  child: Text(
                    (pendaftaran.user.namaLengkap != null && pendaftaran.user.namaLengkap!.isNotEmpty)
                        ? pendaftaran.user.namaLengkap![0].toUpperCase()
                        : '-',
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
                title: Text(pendaftaran.user.namaLengkap ?? '-'),
                subtitle: Text(
                  '${pendaftaran.paketMcu.namaPaket}\n${DateFormat('dd MMM yyyy').format(pendaftaran.tanggalPendaftaran)}',
                ),
                trailing: Chip(
                  label: Text(
                    pendaftaran.status,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: _getStatusColor(pendaftaran.status),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showCompletedMCUDetails(BuildContext context, PendaftaranProvider provider) {
    final completedPendaftaran = provider.pendaftaranList
        .where((p) => p.status.toLowerCase() == 'completed' || p.status.toLowerCase() == 'cancelled')
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                'Detail MCU Selesai & Dibatalkan',
                style: const TextStyle(fontSize: 20),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: completedPendaftaran.isEmpty
              ? const Center(
                  child: Text('Belum ada MCU yang selesai atau dibatalkan'),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: completedPendaftaran.length,
                  itemBuilder: (context, index) {
                    final pendaftaran = completedPendaftaran[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: pendaftaran.status.toLowerCase() == 'completed'
                            ? Colors.purple.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        child: Icon(
                          pendaftaran.status.toLowerCase() == 'completed'
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: pendaftaran.status.toLowerCase() == 'completed'
                              ? Colors.purple
                              : Colors.red,
                        ),
                      ),
                      title: Text(pendaftaran.user.namaLengkap ?? '-'),
                      subtitle: Text(
                        '${pendaftaran.paketMcu.namaPaket}\n${DateFormat('dd MMM yyyy').format(pendaftaran.tanggalPendaftaran)}',
                      ),
                      trailing: pendaftaran.status.toLowerCase() == 'completed'
                          ? Text(
                              'Rp ${NumberFormat('#,##0.00', 'id_ID').format(pendaftaran.totalHarga)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Dibatalkan',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  void _showPendapatanDetails(BuildContext context, PendaftaranProvider provider) {
    final completedPendaftaran = provider.pendaftaranList
        .where((p) => p.status.toLowerCase() == 'completed')
        .toList();
    
    final pendapatanPerPaket = <String, double>{};
    for (var pendaftaran in completedPendaftaran) {
      final paketName = pendaftaran.paketMcu.namaPaket;
      pendapatanPerPaket[paketName] = (pendapatanPerPaket[paketName] ?? 0) + pendaftaran.totalHarga;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                'Detail Pendapatan (MCU Selesai)',
                style: const TextStyle(fontSize: 20),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pendapatan per Paket MCU:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              if (pendapatanPerPaket.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Belum ada pendapatan dari MCU yang selesai',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ...pendapatanPerPaket.entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            entry.key,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        Text(
                          'Rp ${NumberFormat('#,##0.00', 'id_ID').format(entry.value)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Pendapatan:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Rp ${NumberFormat('#,##0.00', 'id_ID').format(pendapatanPerPaket.values.fold(0.0, (sum, value) => sum + value))}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _niceStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required Color bgColor,
    bool isRect = false,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: bgColor,
      child: Padding(
        padding: isRect
            ? const EdgeInsets.symmetric(vertical: 28, horizontal: 24)
            : const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: isRect ? 44 : 36),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: isRect ? 28 : 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: color.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return months[month - 1];
  }

  Future<void> _updateStatus(String id, String newStatus) async {
    try {
      final success = await context.read<PendaftaranProvider>().updatePendaftaran(
        id,
        {'status': newStatus},
      );

      if (!mounted) return;

      if (success) {
        // Reload data pendaftaran untuk memperbarui tampilan
        await context.read<PendaftaranProvider>().loadPendaftaranList();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status berhasil diperbarui'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<PendaftaranProvider>().error ?? 'Gagal memperbarui status',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
