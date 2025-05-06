import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/pendaftaran_provider.dart';
import 'daftar_mcu_screen.dart';
import 'riwayat_mcu_screen.dart';
import 'profil_screen.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  int _carouselIndex = 0;

  final List<String> _carouselImages = [
    'assets/images/carousel1.jpg',
    'assets/images/carousel2.jpg',
  ];

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
      await context.read<PendaftaranProvider>().loadPendaftaranList();
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
        title: const Text('Dashboard Pengguna'),
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
                      icon: Icon(Icons.home),
                      selectedIcon: Icon(Icons.home),
                      label: Text('Beranda'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.medical_services),
                      selectedIcon: Icon(Icons.medical_services),
                      label: Text('Daftar MCU'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.history),
                      selectedIcon: Icon(Icons.history),
                      label: Text('Riwayat MCU'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person),
                      selectedIcon: Icon(Icons.person),
                      label: Text('Profil'),
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
                    icon: Icon(Icons.home),
                    label: 'Beranda',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.medical_services),
                    label: 'Daftar MCU',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.history),
                    label: 'Riwayat MCU',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Profil',
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
        return const DaftarMCUScreen();
      case 2:
        return const RiwayatMCUScreen();
      case 3:
        return const ProfilScreen();
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

    return Consumer2<UserProvider, PendaftaranProvider>(
      builder: (context, userProvider, pendaftaranProvider, child) {
        if (pendaftaranProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final user = userProvider.currentUser;
        if (user == null) {
          return const Center(
            child: Text('User tidak ditemukan'),
          );
        }

        // Filter pendaftaran untuk user yang sedang login dan belum selesai
        final userPendaftaran = pendaftaranProvider.pendaftaranList
            .where((p) =>
                p.user.id == user.id && p.status.toLowerCase() != 'completed')
            .toList();

        // Urutkan berdasarkan tanggal terdekat
        userPendaftaran.sort(
            (a, b) => a.tanggalPendaftaran.compareTo(b.tanggalPendaftaran));

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWebLayout = constraints.maxWidth > 600;
            final padding = isWebLayout ? 24.0 : 16.0;

            return SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat Datang, ${user.namaLengkap}!',
                    style: TextStyle(
                      fontSize: isWebLayout ? 28 : 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: isWebLayout ? 200 : 175,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        PageView.builder(
                          itemCount: _carouselImages.length,
                          onPageChanged: (index) {
                            setState(() {
                              _carouselIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                _carouselImages[index],
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            );
                          },
                        ),
                        Positioned(
                          bottom: 12,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_carouselImages.length, (index) {
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _carouselIndex == index
                                      ? Colors.redAccent
                                      : Colors.grey[300],
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 90,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _MenuCard(
                          iconPath: 'assets/icons/darah.png',
                          label: 'Hematologi',
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                title: Row(
                                  children: [
                                    Image.asset(
                                      'assets/icons/darah.png',
                                      width: 32,
                                      height: 32,
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Detail Pemeriksaan Hematologi',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                content: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Komponen Pemeriksaan:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        children: [
                                          _buildChip('Hemoglobin'),
                                          _buildChip('Lekosit'),
                                          _buildChip('Trombosit'),
                                          _buildChip('Hematokrit'),
                                          _buildChip('Hitung Jenis'),
                                          _buildChip('LED'),
                                          _buildChip('Eritosit'),
                                          _buildChip('MC'),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Deskripsi:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Pemeriksaan Hematologi merupakan pemeriksaan dasar yang digunakan secara luas mulai sebagai pemeriksaan penyaring, diagnosis maupun untuk mengikuti perkembangan penyakit; diantaranya penyakit infeksi, kelainan darah, penyakit degeneratif, dan lainnya.',
                                      ),
                                      const SizedBox(height: 16),
                                      _buildInfoSection(
                                        'Spesimen Pemeriksaan',
                                        'Darah dengan antikoagulan EDTA',
                                        Icons.bloodtype,
                                      ),
                                      const SizedBox(height: 12),
                                      _buildInfoSection(
                                        'Persiapan Pemeriksaan',
                                        'Tidak ada persiapan khusus',
                                        Icons.info_outline,
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text(
                                      'Tutup',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        _MenuCard(
                          iconPath: 'assets/icons/jantung.png',
                          label: 'Jantung',
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                title: Row(
                                  children: [
                                    Image.asset(
                                      'assets/icons/jantung.png',
                                      width: 32,
                                      height: 32,
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Detail Pemeriksaan Jantung',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                content: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Deskripsi:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Troponin T adalah protein spesfik yang hanya ada di otot jantung. Pemeriksaan Troponin T digunakan untuk evaluasi dugaan adanya kelainan iskemi koroner akut, misalnya pada kasus nyeri dada. Dibanding dengan cardiac marker lainnya (misalnya CK-MB), pemeriksaan troponin lebih spesifik dan sensitif dalam medeteksi adanya kerusakan otot jantung.',
                                      ),
                                      const SizedBox(height: 16),
                                      _buildInfoSection(
                                        'Spesimen Pemeriksaan',
                                        'Darah',
                                        Icons.bloodtype,
                                      ),
                                      const SizedBox(height: 12),
                                      _buildInfoSection(
                                        'Persiapan Pemeriksaan',
                                        'Tidak ada persiapan khusus',
                                        Icons.info_outline,
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text(
                                      'Tutup',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        _MenuCard(
                          iconPath: 'assets/icons/paruparu.png',
                          label: 'Paru-paru',
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                title: Row(
                                  children: [
                                    Image.asset(
                                      'assets/icons/paruparu.png',
                                      width: 32,
                                      height: 32,
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Detail Pemeriksaan Paru-paru',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                content: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Deskripsi:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Interferon-Gamma Release Assays (IGRA) adalah pemeriksaan darah yang digunakan untuk membantu dalam diagnosis penyakit Tuberkulosis (TB) maupun Infeksi Laten Tuberkulosis (LTBI). Pemeriksaan ini mengukur respon imun seluler terhadap M. Tuberculosis (M. TBC). Hasil Test IGRA yang positip mengindikasikan adanya infeksi oleh kuman TBC.',
                                      ),
                                      const SizedBox(height: 16),
                                      _buildInfoSection(
                                        'Spesimen Pemeriksaan',
                                        'Darah (plasma)',
                                        Icons.bloodtype,
                                      ),
                                      const SizedBox(height: 12),
                                      _buildInfoSection(
                                        'Persiapan Pemeriksaan',
                                        'Tidak ada persiapan khusus',
                                        Icons.info_outline,
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text(
                                      'Tutup',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        _MenuCard(
                          iconPath: 'assets/icons/usus.png',
                          label: 'Usus',
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                title: Row(
                                  children: [
                                    Image.asset(
                                      'assets/icons/usus.png',
                                      width: 32,
                                      height: 32,
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Detail Pemeriksaan Usus',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                content: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Deskripsi:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Fecal Calprotectin adalah protein dalam faeces yang dikeluarkan ketika terjadi proses peradangan di usus. Pemeriksaan Fecal Calprotectin pada umumnya digunakan untuk membantu diagnosa dan monitoring penyakit inflammatory bowel disease (IBD), disamping menilai diare kronik karena inflamasi. Kadar Calprotectin meningkat didapatkan pada penyakit IBD, seperti Crohn\'s Disease atau ulcerative colitis.',
                                      ),
                                      const SizedBox(height: 16),
                                      _buildInfoSection(
                                        'Spesimen Pemeriksaan',
                                        'Faeses',
                                        Icons.science,
                                      ),
                                      const SizedBox(height: 12),
                                      _buildInfoSection(
                                        'Persiapan Pemeriksaan',
                                        'Tidak ada persiapan khusus',
                                        Icons.info_outline,
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text(
                                      'Tutup',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Jadwal MCU Mendatang',
                    style: TextStyle(
                      fontSize: isWebLayout ? 24 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildUpcomingMCUList(userPendaftaran),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUpcomingMCUList(List<dynamic> userPendaftaran) {
    if (userPendaftaran.isEmpty) {
      return const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Tidak ada jadwal MCU mendatang',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: userPendaftaran.length,
      itemBuilder: (context, index) {
        final pendaftaran = userPendaftaran[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.event, color: Colors.blue),
            title: Text(pendaftaran.paketMcu.namaPaket),
            subtitle: Text(
              'Tanggal: ${pendaftaran.tanggalPendaftaran.toString().split(' ')[0]}',
            ),
            trailing: _buildStatusChip(pendaftaran.status),
          ),
        );
      },
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

  Widget _buildChip(String label) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      backgroundColor: Colors.blue,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(content),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String iconPath;
  final String label;
  final VoidCallback? onTap;
  const _MenuCard({required this.iconPath, required this.label, this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          child: SizedBox(
            width: 140,
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  margin: const EdgeInsets.only(right: 12),
                  child: Image.asset(
                    iconPath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 32, color: Colors.grey),
                  ),
                ),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.left,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
